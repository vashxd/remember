/// Calculadora de Horários de Medicamentos
///
/// Algoritmo central da aplicação que calcula automaticamente os horários
/// de doses baseado em:
/// - Primeiro horário informado
/// - Frequência predefinida (1x, 2x, 3x ao dia, etc)
/// - Intervalo customizado (ex: 5 em 5 horas)
///
/// Também permite ajustar horários para evitar madrugada.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class CalculadoraHorarios {
  // Classe com métodos estáticos apenas (sem estado)

  /// Método principal - Calcula todos os horários baseado no primeiro
  ///
  /// [primeiroHorario] Primeiro horário do dia
  /// [frequencia] Frequência predefinida ('1x ao dia', '2x ao dia', etc)
  /// [intervalo] Intervalo customizado em horas
  /// [qtdDoses] Quantidade de doses por dia
  ///
  /// Returns: Lista de horários calculados
  ///
  /// Throws: ArgumentError se parâmetros forem inválidos
  ///
  /// Example:
  /// ```dart
  /// final horarios = CalculadoraHorarios.calcular(
  ///   primeiroHorario: TimeOfDay(hour: 8, minute: 0),
  ///   frequencia: '3x ao dia',
  /// );
  /// // Retorna: [08:00, 16:00, 00:00]
  /// ```
  static List<TimeOfDay> calcular({
    required TimeOfDay primeiroHorario,
    String? frequencia,
    int? intervalo,
    int? qtdDoses,
  }) {
    // Validações
    if (intervalo != null && (intervalo < 1 || intervalo > 24)) {
      throw ArgumentError('Intervalo deve estar entre 1 e 24 horas');
    }

    if (qtdDoses != null && (qtdDoses < 1 || qtdDoses > 24)) {
      throw ArgumentError('Quantidade de doses deve estar entre 1 e 24');
    }

    // Decide qual método usar
    if (frequencia != null && frequencia != 'customizada') {
      return _calcularPorFrequencia(primeiroHorario, frequencia);
    }

    if (intervalo != null && qtdDoses != null) {
      return _calcularPorIntervalo(primeiroHorario, intervalo, qtdDoses);
    }

    // Default: apenas o horário fornecido
    return [primeiroHorario];
  }

  /// Calcula horários baseado em frequência predefinida
  ///
  /// [primeiro] Primeiro horário
  /// [frequencia] Frequência ('1x ao dia', '2x ao dia', etc)
  ///
  /// Returns: Lista de horários calculados
  static List<TimeOfDay> _calcularPorFrequencia(
    TimeOfDay primeiro,
    String frequencia,
  ) {
    final intervaloHoras = AppConstants.intervalosPredefinidos[frequencia];

    if (intervaloHoras == null) {
      throw ArgumentError('Frequência "$frequencia" não é válida');
    }

    final qtdDoses = 24 ~/ intervaloHoras;
    return _calcularPorIntervalo(primeiro, intervaloHoras, qtdDoses);
  }

  /// Calcula horários baseado em intervalo customizado
  ///
  /// [primeiro] Primeiro horário
  /// [intervaloHoras] Intervalo entre doses em horas
  /// [qtdDoses] Quantidade de doses por dia
  ///
  /// Returns: Lista de horários calculados
  ///
  /// Example:
  /// ```dart
  /// // 3 doses a cada 8 horas, começando às 08:00
  /// final horarios = _calcularPorIntervalo(
  ///   TimeOfDay(hour: 8, minute: 0),
  ///   8,
  ///   3,
  /// );
  /// // Retorna: [08:00, 16:00, 00:00]
  /// ```
  static List<TimeOfDay> _calcularPorIntervalo(
    TimeOfDay primeiro,
    int intervaloHoras,
    int qtdDoses,
  ) {
    final List<TimeOfDay> horarios = [];

    for (int i = 0; i < qtdDoses; i++) {
      final horaCalculada = (primeiro.hour + (intervaloHoras * i)) % 24;
      horarios.add(TimeOfDay(hour: horaCalculada, minute: primeiro.minute));
    }

    return horarios;
  }

  /// Ajusta horários para evitar madrugada
  ///
  /// Redistribui os horários apenas dentro do período ativo (acordado).
  /// Útil para idosos que não querem ser acordados de madrugada.
  ///
  /// [horarios] Horários originais
  /// [horaAcordar] Hora em que a pessoa acorda (padrão: 7h)
  /// [horaDormir] Hora em que a pessoa dorme (padrão: 22h)
  ///
  /// Returns: Horários ajustados para o período ativo
  ///
  /// Example:
  /// ```dart
  /// final horarios = [
  ///   TimeOfDay(hour: 8, minute: 0),
  ///   TimeOfDay(hour: 16, minute: 0),
  ///   TimeOfDay(hour: 0, minute: 0), // meia-noite
  /// ];
  ///
  /// final ajustados = CalculadoraHorarios.ajustarParaPeriodoAtivo(horarios);
  /// // Retorna: [08:00, 13:00, 18:00]
  /// ```
  static List<TimeOfDay> ajustarParaPeriodoAtivo(
    List<TimeOfDay> horarios, {
    TimeOfDay horaAcordar = const TimeOfDay(hour: 7, minute: 0),
    TimeOfDay horaDormir = const TimeOfDay(hour: 22, minute: 0),
  }) {
    if (horarios.isEmpty) return [];

    // Validação
    if (horaDormir.hour <= horaAcordar.hour) {
      throw ArgumentError(
        'Hora de dormir deve ser maior que hora de acordar',
      );
    }

    final List<TimeOfDay> ajustados = [];
    final horasAtivas = horaDormir.hour - horaAcordar.hour;
    final qtdHorarios = horarios.length;

    // Se só tem 1 horário, mantém o minuto original
    if (qtdHorarios == 1) {
      return [
        TimeOfDay(
          hour: horaAcordar.hour,
          minute: horarios[0].minute,
        ),
      ];
    }

    // Calcula intervalo para distribuir uniformemente
    final intervalo = horasAtivas / qtdHorarios;

    for (int i = 0; i < qtdHorarios; i++) {
      final novaHora = horaAcordar.hour + (intervalo * i).floor();
      ajustados.add(
        TimeOfDay(
          hour: novaHora,
          minute: horarios[i].minute,
        ),
      );
    }

    return ajustados;
  }

  /// Verifica se um horário está dentro do período ativo
  ///
  /// [horario] Horário a verificar
  /// [horaAcordar] Hora de acordar
  /// [horaDormir] Hora de dormir
  ///
  /// Returns: true se está no período ativo
  static bool estaNoPeriodoAtivo(
    TimeOfDay horario, {
    TimeOfDay horaAcordar = const TimeOfDay(hour: 7, minute: 0),
    TimeOfDay horaDormir = const TimeOfDay(hour: 22, minute: 0),
  }) {
    return horario.hour >= horaAcordar.hour &&
        horario.hour < horaDormir.hour;
  }

  /// Verifica se algum horário cai na madrugada
  ///
  /// [horarios] Lista de horários
  /// [horaAcordar] Hora de acordar
  /// [horaDormir] Hora de dormir
  ///
  /// Returns: true se algum horário está na madrugada
  static bool temHorarioNaMadrugada(
    List<TimeOfDay> horarios, {
    TimeOfDay horaAcordar = const TimeOfDay(hour: 7, minute: 0),
    TimeOfDay horaDormir = const TimeOfDay(hour: 22, minute: 0),
  }) {
    return horarios.any(
      (h) => !estaNoPeriodoAtivo(h,
          horaAcordar: horaAcordar, horaDormir: horaDormir),
    );
  }

  /// Encontra o próximo horário a partir de agora
  ///
  /// [horarios] Lista de horários possíveis
  /// [agora] Horário atual (padrão: TimeOfDay.now())
  ///
  /// Returns: Próximo horário ou null se lista vazia
  ///
  /// Example:
  /// ```dart
  /// final horarios = [
  ///   TimeOfDay(hour: 8, minute: 0),
  ///   TimeOfDay(hour: 14, minute: 0),
  ///   TimeOfDay(hour: 20, minute: 0),
  /// ];
  ///
  /// // Se agora são 10:00
  /// final proximo = CalculadoraHorarios.proximoHorario(
  ///   horarios,
  ///   TimeOfDay(hour: 10, minute: 0),
  /// );
  /// // Retorna: 14:00
  /// ```
  static TimeOfDay? proximoHorario(
    List<TimeOfDay> horarios, {
    TimeOfDay? agora,
  }) {
    if (horarios.isEmpty) return null;

    agora ??= TimeOfDay.now();
    final minutoAtual = agora.hour * 60 + agora.minute;

    // Ordena horários por minutos do dia
    final horariosOrdenados = [...horarios]..sort((a, b) {
        final minutosA = a.hour * 60 + a.minute;
        final minutosB = b.hour * 60 + b.minute;
        return minutosA.compareTo(minutosB);
      });

    // Procura o próximo horário hoje
    for (final horario in horariosOrdenados) {
      final minutoHorario = horario.hour * 60 + horario.minute;
      if (minutoHorario > minutoAtual) {
        return horario;
      }
    }

    // Se não encontrou, retorna o primeiro horário (será amanhã)
    return horariosOrdenados.first;
  }

  /// Formata lista de horários para string
  ///
  /// [horarios] Lista de horários
  /// [separador] Separador entre horários (padrão: ', ')
  ///
  /// Returns: String com horários formatados
  ///
  /// Example:
  /// ```dart
  /// final str = CalculadoraHorarios.formatarHorarios([
  ///   TimeOfDay(hour: 8, minute: 0),
  ///   TimeOfDay(hour: 14, minute: 30),
  /// ]);
  /// // Retorna: "08:00, 14:30"
  /// ```
  static String formatarHorarios(
    List<TimeOfDay> horarios, {
    String separador = ', ',
  }) {
    return horarios.map((h) {
      final hora = h.hour.toString().padLeft(2, '0');
      final minuto = h.minute.toString().padLeft(2, '0');
      return '$hora:$minuto';
    }).join(separador);
  }

  /// Verifica se dois horários são iguais (ignora segundos)
  ///
  /// [h1] Primeiro horário
  /// [h2] Segundo horário
  ///
  /// Returns: true se são iguais
  static bool horariosIguais(TimeOfDay h1, TimeOfDay h2) {
    return h1.hour == h2.hour && h1.minute == h2.minute;
  }

  /// Detecta conflitos de horários (horários muito próximos)
  ///
  /// [horarios] Lista de horários
  /// [minimoMinutosEntre] Mínimo de minutos entre horários (padrão: 30)
  ///
  /// Returns: Lista de pares de horários conflitantes
  ///
  /// Example:
  /// ```dart
  /// final conflitos = CalculadoraHorarios.detectarConflitos([
  ///   TimeOfDay(hour: 8, minute: 0),
  ///   TimeOfDay(hour: 8, minute: 15), // muito próximo!
  /// ]);
  /// // Retorna lista com o conflito detectado
  /// ```
  static List<List<TimeOfDay>> detectarConflitos(
    List<TimeOfDay> horarios, {
    int minimoMinutosEntre = 30,
  }) {
    final List<List<TimeOfDay>> conflitos = [];

    for (int i = 0; i < horarios.length; i++) {
      for (int j = i + 1; j < horarios.length; j++) {
        final h1 = horarios[i];
        final h2 = horarios[j];

        final minutos1 = h1.hour * 60 + h1.minute;
        final minutos2 = h2.hour * 60 + h2.minute;
        final diferenca = (minutos1 - minutos2).abs();

        if (diferenca < minimoMinutosEntre) {
          conflitos.add([h1, h2]);
        }
      }
    }

    return conflitos;
  }
}
