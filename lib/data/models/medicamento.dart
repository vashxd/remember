/// Modelo de Medicamento
///
/// Representa um medicamento cadastrado no sistema com todas as
/// configurações de horários e frequência.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

import 'package:flutter/material.dart';
import '../../core/constants/database_constants.dart';

class Medicamento {
  final int? id;
  final String nome;
  final String dosagem;
  final TimeOfDay primeiroHorario;
  final int? intervaloHoras;
  final int? qtdDosesDia;
  final String? tipoFrequencia;
  final int diasTratamento;
  final String? observacoes;
  final bool ativo;
  final DateTime criadoEm;
  final DateTime? atualizadoEm;

  Medicamento({
    this.id,
    required this.nome,
    required this.dosagem,
    required this.primeiroHorario,
    this.intervaloHoras,
    this.qtdDosesDia,
    this.tipoFrequencia,
    required this.diasTratamento,
    this.observacoes,
    this.ativo = true,
    DateTime? criadoEm,
    this.atualizadoEm,
  }) : criadoEm = criadoEm ?? DateTime.now();

  /// Converte o medicamento para Map (para salvar no SQLite)
  ///
  /// Returns: Map com os campos do medicamento
  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseConstants.fieldId: id,
      DatabaseConstants.fieldNome: nome,
      DatabaseConstants.fieldDosagem: dosagem,
      DatabaseConstants.fieldPrimeiroHorario: _timeOfDayToString(primeiroHorario),
      if (intervaloHoras != null)
        DatabaseConstants.fieldIntervaloHoras: intervaloHoras,
      if (qtdDosesDia != null)
        DatabaseConstants.fieldQtdDosesDia: qtdDosesDia,
      if (tipoFrequencia != null)
        DatabaseConstants.fieldTipoFrequencia: tipoFrequencia,
      DatabaseConstants.fieldDiasTratamento: diasTratamento,
      if (observacoes != null)
        DatabaseConstants.fieldObservacoes: observacoes,
      DatabaseConstants.fieldAtivo: ativo ? 1 : 0,
      DatabaseConstants.fieldCriadoEm: criadoEm.toIso8601String(),
      if (atualizadoEm != null)
        DatabaseConstants.fieldAtualizadoEm: atualizadoEm!.toIso8601String(),
    };
  }

  /// Cria um Medicamento a partir de um Map (do SQLite)
  ///
  /// [map] Map com os dados do medicamento
  ///
  /// Returns: Instância de Medicamento
  factory Medicamento.fromMap(Map<String, dynamic> map) {
    return Medicamento(
      id: map[DatabaseConstants.fieldId] as int?,
      nome: map[DatabaseConstants.fieldNome] as String,
      dosagem: map[DatabaseConstants.fieldDosagem] as String,
      primeiroHorario: _stringToTimeOfDay(
        map[DatabaseConstants.fieldPrimeiroHorario] as String,
      ),
      intervaloHoras: map[DatabaseConstants.fieldIntervaloHoras] as int?,
      qtdDosesDia: map[DatabaseConstants.fieldQtdDosesDia] as int?,
      tipoFrequencia: map[DatabaseConstants.fieldTipoFrequencia] as String?,
      diasTratamento: map[DatabaseConstants.fieldDiasTratamento] as int,
      observacoes: map[DatabaseConstants.fieldObservacoes] as String?,
      ativo: (map[DatabaseConstants.fieldAtivo] as int) == 1,
      criadoEm: DateTime.parse(map[DatabaseConstants.fieldCriadoEm] as String),
      atualizadoEm: map[DatabaseConstants.fieldAtualizadoEm] != null
          ? DateTime.parse(map[DatabaseConstants.fieldAtualizadoEm] as String)
          : null,
    );
  }

  /// Cria uma cópia do medicamento com campos modificados
  ///
  /// Útil para imutabilidade e atualizações
  ///
  /// Returns: Nova instância de Medicamento com campos atualizados
  Medicamento copyWith({
    int? id,
    String? nome,
    String? dosagem,
    TimeOfDay? primeiroHorario,
    int? intervaloHoras,
    int? qtdDosesDia,
    String? tipoFrequencia,
    int? diasTratamento,
    String? observacoes,
    bool? ativo,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Medicamento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      dosagem: dosagem ?? this.dosagem,
      primeiroHorario: primeiroHorario ?? this.primeiroHorario,
      intervaloHoras: intervaloHoras ?? this.intervaloHoras,
      qtdDosesDia: qtdDosesDia ?? this.qtdDosesDia,
      tipoFrequencia: tipoFrequencia ?? this.tipoFrequencia,
      diasTratamento: diasTratamento ?? this.diasTratamento,
      observacoes: observacoes ?? this.observacoes,
      ativo: ativo ?? this.ativo,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? DateTime.now(),
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

  /// Formata o horário para exibição
  ///
  /// [context] BuildContext para formatar de acordo com locale
  ///
  /// Returns: String formatada (ex: "08:00")
  String formatarHorario(BuildContext context) {
    return primeiroHorario.format(context);
  }

  /// Retorna descrição da frequência
  ///
  /// Returns: String descritiva da frequência
  String get descricaoFrequencia {
    if (tipoFrequencia != null &&
        tipoFrequencia != DatabaseConstants.freqCustomizada) {
      return tipoFrequencia!;
    }

    if (intervaloHoras != null && qtdDosesDia != null) {
      return '$qtdDosesDia doses a cada $intervaloHoras horas';
    }

    return '1x ao dia';
  }

  @override
  String toString() {
    return 'Medicamento{id: $id, nome: $nome, dosagem: $dosagem, '
        'frequencia: $descricaoFrequencia}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Medicamento &&
        other.id == id &&
        other.nome == nome &&
        other.dosagem == dosagem;
  }

  @override
  int get hashCode => id.hashCode ^ nome.hashCode ^ dosagem.hashCode;
}
