/// Database Helper - Gerenciador do Banco de Dados SQLite
///
/// Singleton que gerencia a conexão com o banco SQLite e todas as operações
/// CRUD (Create, Read, Update, Delete) para as tabelas da aplicação.
///
/// Segurança: SEMPRE usa prepared statements para prevenir SQL Injection.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/database_constants.dart';
import '../models/models.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  /// Factory constructor que retorna a mesma instância
  factory DatabaseHelper() => _instance;

  /// Construtor privado
  DatabaseHelper._internal();

  /// Obtém a instância do banco de dados
  ///
  /// Cria o banco se não existir
  ///
  /// Returns: Database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa o banco de dados
  ///
  /// Cria o arquivo do banco e executa as migrações
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseConstants.databaseName);

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Cria as tabelas do banco (primeira vez)
  Future<void> _onCreate(Database db, int version) async {
    // Tabela de medicamentos
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableMedicamentos} (
        ${DatabaseConstants.fieldId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.fieldNome} TEXT NOT NULL,
        ${DatabaseConstants.fieldDosagem} TEXT NOT NULL,
        ${DatabaseConstants.fieldPrimeiroHorario} TEXT NOT NULL,
        ${DatabaseConstants.fieldIntervaloHoras} INTEGER,
        ${DatabaseConstants.fieldQtdDosesDia} INTEGER,
        ${DatabaseConstants.fieldTipoFrequencia} TEXT,
        ${DatabaseConstants.fieldDiasTratamento} INTEGER NOT NULL,
        ${DatabaseConstants.fieldObservacoes} TEXT,
        ${DatabaseConstants.fieldAtivo} INTEGER NOT NULL DEFAULT 1,
        ${DatabaseConstants.fieldCriadoEm} TEXT NOT NULL,
        ${DatabaseConstants.fieldAtualizadoEm} TEXT
      )
    ''');

    // Tabela de horários de alarmes
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableHorariosAlarmes} (
        ${DatabaseConstants.fieldId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.fieldMedicamentoId} INTEGER NOT NULL,
        ${DatabaseConstants.fieldHorario} TEXT NOT NULL,
        ${DatabaseConstants.fieldAtivo} INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (${DatabaseConstants.fieldMedicamentoId})
          REFERENCES ${DatabaseConstants.tableMedicamentos}(${DatabaseConstants.fieldId})
          ON DELETE CASCADE
      )
    ''');

    // Tabela de histórico de doses
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableHistoricoDoses} (
        ${DatabaseConstants.fieldId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.fieldMedicamentoId} INTEGER NOT NULL,
        ${DatabaseConstants.fieldHorarioPrevisto} TEXT NOT NULL,
        ${DatabaseConstants.fieldHorarioTomado} TEXT,
        ${DatabaseConstants.fieldStatus} TEXT NOT NULL,
        ${DatabaseConstants.fieldDataDose} TEXT NOT NULL,
        FOREIGN KEY (${DatabaseConstants.fieldMedicamentoId})
          REFERENCES ${DatabaseConstants.tableMedicamentos}(${DatabaseConstants.fieldId})
          ON DELETE CASCADE
      )
    ''');

    // Índices para melhorar performance
    await db.execute('''
      CREATE INDEX idx_medicamentos_ativo
      ON ${DatabaseConstants.tableMedicamentos}(${DatabaseConstants.fieldAtivo})
    ''');

    await db.execute('''
      CREATE INDEX idx_horarios_medicamento
      ON ${DatabaseConstants.tableHorariosAlarmes}(${DatabaseConstants.fieldMedicamentoId})
    ''');

    await db.execute('''
      CREATE INDEX idx_historico_medicamento
      ON ${DatabaseConstants.tableHistoricoDoses}(${DatabaseConstants.fieldMedicamentoId})
    ''');

    await db.execute('''
      CREATE INDEX idx_historico_data
      ON ${DatabaseConstants.tableHistoricoDoses}(${DatabaseConstants.fieldDataDose})
    ''');
  }

  /// Migração do banco (futuras versões)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implementar migrações quando necessário
    // Exemplo:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE ...');
    // }
  }

  // ========== OPERAÇÕES DE MEDICAMENTOS ==========

  /// Insere um novo medicamento
  ///
  /// [medicamento] Medicamento a inserir
  ///
  /// Returns: ID do medicamento inserido
  Future<int> insertMedicamento(Medicamento medicamento) async {
    final db = await database;
    return await db.insert(
      DatabaseConstants.tableMedicamentos,
      medicamento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Atualiza um medicamento existente
  ///
  /// [medicamento] Medicamento com dados atualizados
  ///
  /// Returns: Número de linhas afetadas
  Future<int> updateMedicamento(Medicamento medicamento) async {
    final db = await database;
    return await db.update(
      DatabaseConstants.tableMedicamentos,
      medicamento.toMap(),
      where: '${DatabaseConstants.fieldId} = ?',
      whereArgs: [medicamento.id],
    );
  }

  /// Deleta um medicamento (soft delete - marca como inativo)
  ///
  /// [id] ID do medicamento
  ///
  /// Returns: Número de linhas afetadas
  Future<int> deleteMedicamento(int id) async {
    final db = await database;
    return await db.update(
      DatabaseConstants.tableMedicamentos,
      {DatabaseConstants.fieldAtivo: 0},
      where: '${DatabaseConstants.fieldId} = ?',
      whereArgs: [id],
    );
  }

  /// Deleta permanentemente um medicamento
  ///
  /// [id] ID do medicamento
  ///
  /// Returns: Número de linhas afetadas
  Future<int> deleteMedicamentoPermanente(int id) async {
    final db = await database;
    return await db.delete(
      DatabaseConstants.tableMedicamentos,
      where: '${DatabaseConstants.fieldId} = ?',
      whereArgs: [id],
    );
  }

  /// Busca medicamento por ID
  ///
  /// [id] ID do medicamento
  ///
  /// Returns: Medicamento ou null se não encontrado
  Future<Medicamento?> getMedicamentoById(int id) async {
    final db = await database;
    final maps = await db.query(
      DatabaseConstants.tableMedicamentos,
      where: '${DatabaseConstants.fieldId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Medicamento.fromMap(maps.first);
  }

  /// Busca todos os medicamentos ativos
  ///
  /// Returns: Lista de medicamentos
  Future<List<Medicamento>> getMedicamentos({bool apenasAtivos = true}) async {
    final db = await database;
    final maps = await db.query(
      DatabaseConstants.tableMedicamentos,
      where: apenasAtivos ? '${DatabaseConstants.fieldAtivo} = ?' : null,
      whereArgs: apenasAtivos ? [1] : null,
      orderBy: '${DatabaseConstants.fieldNome} ASC',
    );

    return maps.map((map) => Medicamento.fromMap(map)).toList();
  }

  // ========== OPERAÇÕES DE HORÁRIOS DE ALARMES ==========

  /// Insere um novo horário de alarme
  ///
  /// [horario] Horário a inserir
  ///
  /// Returns: ID do horário inserido
  Future<int> insertHorario(HorarioAlarme horario) async {
    final db = await database;
    return await db.insert(
      DatabaseConstants.tableHorariosAlarmes,
      horario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insere múltiplos horários de uma vez
  ///
  /// [horarios] Lista de horários
  ///
  /// Returns: Lista de IDs inseridos
  Future<List<int>> insertHorarios(List<HorarioAlarme> horarios) async {
    final db = await database;
    final batch = db.batch();

    for (final horario in horarios) {
      batch.insert(
        DatabaseConstants.tableHorariosAlarmes,
        horario.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final results = await batch.commit();
    return results.cast<int>();
  }

  /// Busca horários de um medicamento específico
  ///
  /// [medicamentoId] ID do medicamento
  ///
  /// Returns: Lista de horários
  Future<List<HorarioAlarme>> getHorariosByMedicamento(int medicamentoId) async {
    final db = await database;
    final maps = await db.query(
      DatabaseConstants.tableHorariosAlarmes,
      where: '${DatabaseConstants.fieldMedicamentoId} = ?',
      whereArgs: [medicamentoId],
      orderBy: '${DatabaseConstants.fieldHorario} ASC',
    );

    return maps.map((map) => HorarioAlarme.fromMap(map)).toList();
  }

  /// Deleta todos os horários de um medicamento
  ///
  /// [medicamentoId] ID do medicamento
  ///
  /// Returns: Número de linhas afetadas
  Future<int> deleteHorariosByMedicamento(int medicamentoId) async {
    final db = await database;
    return await db.delete(
      DatabaseConstants.tableHorariosAlarmes,
      where: '${DatabaseConstants.fieldMedicamentoId} = ?',
      whereArgs: [medicamentoId],
    );
  }

  // ========== OPERAÇÕES DE HISTÓRICO ==========

  /// Insere um registro de histórico
  ///
  /// [historico] Histórico a inserir
  ///
  /// Returns: ID do histórico inserido
  Future<int> insertHistorico(HistoricoDose historico) async {
    final db = await database;
    return await db.insert(
      DatabaseConstants.tableHistoricoDoses,
      historico.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Busca histórico de um medicamento
  ///
  /// [medicamentoId] ID do medicamento
  /// [dataInicio] Data inicial (opcional)
  /// [dataFim] Data final (opcional)
  ///
  /// Returns: Lista de registros de histórico
  Future<List<HistoricoDose>> getHistorico({
    int? medicamentoId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final db = await database;

    String? where;
    List<dynamic>? whereArgs;

    if (medicamentoId != null) {
      where = '${DatabaseConstants.fieldMedicamentoId} = ?';
      whereArgs = [medicamentoId];

      if (dataInicio != null && dataFim != null) {
        where += ' AND ${DatabaseConstants.fieldDataDose} BETWEEN ? AND ?';
        whereArgs.addAll([
          dataInicio.toIso8601String(),
          dataFim.toIso8601String(),
        ]);
      }
    } else if (dataInicio != null && dataFim != null) {
      where = '${DatabaseConstants.fieldDataDose} BETWEEN ? AND ?';
      whereArgs = [
        dataInicio.toIso8601String(),
        dataFim.toIso8601String(),
      ];
    }

    final maps = await db.query(
      DatabaseConstants.tableHistoricoDoses,
      where: where,
      whereArgs: whereArgs,
      orderBy: '${DatabaseConstants.fieldDataDose} DESC',
    );

    return maps.map((map) => HistoricoDose.fromMap(map)).toList();
  }

  /// Calcula taxa de adesão ao tratamento
  ///
  /// [medicamentoId] ID do medicamento
  /// [dataInicio] Data inicial
  /// [dataFim] Data final
  ///
  /// Returns: Porcentagem de doses tomadas (0-100)
  Future<double> calcularTaxaAdesao({
    required int medicamentoId,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    final db = await database;

    final total = Sqflite.firstIntValue(
      await db.rawQuery('''
        SELECT COUNT(*) FROM ${DatabaseConstants.tableHistoricoDoses}
        WHERE ${DatabaseConstants.fieldMedicamentoId} = ?
        AND ${DatabaseConstants.fieldDataDose} BETWEEN ? AND ?
      ''', [
        medicamentoId,
        dataInicio.toIso8601String(),
        dataFim.toIso8601String(),
      ]),
    ) ?? 0;

    if (total == 0) return 0.0;

    final tomadas = Sqflite.firstIntValue(
      await db.rawQuery('''
        SELECT COUNT(*) FROM ${DatabaseConstants.tableHistoricoDoses}
        WHERE ${DatabaseConstants.fieldMedicamentoId} = ?
        AND ${DatabaseConstants.fieldDataDose} BETWEEN ? AND ?
        AND ${DatabaseConstants.fieldStatus} = ?
      ''', [
        medicamentoId,
        dataInicio.toIso8601String(),
        dataFim.toIso8601String(),
        DatabaseConstants.statusTomado,
      ]),
    ) ?? 0;

    return (tomadas / total) * 100;
  }

  // ========== UTILITÁRIOS ==========

  /// Fecha a conexão com o banco
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Limpa todos os dados do banco (usar com cuidado!)
  Future<void> limparBanco() async {
    final db = await database;
    await db.delete(DatabaseConstants.tableHistoricoDoses);
    await db.delete(DatabaseConstants.tableHorariosAlarmes);
    await db.delete(DatabaseConstants.tableMedicamentos);
  }
}
