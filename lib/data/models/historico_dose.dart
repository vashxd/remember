/// Modelo de Histórico de Dose
///
/// Registra quando uma dose foi tomada, pulada ou adiada.
/// Usado para acompanhamento do tratamento e geração de relatórios.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

import 'package:flutter/material.dart';
import '../../core/constants/database_constants.dart';

class HistoricoDose {
  final int? id;
  final int medicamentoId;
  final TimeOfDay horarioPrevisto;
  final DateTime? horarioTomado;
  final String status;
  final DateTime dataDose;
  final String? observacoes;

  HistoricoDose({
    this.id,
    required this.medicamentoId,
    required this.horarioPrevisto,
    this.horarioTomado,
    required this.status,
    DateTime? dataDose,
    this.observacoes,
  }) : dataDose = dataDose ?? DateTime.now();

  /// Converte o histórico para Map (para salvar no SQLite)
  ///
  /// Returns: Map com os campos do histórico
  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseConstants.fieldId: id,
      DatabaseConstants.fieldMedicamentoId: medicamentoId,
      DatabaseConstants.fieldHorarioPrevisto: _timeOfDayToString(horarioPrevisto),
      if (horarioTomado != null)
        DatabaseConstants.fieldHorarioTomado: horarioTomado!.toIso8601String(),
      DatabaseConstants.fieldStatus: status,
      DatabaseConstants.fieldDataDose: dataDose.toIso8601String(),
      if (observacoes != null) DatabaseConstants.fieldObservacoes: observacoes,
    };
  }

  /// Cria um HistoricoDose a partir de um Map (do SQLite)
  ///
  /// [map] Map com os dados do histórico
  ///
  /// Returns: Instância de HistoricoDose
  factory HistoricoDose.fromMap(Map<String, dynamic> map) {
    return HistoricoDose(
      id: map[DatabaseConstants.fieldId] as int?,
      medicamentoId: map[DatabaseConstants.fieldMedicamentoId] as int,
      horarioPrevisto: _stringToTimeOfDay(
        map[DatabaseConstants.fieldHorarioPrevisto] as String,
      ),
      horarioTomado: map[DatabaseConstants.fieldHorarioTomado] != null
          ? DateTime.parse(map[DatabaseConstants.fieldHorarioTomado] as String)
          : null,
      status: map[DatabaseConstants.fieldStatus] as String,
      dataDose: DateTime.parse(map[DatabaseConstants.fieldDataDose] as String),
      observacoes: map[DatabaseConstants.fieldObservacoes] as String?,
    );
  }

  /// Cria uma cópia do histórico com campos modificados
  ///
  /// Returns: Nova instância de HistoricoDose
  HistoricoDose copyWith({
    int? id,
    int? medicamentoId,
    TimeOfDay? horarioPrevisto,
    DateTime? horarioTomado,
    String? status,
    DateTime? dataDose,
    String? observacoes,
  }) {
    return HistoricoDose(
      id: id ?? this.id,
      medicamentoId: medicamentoId ?? this.medicamentoId,
      horarioPrevisto: horarioPrevisto ?? this.horarioPrevisto,
      horarioTomado: horarioTomado ?? this.horarioTomado,
      status: status ?? this.status,
      dataDose: dataDose ?? this.dataDose,
      observacoes: observacoes ?? this.observacoes,
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

  /// Verifica se a dose foi tomada
  bool get foiTomada => status == DatabaseConstants.statusTomado;

  /// Verifica se a dose foi pulada
  bool get foiPulada => status == DatabaseConstants.statusPulado;

  /// Verifica se a dose foi adiada
  bool get foiAdiada => status == DatabaseConstants.statusAdiado;

  /// Verifica se a dose está pendente
  bool get estaPendente => status == DatabaseConstants.statusPendente;

  /// Calcula o atraso em minutos (se houver)
  ///
  /// Returns: Minutos de atraso (negativo se adiantou, 0 se na hora)
  int? calcularAtrasoMinutos() {
    if (horarioTomado == null) return null;

    final previstoDateTime = DateTime(
      dataDose.year,
      dataDose.month,
      dataDose.day,
      horarioPrevisto.hour,
      horarioPrevisto.minute,
    );

    return horarioTomado!.difference(previstoDateTime).inMinutes;
  }

  /// Retorna descrição do status em português
  String get descricaoStatus {
    switch (status) {
      case DatabaseConstants.statusTomado:
        return 'Tomado';
      case DatabaseConstants.statusPulado:
        return 'Pulado';
      case DatabaseConstants.statusAdiado:
        return 'Adiado';
      case DatabaseConstants.statusPendente:
        return 'Pendente';
      default:
        return 'Desconhecido';
    }
  }

  /// Retorna cor associada ao status
  Color get corStatus {
    switch (status) {
      case DatabaseConstants.statusTomado:
        return Colors.green;
      case DatabaseConstants.statusPulado:
        return Colors.red;
      case DatabaseConstants.statusAdiado:
        return Colors.orange;
      case DatabaseConstants.statusPendente:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  String toString() {
    return 'HistoricoDose{id: $id, medicamentoId: $medicamentoId, '
        'status: $status, data: ${dataDose.toLocal()}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HistoricoDose &&
        other.id == id &&
        other.medicamentoId == medicamentoId &&
        other.dataDose == dataDose;
  }

  @override
  int get hashCode =>
      id.hashCode ^ medicamentoId.hashCode ^ dataDose.hashCode;
}
