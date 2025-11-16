/// Provider para gerenciar estado dos medicamentos
///
/// Gerencia a lista de medicamentos, operações CRUD e notifica
/// os widgets quando há mudanças.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

import 'package:flutter/foundation.dart';
import '../../data/models/models.dart';
import '../../data/database/database_helper.dart';
import '../../domain/calculators/calculadora_horarios.dart';

class MedicamentoProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  List<Medicamento> _medicamentos = [];
  bool _loading = false;
  String? _error;

  List<Medicamento> get medicamentos => _medicamentos;
  bool get loading => _loading;
  String? get error => _error;
  bool get temMedicamentos => _medicamentos.isNotEmpty;

  /// Carrega todos os medicamentos do banco
  Future<void> carregarMedicamentos() async {
    _setLoading(true);
    _error = null;

    try {
      _medicamentos = await _db.getMedicamentos();
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar medicamentos: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Adiciona um novo medicamento
  Future<bool> adicionarMedicamento(Medicamento medicamento) async {
    _setLoading(true);
    _error = null;

    try {
      final id = await _db.insertMedicamento(medicamento);

      // Calcular e salvar horários
      final horarios = CalculadoraHorarios.calcular(
        primeiroHorario: medicamento.primeiroHorario,
        frequencia: medicamento.tipoFrequencia,
        intervalo: medicamento.intervaloHoras,
        qtdDoses: medicamento.qtdDosesDia,
      );

      // Salvar horários no banco
      for (final horario in horarios) {
        await _db.insertHorario(
          HorarioAlarme(
            medicamentoId: id,
            horario: horario,
          ),
        );
      }

      await carregarMedicamentos();
      return true;
    } catch (e) {
      _error = 'Erro ao adicionar medicamento: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza um medicamento existente
  Future<bool> atualizarMedicamento(Medicamento medicamento) async {
    _setLoading(true);
    _error = null;

    try {
      await _db.updateMedicamento(medicamento);

      // Recalcular horários
      await _db.deleteHorariosByMedicamento(medicamento.id!);

      final horarios = CalculadoraHorarios.calcular(
        primeiroHorario: medicamento.primeiroHorario,
        frequencia: medicamento.tipoFrequencia,
        intervalo: medicamento.intervaloHoras,
        qtdDoses: medicamento.qtdDosesDia,
      );

      for (final horario in horarios) {
        await _db.insertHorario(
          HorarioAlarme(
            medicamentoId: medicamento.id!,
            horario: horario,
          ),
        );
      }

      await carregarMedicamentos();
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar medicamento: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove um medicamento
  Future<bool> removerMedicamento(int id) async {
    _setLoading(true);
    _error = null;

    try {
      await _db.deleteMedicamento(id);
      await carregarMedicamentos();
      return true;
    } catch (e) {
      _error = 'Erro ao remover medicamento: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Busca horários de um medicamento
  Future<List<HorarioAlarme>> buscarHorarios(int medicamentoId) async {
    try {
      return await _db.getHorariosByMedicamento(medicamentoId);
    } catch (e) {
      debugPrint('Erro ao buscar horários: $e');
      return [];
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void limparErro() {
    _error = null;
    notifyListeners();
  }
}
