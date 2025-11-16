/// Item de horário
///
/// Componente molécula que exibe um único horário de medicamento.
/// Usado em listas e visualizações detalhadas.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

import 'package:flutter/material.dart';
import '../../../data/models/models.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_text_styles.dart';
import '../atoms/badge_status.dart';

class ItemHorario extends StatelessWidget {
  final HorarioAlarme horario;
  final Medicamento medicamento;
  final HistoricoDose? historico;
  final VoidCallback? aoClicar;
  final bool mostrarMedicamento;
  final bool mostrarStatus;

  const ItemHorario({
    super.key,
    required this.horario,
    required this.medicamento,
    this.historico,
    this.aoClicar,
    this.mostrarMedicamento = false,
    this.mostrarStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: aoClicar,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Horário em destaque
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _obterCorHorario().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _obterCorHorario(),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _formatarHora(),
                      style: AppTextStyles.horario.copyWith(
                        color: _obterCorHorario(),
                      ),
                    ),
                    Text(
                      _formatarMinuto(),
                      style: AppTextStyles.dosagem.copyWith(
                        color: _obterCorHorario(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome do medicamento (se necessário)
                    if (mostrarMedicamento) ...[
                      Text(
                        medicamento.nome,
                        style: AppTextStyles.medicamentoNome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Dosagem
                    Text(
                      medicamento.dosagem,
                      style: AppTextStyles.bodyMedium,
                    ),

                    // Observações (se houver no histórico)
                    if (historico?.observacoes != null &&
                        historico!.observacoes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        historico!.observacoes!,
                        style: AppTextStyles.caption.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Status badge
              if (mostrarStatus && historico != null) ...[
                const SizedBox(width: 12),
                _buildStatusBadge(),
              ],

              // Indicador de ativo/inativo
              if (!horario.ativo) ...[
                const SizedBox(width: 12),
                const Icon(
                  Icons.notifications_off,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = historico!.status;

    switch (status) {
      case 'tomado':
        return const BadgeStatus(tipo: TipoStatus.tomado);
      case 'pulado':
        return const BadgeStatus(tipo: TipoStatus.pulado);
      case 'pendente':
        return const BadgeStatus(tipo: TipoStatus.pendente);
      default:
        return const BadgeStatus(tipo: TipoStatus.atrasado);
    }
  }

  Color _obterCorHorario() {
    if (historico != null) {
      switch (historico!.status) {
        case 'tomado':
          return AppColors.success;
        case 'pulado':
          return AppColors.error;
        case 'pendente':
          return AppColors.pending;
        default:
          return AppColors.warning;
      }
    }
    return horario.ativo ? AppColors.primary : AppColors.textSecondary;
  }

  String _formatarHora() {
    return horario.horario.hour.toString().padLeft(2, '0');
  }

  String _formatarMinuto() {
    return horario.horario.minute.toString().padLeft(2, '0');
  }
}
