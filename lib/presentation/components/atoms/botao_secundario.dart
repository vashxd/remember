/// Botão secundário reutilizável
///
/// Componente atômico para botões de ação secundária ou cancelamento.
/// Usa outline style para diferenciar do botão primário.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

import 'package:flutter/material.dart';

class BotaoSecundario extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final IconData? icone;
  final bool loading;
  final bool larguraTotal;
  final double? larguraMinima;
  final double? alturaMinima;

  const BotaoSecundario({
    super.key,
    required this.texto,
    this.onPressed,
    this.icone,
    this.loading = false,
    this.larguraTotal = true,
    this.larguraMinima,
    this.alturaMinima = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: larguraTotal ? double.infinity : larguraMinima,
      height: alturaMinima,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : icone != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icone, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        texto,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    texto,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
      ),
    );
  }
}
