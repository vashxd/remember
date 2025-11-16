# Data

## Propósito
Camada de dados responsável por persistência e modelos de dados. Gerencia o banco SQLite e define as estruturas de dados da aplicação.

## Estrutura

### database/
Gerenciamento do banco de dados SQLite
- **database_helper.dart**: Singleton para gerenciar conexão e operações do SQLite
- **migrations.dart**: Controle de versões e migrações do banco

### models/
Modelos de dados (DTOs - Data Transfer Objects)
- **medicamento.dart**: Modelo de medicamento
- **horario_alarme.dart**: Modelo de horário de alarme
- **historico_dose.dart**: Modelo de histórico de doses
- **configuracoes_usuario.dart**: Modelo de configurações

## Arquivos

### database_helper.dart
- **Propósito**: Gerenciar conexão SQLite e operações CRUD
- **Padrão**: Singleton
- **Principais métodos**:
  - `getInstance()`: Obter instância única
  - `initDatabase()`: Inicializar banco
  - `insertMedicamento()`, `updateMedicamento()`, `deleteMedicamento()`
  - `getMedicamentos()`, `getMedicamentoById()`
  - `insertHorario()`, `getHorariosByMedicamento()`
  - `insertHistorico()`, `getHistorico()`
- **Dependências**: sqflite, path
- **Usado por**: Services (domain layer)

### medicamento.dart
- **Propósito**: Representar um medicamento no sistema
- **Campos**:
  - `id`, `nome`, `dosagem`
  - `primeiroHorario`, `intervaloHoras`, `qtdDosesDia`
  - `tipoFrequencia`, `diasTratamento`, `observacoes`
  - `criadoEm`
- **Métodos**:
  - `toMap()`: Converter para Map (SQLite)
  - `fromMap()`: Criar instância de Map
  - `copyWith()`: Criar cópia com modificações
- **Validações**: Dados sempre validados antes de salvar

## Padrões Específicos

### Modelos
```dart
class Medicamento {
  final int? id;
  final String nome;
  final String dosagem;

  // Construtor com campos obrigatórios
  Medicamento({
    this.id,
    required this.nome,
    required this.dosagem,
  });

  // Sempre implementar toMap e fromMap
  Map<String, dynamic> toMap() => {...};
  factory Medicamento.fromMap(Map<String, dynamic> map) => Medicamento(...);

  // copyWith para imutabilidade
  Medicamento copyWith({...}) => Medicamento(...);
}
```

### Database Helper
```dart
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Sempre usar prepared statements
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }
}
```

### Segurança
- **NUNCA** interpolar strings diretamente em queries
- **SEMPRE** usar prepared statements (whereArgs)
- **VALIDAR** todos os dados antes de inserir
- **SANITIZAR** entrada do usuário

```dart
// CORRETO
await db.query('medicamentos', where: 'id = ?', whereArgs: [id]);

// ERRADO - Vulnerável a SQL Injection
await db.rawQuery('SELECT * FROM medicamentos WHERE id = $id');
```

## Exemplo de Uso

```dart
// Criar medicamento
final medicamento = Medicamento(
  nome: 'Losartana',
  dosagem: '50mg',
  tipoFrequencia: '2x ao dia',
  primeiroHorario: TimeOfDay(hour: 8, minute: 0),
);

// Salvar
final db = DatabaseHelper();
final id = await db.insertMedicamento(medicamento);

// Buscar
final medicamentos = await db.getMedicamentos();
```

## Dependências
- sqflite (banco de dados)
- path (paths do sistema)
- core/constants (constantes do banco)

## Usado Por
- domain/services (lógica de negócio)
