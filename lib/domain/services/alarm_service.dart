/// Serviço de Alarmes
///
/// Gerencia alarmes usando o package 'alarm' que funciona mesmo
/// com o dispositivo bloqueado, como um alarme de despertador.
///
/// Este serviço garante que os alarmes:
/// - Toquem mesmo com o app fechado
/// - Toquem mesmo com o celular bloqueado
/// - Acordem o dispositivo
/// - Exibam notificação em tela cheia
///
/// Autor: Sistema
/// Data: 2025-11-26
library;

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import '../../data/models/medicamento.dart';
import '../../data/models/horario_alarme.dart';
import '../../data/preferences/user_preferences.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  bool _initialized = false;

  /// Inicializa o serviço de alarmes
  Future<void> init() async {
    if (_initialized) return;

    await Alarm.init();
    _initialized = true;

    debugPrint('AlarmService: Serviço de alarmes inicializado');
  }

  /// Agenda todos os alarmes de um medicamento
  Future<void> scheduleAllMedicationAlarms({
    required Medicamento medicamento,
    required List<HorarioAlarme> horarios,
    required UserPreferences prefs,
  }) async {
    if (!_initialized) {
      await init();
    }

    for (final horario in horarios) {
      await _scheduleMedicationAlarm(
        medicamento: medicamento,
        horario: horario,
        prefs: prefs,
      );
    }

    debugPrint('AlarmService: ${horarios.length} alarmes agendados para ${medicamento.nome}');
  }

  /// Agenda um alarme específico de um medicamento
  Future<void> _scheduleMedicationAlarm({
    required Medicamento medicamento,
    required HorarioAlarme horario,
    required UserPreferences prefs,
  }) async {
    // Gera ID único baseado no medicamento e horário
    final alarmId = _generateAlarmId(medicamento.id!, horario.horario);

    // Calcula próxima ocorrência do horário
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      horario.horario.hour,
      horario.horario.minute,
    );

    // Se já passou hoje, agenda para amanhã
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Determinar caminho do som
    String soundPath = prefs.ringtone;

    // Se o toque for de assets, usar o caminho completo
    // Se for personalizado (do dispositivo), o package alarm pode não conseguir usar
    // Então vamos usar um som padrão se não for de assets
    if (!soundPath.startsWith('assets/')) {
      soundPath = 'assets/sounds/alarm.mp3';
      debugPrint('AlarmService: Som personalizado não suportado para alarmes, usando padrão');
    }

    // Configurar alarme
    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: scheduledDate,
      assetAudioPath: soundPath,
      loopAudio: true,
      vibrate: prefs.vibration,
      volume: prefs.volume,
      fadeDuration: 3.0, // Aumentar volume gradualmente
      notificationTitle: '💊 Hora do Medicamento!',
      notificationBody: '${medicamento.nome} ${medicamento.dosagem}',
      enableNotificationOnKill: true,
      androidFullScreenIntent: true,
    );

    try {
      await Alarm.set(alarmSettings: alarmSettings);
      debugPrint('AlarmService: Alarme ${alarmId} agendado para ${scheduledDate.toString()}');
    } catch (e) {
      debugPrint('AlarmService: Erro ao agendar alarme: $e');
      rethrow;
    }
  }

  /// Cancela todos os alarmes de um medicamento
  Future<void> cancelMedicationAlarms(
    int medicamentoId,
    List<HorarioAlarme> horarios,
  ) async {
    for (final horario in horarios) {
      final alarmId = _generateAlarmId(medicamentoId, horario.horario);
      await Alarm.stop(alarmId);
      debugPrint('AlarmService: Alarme $alarmId cancelado');
    }
  }

  /// Cancela um alarme específico
  Future<void> cancelAlarm(int alarmId) async {
    await Alarm.stop(alarmId);
    debugPrint('AlarmService: Alarme $alarmId cancelado');
  }

  /// Cancela todos os alarmes
  Future<void> cancelAllAlarms() async {
    await Alarm.stopAll();
    debugPrint('AlarmService: Todos os alarmes cancelados');
  }

  /// Reagenda um alarme para o próximo dia
  Future<void> rescheduleAlarmForNextDay({
    required int medicamentoId,
    required TimeOfDay horario,
    required Medicamento medicamento,
    required UserPreferences prefs,
  }) async {
    final alarmId = _generateAlarmId(medicamentoId, horario);

    // Agenda para o mesmo horário amanhã
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final scheduledDate = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      horario.hour,
      horario.minute,
    );

    String soundPath = prefs.ringtone;
    if (!soundPath.startsWith('assets/')) {
      soundPath = 'assets/sounds/alarm.mp3';
    }

    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: scheduledDate,
      assetAudioPath: soundPath,
      loopAudio: true,
      vibrate: prefs.vibration,
      volume: prefs.volume,
      fadeDuration: 3.0,
      notificationTitle: '💊 Hora do Medicamento!',
      notificationBody: '${medicamento.nome} ${medicamento.dosagem}',
      enableNotificationOnKill: true,
      androidFullScreenIntent: true,
    );

    await Alarm.set(alarmSettings: alarmSettings);
    debugPrint('AlarmService: Alarme $alarmId reagendado para ${scheduledDate.toString()}');
  }

  /// Gera um ID único para o alarme baseado no medicamento e horário
  int _generateAlarmId(int medicamentoId, TimeOfDay horario) {
    // Combina medicamentoId, hora e minuto para criar ID único
    // Formato: medicamentoId * 10000 + hora * 100 + minuto
    return medicamentoId * 10000 + horario.hour * 100 + horario.minute;
  }

  /// Verifica se um alarme está ativo
  Future<bool> isAlarmActive(int alarmId) async {
    final alarms = await Alarm.getAlarms();
    return alarms.any((alarm) => alarm.id == alarmId);
  }

  /// Lista todos os alarmes ativos
  Future<List<AlarmSettings>> getAllActiveAlarms() async {
    return await Alarm.getAlarms();
  }

  /// Stream de eventos de alarmes
  Stream<AlarmSettings> get alarmStream => Alarm.ringStream.stream;
}
