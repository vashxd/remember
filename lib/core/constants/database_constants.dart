/// Constantes do banco de dados SQLite
///
/// Define nomes de tabelas, campos e versões do banco.
/// Centraliza strings para evitar typos e facilitar manutenção.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

class DatabaseConstants {
  // Configuração do banco
  static const String databaseName = 'lembrete_medicamentos.db';
  static const int databaseVersion = 1;

  // Tabelas
  static const String tableMedicamentos = 'medicamentos';
  static const String tableHorariosAlarmes = 'horarios_alarmes';
  static const String tableHistoricoDoses = 'historico_doses';
  static const String tableConfiguracoes = 'configuracoes';

  // Campos comuns
  static const String fieldId = 'id';
  static const String fieldCriadoEm = 'criado_em';
  static const String fieldAtualizadoEm = 'atualizado_em';

  // Campos de medicamentos
  static const String fieldNome = 'nome';
  static const String fieldDosagem = 'dosagem';
  static const String fieldPrimeiroHorario = 'primeiro_horario';
  static const String fieldIntervaloHoras = 'intervalo_horas';
  static const String fieldQtdDosesDia = 'qtd_doses_dia';
  static const String fieldTipoFrequencia = 'tipo_frequencia';
  static const String fieldDiasTratamento = 'dias_tratamento';
  static const String fieldObservacoes = 'observacoes';
  static const String fieldAtivo = 'ativo';

  // Campos de horários de alarmes
  static const String fieldMedicamentoId = 'medicamento_id';
  static const String fieldHorario = 'horario';

  // Campos de histórico
  static const String fieldHorarioPrevisto = 'horario_previsto';
  static const String fieldHorarioTomado = 'horario_tomado';
  static const String fieldStatus = 'status';
  static const String fieldDataDose = 'data_dose';

  // Status de doses
  static const String statusTomado = 'tomado';
  static const String statusPulado = 'pulado';
  static const String statusAdiado = 'adiado';
  static const String statusPendente = 'pendente';

  // Tipos de frequência predefinidos
  static const String freq1xDia = '1x ao dia';
  static const String freq2xDia = '2x ao dia';
  static const String freq3xDia = '3x ao dia';
  static const String freq4xDia = '4x ao dia';
  static const String freq6xDia = '6x ao dia';
  static const String freqCustomizada = 'customizada';
}
