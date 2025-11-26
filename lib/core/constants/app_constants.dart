/// Constantes gerais da aplicação
///
/// Define limites, valores padrão e configurações globais.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

class AppConstants {
  // Limites
  static const int maxDosesPorDia = 24;
  static const int minDosesPorDia = 1;
  static const int maxIntervaloHoras = 24;
  static const int minIntervaloHoras = 1;
  static const int maxDiasTratamento = 365;
  static const int minDiasTratamento = 1;
  static const int maxNomeLength = 100;
  static const int maxDosagemLength = 50;
  static const int maxObservacoesLength = 500;

  // Valores padrão
  static const int defaultDiasTratamento = 30;
  static const int defaultTempoSoneca = 10; // minutos
  static const int defaultDiasReabastecimento = 7; // alertar quando restar

  // Horários padrão
  static const int horaAcordarPadrao = 7;
  static const int horaDormirPadrao = 22;

  // Intervalos predefinidos (em horas)
  static const Map<String, int> intervalosPredefinidos = {
    '1x ao dia': 24,
    '2x ao dia': 12,
    '3x ao dia': 8,
    '4x ao dia': 6,
    '6x ao dia': 4,
  };

  // Lista de frequências disponíveis
  static const List<String> frequenciasPredefinidas = [
    '1x ao dia',
    '2x ao dia',
    '3x ao dia',
    '4x ao dia',
    '6x ao dia',
    'customizada',
  ];

  // Mensagens
  static const String appName = 'Lembrete de Medicamentos';
  static const String appVersion = '1.0.0';

  // Notificações
  static const String channelId = 'alarmes_medicamentos';
  static const String channelName = 'Lembretes de Medicamentos';
  static const String channelDescription =
      'Notificações para lembrar de tomar medicamentos';

  // Assets
  static const String soundAlarmePath = 'assets/sounds/alarme_medicamento.mp3';
}
