/// Modelo de Horário de Alarme
///
/// Representa um horário específico em que um alarme deve tocar
/// para um medicamento.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

import 'package:flutter/material.dart';
import '../../core/constants/database_constants.dart';

class HorarioAlarme {
  final int? id;
  final int medicamentoId;
  final TimeOfDay horario;
  final bool ativo;

  HorarioAlarme({
    this.id,
    required this.medicamentoId,
    required this.horario,
    this.ativo = true,
  });

  /// Converte o horário de alarme para Map (para salvar no SQLite)
  ///
  /// Returns: Map com os campos do horário
  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseConstants.fieldId: id,
      DatabaseConstants.fieldMedicamentoId: medicamentoId,
      DatabaseConstants.fieldHorario: _timeOfDayToString(horario),
      DatabaseConstants.fieldAtivo: ativo ? 1 : 0,
    };
  }

  /// Cria um HorarioAlarme a partir de um Map (do SQLite)
  ///
  /// [map] Map com os dados do horário
  ///
  /// Returns: Instância de HorarioAlarme
  factory HorarioAlarme.fromMap(Map<String, dynamic> map) {
    return HorarioAlarme(
      id: map[DatabaseConstants.fieldId] as int?,
      medicamentoId: map[DatabaseConstants.fieldMedicamentoId] as int,
      horario: _stringToTimeOfDay(map[DatabaseConstants.fieldHorario] as String),
      ativo: (map[DatabaseConstants.fieldAtivo] as int) == 1,
    );
  }

  /// Cria uma cópia do horário com campos modificados
  ///
  /// Returns: Nova instância de HorarioAlarme
  HorarioAlarme copyWith({
    int? id,
    int? medicamentoId,
    TimeOfDay? horario,
    bool? ativo,
  }) {
    return HorarioAlarme(
      id: id ?? this.id,
      medicamentoId: medicamentoId ?? this.medicamentoId,
      horario: horario ?? this.horario,
      ativo: ativo ?? this.ativo,
    );
  }

  /// Converte TimeOfDay para String (formato HH:mm)
  static String _timeOfDayToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Converte String (formato HH:mm) para TimeOfDay
  static TimeOfDay _stringToTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Gera um ID único para o alarme baseado no medicamento e horário
  ///
  /// Returns: ID numérico único para identificar o alarme no sistema
  int gerarIdAlarme() {
    return '${medicamentoId}_${horario.hour}_${horario.minute}'.hashCode;
  }

  /// Formata o horário para exibição
  ///
  /// [context] BuildContext para formatar de acordo com locale
  ///
  /// Returns: String formatada (ex: "08:00")
  String formatarHorario(BuildContext context) {
    return horario.format(context);
  }

  @override
  String toString() {
    return 'HorarioAlarme{id: $id, medicamentoId: $medicamentoId, '
        'horario: ${horario.hour}:${horario.minute}, ativo: $ativo}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HorarioAlarme &&
        other.id == id &&
        other.medicamentoId == medicamentoId &&
        other.horario.hour == horario.hour &&
        other.horario.minute == horario.minute;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      medicamentoId.hashCode ^
      horario.hour.hashCode ^
      horario.minute.hashCode;
}
