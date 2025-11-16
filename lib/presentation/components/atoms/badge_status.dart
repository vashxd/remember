/// Badge de status reutilizável
///
/// Componente atômico para indicar status de doses.
/// Cores de alto contraste para fácil identificação.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

enum TipoStatus {
  tomado,
  pendente,
  atrasado,
  pulado,
}

class BadgeStatus extends StatelessWidget {
  final TipoStatus tipo;
  final String? textoCustomizado;

  const BadgeStatus({
    super.key,
    required this.tipo,
    this.textoCustomizado,
  });

  @override
  Widget build(BuildContext context) {
    final config = _obterConfiguracao();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: config.cor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.cor,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icone,
            size: 18,
            color: config.cor,
          ),
          const SizedBox(width: 6),
          Text(
            textoCustomizado ?? config.texto,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: config.cor,
            ),
          ),
        ],
      ),
    );
  }

  _ConfiguracaoStatus _obterConfiguracao() {
    switch (tipo) {
      case TipoStatus.tomado:
        return _ConfiguracaoStatus(
          cor: AppColors.success,
          icone: Icons.check_circle,
          texto: 'Tomado',
        );
      case TipoStatus.pendente:
        return _ConfiguracaoStatus(
          cor: AppColors.pending,
          icone: Icons.schedule,
          texto: 'Pendente',
        );
      case TipoStatus.atrasado:
        return _ConfiguracaoStatus(
          cor: AppColors.warning,
          icone: Icons.warning,
          texto: 'Atrasado',
        );
      case TipoStatus.pulado:
        return _ConfiguracaoStatus(
          cor: AppColors.error,
          icone: Icons.cancel,
          texto: 'Pulado',
        );
    }
  }
}

class _ConfiguracaoStatus {
  final Color cor;
  final IconData icone;
  final String texto;

  _ConfiguracaoStatus({
    required this.cor,
    required this.icone,
    required this.texto,
  });
}
