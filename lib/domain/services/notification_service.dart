import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import '../../data/preferences/user_preferences.dart';
import '../../data/models/medicamento.dart';
import '../../data/models/horario_alarme.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    _initialized = true;
  }

  Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required UserPreferences prefs,
  }) async {
    // Check if we should avoid early morning
    if (prefs.avoidEarlyMorning) {
      final time = TimeOfDay.fromDateTime(scheduledDate);
      final wakeUp = prefs.wakeUpTime;
      final bedTime = prefs.bedTime;

      // Simple check: if time is before wakeUp or after bedTime
      // Note: This logic can be complex for overnight ranges. 
      // For MVP, let's assume "Active Period" is e.g. 07:00 to 22:00.
      // If scheduled time is outside, we might want to shift it or just warn.
      // For now, we'll just schedule it as is but maybe suppress sound if "Do Not Disturb" was the goal.
      // But the requirement is "Redistribute", which happens at calculation time, not alarm time.
      // So here we just respect volume/sound settings.
    }

    final androidDetails = AndroidNotificationDetails(
      'medication_channel',
      'Lembretes de Medicamentos',
      channelDescription: 'Canal para alarmes de medicamentos',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(prefs.ringtone.split('/').last.split('.').first), // Assumes sound is in res/raw
      // Note: Custom sounds in Flutter Local Notifications need to be in res/raw for Android.
      // The assets/sounds path is for playing via audio player, not native notification sound usually.
      // We might need to copy assets to res/raw or use a default sound if not possible dynamically.
      // For now, let's use default or a specific resource if mapped.
      playSound: true,
      enableVibration: prefs.vibration,
      fullScreenIntent: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      presentBanner: true,
      presentList: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAlarm(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Agenda todos os alarmes de um medicamento
  ///
  /// [medicamento] Medicamento para agendar
  /// [horarios] Lista de horários do medicamento
  /// [prefs] Preferências do usuário para som/vibração
  Future<void> scheduleAllMedicationAlarms({
    required Medicamento medicamento,
    required List<HorarioAlarme> horarios,
    required UserPreferences prefs,
  }) async {
    for (final horario in horarios) {
      await _scheduleMedicationAlarm(
        medicamento: medicamento,
        horario: horario,
        prefs: prefs,
      );
    }
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

    await scheduleAlarm(
      id: alarmId,
      title: 'Hora do Medicamento!',
      body: '${medicamento.nome} ${medicamento.dosagem}\nToque para confirmar',
      scheduledDate: scheduledDate,
      prefs: prefs,
    );
  }

  /// Cancela todos os alarmes de um medicamento
  Future<void> cancelMedicationAlarms(int medicamentoId, List<HorarioAlarme> horarios) async {
    for (final horario in horarios) {
      final alarmId = _generateAlarmId(medicamentoId, horario.horario);
      await cancelAlarm(alarmId);
    }
  }

  /// Gera um ID único para o alarme baseado no medicamento e horário
  int _generateAlarmId(int medicamentoId, TimeOfDay horario) {
    // Combina medicamentoId, hora e minuto para criar ID único
    // Formato: medicamentoId * 10000 + hora * 100 + minuto
    return medicamentoId * 10000 + horario.hour * 100 + horario.minute;
  }

  /// Reagenda um alarme para repetir diariamente
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

    await scheduleAlarm(
      id: alarmId,
      title: 'Hora do Medicamento!',
      body: '${medicamento.nome} ${medicamento.dosagem}\nToque para confirmar',
      scheduledDate: scheduledDate,
      prefs: prefs,
    );
  }
}
