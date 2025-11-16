/// Card de medicamento
///
/// Componente molécula que exibe informações de um medicamento.
/// Mostra nome, dosagem, horários e permite ações.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

import 'package:flutter/material.dart';
import '../../../data/models/models.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_text_styles.dart';

class CardMedicamento extends StatelessWidget {
  final Medicamento medicamento;
  final List<HorarioAlarme> horarios;
  final VoidCallback? aoClicar;
  final VoidCallback? aoEditar;
  final VoidCallback? aoExcluir;

  const CardMedicamento({
    super.key,
    required this.medicamento,
    required this.horarios,
    this.aoClicar,
    this.aoEditar,
    this.aoExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: aoClicar,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho: nome e ações
              Row(
                children: [
                  // Ícone de medicamento
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medication,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Nome e dosagem
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicamento.nome,
                          style: AppTextStyles.medicamentoNome,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medicamento.dosagem,
                          style: AppTextStyles.dosagem,
                        ),
                      ],
                    ),
                  ),

                  // Botões de ação
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 28),
                    onSelected: (value) {
                      if (value == 'editar' && aoEditar != null) {
                        aoEditar!();
                      } else if (value == 'excluir' && aoExcluir != null) {
                        aoExcluir!();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 24),
                            SizedBox(width: 12),
                            Text('Editar', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'excluir',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 24, color: AppColors.error),
                            SizedBox(width: 12),
                            Text(
                              'Excluir',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Frequência
              Row(
                children: [
                  const Icon(
                    Icons.repeat,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _obterTextoFrequencia(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Horários
              if (horarios.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Horários:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: horarios.map((horario) {
                    return _buildChipHorario(horario);
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipHorario(HorarioAlarme horario) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: horario.ativo
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: horario.ativo ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Text(
        _formatarHorario(horario.horario),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: horario.ativo ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }

  String _formatarHorario(TimeOfDay horario) {
    final hora = horario.hour.toString().padLeft(2, '0');
    final minuto = horario.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  String _obterTextoFrequencia() {
    if (medicamento.tipoFrequencia != null) {
      return medicamento.tipoFrequencia!;
    } else if (medicamento.intervaloHoras != null &&
               medicamento.qtdDosesDia != null) {
      return '${medicamento.qtdDosesDia}x ao dia (${medicamento.intervaloHoras}/${medicamento.intervaloHoras}h)';
    }
    return 'Personalizado';
  }
}
