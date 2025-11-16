# Core

## Propósito
Contém o núcleo da aplicação: constantes, temas, utilitários e configurações compartilhadas por toda a aplicação.

## Estrutura

### constants/
Constantes globais da aplicação
- **app_constants.dart**: Constantes gerais (limites, valores padrão)
- **app_strings.dart**: Strings e textos da aplicação (i18n futuro)
- **database_constants.dart**: Nomes de tabelas e campos do banco

### themes/
Temas e estilos visuais
- **app_theme.dart**: Tema principal da aplicação
- **app_colors.dart**: Paleta de cores
- **app_text_styles.dart**: Estilos de texto pré-definidos

### utils/
Utilitários e helpers gerais
- **validators.dart**: Validadores de entrada
- **formatters.dart**: Formatadores de data, hora, texto
- **logger.dart**: Sistema de logs

## Padrões Específicos

### Constantes
```dart
// Sempre usar const para valores imutáveis
class AppConstants {
  static const int maxDosesPorDia = 24;
  static const int minIntervaloHoras = 1;
}
```

### Temas
```dart
// Centralizar cores e estilos
class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color textPrimary = Color(0xFF000000);
}
```

### Validadores
```dart
// Sempre retornar String? (null = válido)
String? validarNomeMedicamento(String? valor) {
  if (valor == null || valor.trim().isEmpty) {
    return 'Nome não pode ser vazio';
  }
  return null;
}
```

## Dependências
Nenhuma (não depende de outras camadas)

## Usado Por
Todas as camadas da aplicação
