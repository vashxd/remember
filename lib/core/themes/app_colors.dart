/// Paleta de cores da aplicação
///
/// Cores com alto contraste para acessibilidade (WCAG AA compliance).
/// Especialmente projetadas para facilitar visualização por idosos.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

import 'package:flutter/material.dart';

class AppColors {
  // Cores primárias (alto contraste)
  static const Color primary = Color(0xFF2196F3); // Azul suave
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Cores de fundo
  static const Color background = Color(0xFFFFFFFF); // Branco puro
  static const Color surface = Color(0xFFF5F5F5); // Cinza muito claro
  static const Color surfaceDark = Color(0xFFE0E0E0);

  // Cores de texto (máximo contraste)
  static const Color textPrimary = Color(0xFF000000); // Preto puro
  static const Color textSecondary = Color(0xFF424242); // Cinza escuro
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Branco para fundo azul

  // Cores de status
  static const Color success = Color(0xFF4CAF50); // Verde (dose tomada)
  static const Color warning = Color(0xFFFF9800); // Laranja (dose atrasada)
  static const Color error = Color(0xFFF44336); // Vermelho (dose pulada)
  static const Color info = Color(0xFF2196F3); // Azul (informação)
  static const Color pending = Color(0xFF9E9E9E); // Cinza (pendente)

  // Cores de ação
  static const Color successLight = Color(0xFF81C784);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color errorLight = Color(0xFFE57373);

  // Bordas e divisores
  static const Color divider = Color(0xFFBDBDBD);
  static const Color border = Color(0xFF9E9E9E);

  // Sombras
  static const Color shadow = Color(0x40000000);

  // Cores específicas do app
  static const Color medicamentoCard = Color(0xFFFFFFFF);
  static const Color horarioCard = Color(0xFFF5F5F5);
}
