/// Validadores de entrada da aplicação
///
/// Fornece funções de validação para garantir integridade dos dados.
/// Todas as funções retornam String? (null = válido, String = mensagem de erro).
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

import '../constants/app_constants.dart';

class Validators {
  /// Valida nome de medicamento
  ///
  /// [value] Nome do medicamento a validar
  ///
  /// Returns: null se válido, mensagem de erro se inválido
  static String? validarNomeMedicamento(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome do medicamento é obrigatório';
    }

    final nome = value.trim();

    if (nome.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }

    if (nome.length > AppConstants.maxNomeLength) {
      return 'Nome muito longo (máximo ${AppConstants.maxNomeLength} caracteres)';
    }

    // Verifica caracteres potencialmente perigosos
    if (nome.contains(RegExp(r'[<>"' "'" r'\\]'))) {
      return 'Nome contém caracteres não permitidos';
    }

    return null;
  }

  /// Valida dosagem do medicamento
  ///
  /// [value] Dosagem a validar
  ///
  /// Returns: null se válido, mensagem de erro se inválido
  static String? validarDosagem(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Dosagem é obrigatória';
    }

    final dosagem = value.trim();

    if (dosagem.length > AppConstants.maxDosagemLength) {
      return 'Dosagem muito longa (máximo ${AppConstants.maxDosagemLength} caracteres)';
    }

    // Verifica caracteres potencialmente perigosos
    if (dosagem.contains(RegExp(r'[<>"' "'" r'\\]'))) {
      return 'Dosagem contém caracteres não permitidos';
    }

    return null;
  }

  /// Valida intervalo entre doses em horas
  ///
  /// [intervalo] Intervalo em horas
  ///
  /// Returns: null se válido, mensagem de erro se inválido
  static String? validarIntervaloHoras(int? intervalo) {
    if (intervalo == null) {
      return 'Intervalo é obrigatório';
    }

    if (intervalo < AppConstants.minIntervaloHoras) {
      return 'Intervalo mínimo é ${AppConstants.minIntervaloHoras} hora';
    }

    if (intervalo > AppConstants.maxIntervaloHoras) {
      return 'Intervalo máximo é ${AppConstants.maxIntervaloHoras} horas';
    }

    return null;
  }

  /// Valida quantidade de doses por dia
  ///
  /// [qtdDoses] Quantidade de doses
  ///
  /// Returns: null se válido, mensagem de erro se inválido
  static String? validarQtdDoses(int? qtdDoses) {
    if (qtdDoses == null) {
      return 'Quantidade de doses é obrigatória';
    }

    if (qtdDoses < AppConstants.minDosesPorDia) {
      return 'Mínimo de ${AppConstants.minDosesPorDia} dose por dia';
    }

    if (qtdDoses > AppConstants.maxDosesPorDia) {
      return 'Máximo de ${AppConstants.maxDosesPorDia} doses por dia';
    }

    return null;
  }

  /// Valida dias de tratamento
  ///
  /// [dias] Número de dias
  ///
  /// Returns: null se válido, mensagem de erro se inválido
  static String? validarDiasTratamento(int? dias) {
    if (dias == null) {
      return 'Dias de tratamento é obrigatório';
    }

    if (dias < AppConstants.minDiasTratamento) {
      return 'Mínimo de ${AppConstants.minDiasTratamento} dia';
    }

    if (dias > AppConstants.maxDiasTratamento) {
      return 'Máximo de ${AppConstants.maxDiasTratamento} dias';
    }

    return null;
  }

  /// Valida observações
  ///
  /// [value] Texto das observações
  ///
  /// Returns: null se válido, mensagem de erro se inválido
  static String? validarObservacoes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Observações são opcionais
    }

    final observacoes = value.trim();

    if (observacoes.length > AppConstants.maxObservacoesLength) {
      return 'Observações muito longas (máximo ${AppConstants.maxObservacoesLength} caracteres)';
    }

    // Verifica caracteres potencialmente perigosos
    if (observacoes.contains(RegExp(r'[<>"' "'" r'\\]'))) {
      return 'Observações contêm caracteres não permitidos';
    }

    return null;
  }

  /// Sanitiza string removendo caracteres perigosos
  ///
  /// [value] String a sanitizar
  ///
  /// Returns: String sanitizada
  static String sanitizeString(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'[<>"' "'" r'\\]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Valida se string é um número inteiro positivo
  ///
  /// [value] String a validar
  ///
  /// Returns: null se válido, mensagem de erro se inválido
  static String? validarNumeroPositivo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    final numero = int.tryParse(value.trim());

    if (numero == null) {
      return 'Digite um número válido';
    }

    if (numero <= 0) {
      return 'Número deve ser maior que zero';
    }

    return null;
  }
}
