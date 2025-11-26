/// Provider para gerenciar estado dos medicamentos
///
/// Gerencia a lista de medicamentos, operações CRUD e notifica
/// os widgets quando há mudanças.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../../data/database/database_helper.dart';
import '../../domain/calculators/calculadora_horarios.dart';
import '../../domain/services/notification_service.dart';
import '../../domain/services/alarm_service.dart';
import '../../data/preferences/user_preferences.dart';

class MedicamentoProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();
  final AlarmService _alarmService = AlarmService();
  UserPreferences? _prefs;

  List<Medicamento> _medicamentos = [];
  bool _loading = false;
  String? _error;

  /// Inicializa o provider com as preferências do usuário
  Future<void> init() async {
    _prefs = await UserPreferences.init();
    await _notificationService.init();
    await _alarmService.init();
  }

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
  ///
  /// [medicamento] Medicamento a ser adicionado
  /// [horariosCalculados] Horários já calculados (opcional). Se não fornecido, calcula automaticamente.
  Future<bool> adicionarMedicamento(
    Medicamento medicamento, [
    List<TimeOfDay>? horariosCalculados,
  ]) async {
    _setLoading(true);
    _error = null;

    try {
      final id = await _db.insertMedicamento(medicamento);

      // Usar horários fornecidos ou calcular automaticamente
      final horarios = horariosCalculados ??
          CalculadoraHorarios.calcular(
            primeiroHorario: medicamento.primeiroHorario,
            frequencia: medicamento.tipoFrequencia,
            intervalo: medicamento.intervaloHoras,
            qtdDoses: medicamento.qtdDosesDia,
          );

      // Salvar horários no banco
      final horariosAlarme = <HorarioAlarme>[];
      for (final horario in horarios) {
        final horarioAlarme = HorarioAlarme(
          medicamentoId: id,
          horario: horario,
        );
        await _db.insertHorario(horarioAlarme);
        horariosAlarme.add(horarioAlarme);
      }

      // Agendar alarmes (usando AlarmService ao invés de NotificationService)
      if (_prefs != null) {
        final medicamentoSalvo = medicamento.copyWith(id: id);
        await _alarmService.scheduleAllMedicationAlarms(
          medicamento: medicamentoSalvo,
          horarios: horariosAlarme,
          prefs: _prefs!,
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
      // Buscar horários antes de deletar para cancelar alarmes
      final horarios = await _db.getHorariosByMedicamento(id);

      // Cancelar alarmes
      await _alarmService.cancelMedicationAlarms(id, horarios);

      // Deletar do banco
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
