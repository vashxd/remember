/// Tela de Alarme Tocando
///
/// Exibida quando um alarme de medicamento toca.
/// Permite ao usuário parar o alarme ou ativar soneca.
///
/// Autor: Sistema
/// Data: 2025-11-26
library;

import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:provider/provider.dart';
import '../../../data/database/database_helper.dart';
import '../../../domain/services/alarm_service.dart';
import '../../../data/preferences/user_preferences.dart';
import '../../providers/medicamento_provider.dart';

class AlarmRingPage extends StatelessWidget {
  final AlarmSettings alarmSettings;
  final VoidCallback? onDismissed;

  const AlarmRingPage({
    super.key,
    required this.alarmSettings,
    this.onDismissed,
  });

  /// Extrai informações do ID do alarme
  /// Formato: medicamentoId * 10000 + hora * 100 + minuto
  Map<String, int> _parseAlarmId(int alarmId) {
    final medicamentoId = alarmId ~/ 10000;
    final resto = alarmId % 10000;
    final hora = resto ~/ 100;
    final minuto = resto % 100;

    return {
      'medicamentoId': medicamentoId,
      'hora': hora,
      'minuto': minuto,
    };
  }

  Future<void> _stopAlarm(BuildContext context) async {
    final alarmService = AlarmService();
    final db = DatabaseHelper();
    final parsed = _parseAlarmId(alarmSettings.id);

    // Parar o alarme
    await Alarm.stop(alarmSettings.id);

    // Reagendar para o próximo dia
    try {
      final medicamento = await db.getMedicamentoById(parsed['medicamentoId']!);
      final prefs = await UserPreferences.init();

      if (medicamento != null) {
        await alarmService.rescheduleAlarmForNextDay(
          medicamentoId: parsed['medicamentoId']!,
          horario: TimeOfDay(hour: parsed['hora']!, minute: parsed['minuto']!),
          medicamento: medicamento,
          prefs: prefs,
        );

        debugPrint('Alarme parado e reagendado para amanhã');
      }
    } catch (e) {
      debugPrint('Erro ao reagendar alarme: $e');
    }

    // Notify parent that alarm was dismissed
    onDismissed?.call();

    // Fechar a tela
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _snoozeAlarm(BuildContext context) async {
    // Parar o alarme atual
    await Alarm.stop(alarmSettings.id);

    // Get user's snooze preference
    final prefs = await UserPreferences.init();
    final snoozeMinutes = prefs.snoozeMinutes;

    // Reagendar para X minutos no futuro (baseado na preferência do usuário)
    final snoozeTime = DateTime.now().add(Duration(minutes: snoozeMinutes));

    final snoozeSettings = AlarmSettings(
      id: alarmSettings.id,
      dateTime: snoozeTime,
      assetAudioPath: alarmSettings.assetAudioPath,
      loopAudio: alarmSettings.loopAudio,
      vibrate: alarmSettings.vibrate,
      volume: alarmSettings.volume,
      fadeDuration: alarmSettings.fadeDuration,
      notificationTitle: alarmSettings.notificationTitle,
      notificationBody: '⏰ Soneca ($snoozeMinutes min) - ${alarmSettings.notificationBody}',
      enableNotificationOnKill: alarmSettings.enableNotificationOnKill,
      androidFullScreenIntent: alarmSettings.androidFullScreenIntent,
    );

    await Alarm.set(alarmSettings: snoozeSettings);

    debugPrint('Alarme em soneca por $snoozeMinutes minutos');

    // Notify parent that alarm was dismissed
    onDismissed?.call();

    // Fechar a tela
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parseAlarmId(alarmSettings.id);

    return WillPopScope(
      // Prevent back button from dismissing without stopping alarm
      onWillPop: () async => false,
      child: Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone de medicamento animado
              Icon(
                Icons.medication_rounded,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 32),

              // Título
              Text(
                'Hora do Medicamento!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Horário
              Text(
                '${parsed['hora']!.toString().padLeft(2, '0')}:${parsed['minuto']!.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              // Nome do medicamento (da notificação)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  alarmSettings.notificationBody ?? 'Medicamento',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 64),

              // Botão de Parar (grande e destacado)
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: () => _stopAlarm(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        'TOMEI O REMÉDIO',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botão de Soneca (secundário)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton(
                  onPressed: () => _snoozeAlarm(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.snooze, size: 28),
                      const SizedBox(width: 12),
                      FutureBuilder<int>(
                        future: UserPreferences.init().then((p) => p.snoozeMinutes),
                        builder: (context, snapshot) {
                          final minutes = snapshot.data ?? 10;
                          return Text(
                            'Soneca ($minutes min)',
                            style: const TextStyle(
                          fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
