/// Seletor de horário reutilizável
///
/// Componente atômico para seleção de horários.
/// Interface grande e clara para facilitar uso por idosos.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

import 'package:flutter/material.dart';

class SeletorHorario extends StatelessWidget {
  final String rotulo;
  final TimeOfDay? horarioSelecionado;
  final void Function(TimeOfDay) aoSelecionar;
  final bool obrigatorio;
  final String? mensagemErro;

  const SeletorHorario({
    super.key,
    required this.rotulo,
    required this.horarioSelecionado,
    required this.aoSelecionar,
    this.obrigatorio = false,
    this.mensagemErro,
  });

  @override
  Widget build(BuildContext context) {
    final temErro = obrigatorio && horarioSelecionado == null && mensagemErro != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                rotulo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: temErro
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              if (obrigatorio)
                Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
        ),

        // Botão seletor
        InkWell(
          onTap: () => _selecionarHorario(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: temErro
                    ? Theme.of(context).colorScheme.error
                    : const Color(0xFF9E9E9E),
                width: temErro ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 28,
                  color: horarioSelecionado != null
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                ),
                const SizedBox(width: 16),
                Text(
                  horarioSelecionado != null
                      ? _formatarHorario(horarioSelecionado!)
                      : 'Selecione o horário',
                  style: TextStyle(
                    fontSize: 18,
                    color: horarioSelecionado != null
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Colors.grey[600],
                    fontWeight: horarioSelecionado != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Mensagem de erro
        if (temErro)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 20),
            child: Text(
              mensagemErro!,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _selecionarHorario(BuildContext context) async {
    final horario = await showTimePicker(
      context: context,
      initialTime: horarioSelecionado ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: 'SELECIONE O HORÁRIO',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );

    if (horario != null) {
      aoSelecionar(horario);
    }
  }

  String _formatarHorario(TimeOfDay horario) {
    final hora = horario.hour.toString().padLeft(2, '0');
    final minuto = horario.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }
}
