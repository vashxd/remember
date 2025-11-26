/// Tela de Adicionar Medicamento
///
/// Fluxo simplificado com 3 passos:
/// 1. Informações básicas (nome e dosagem)
/// 2. Frequência e primeiro horário
/// 3. Confirmação com preview dos horários calculados
///
/// Autor: Sistema
/// Data: 2025-11-26
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/medicamento.dart';
import '../../../data/models/horario_alarme.dart';
import '../../../domain/calculators/calculadora_horarios.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/medicamento_provider.dart';
import '../../components/atoms/botao_primario.dart';
import '../../components/atoms/botao_secundario.dart';
import '../../components/atoms/campo_texto.dart';

class AdicionarMedicamentoPage extends StatefulWidget {
  const AdicionarMedicamentoPage({super.key});

  @override
  State<AdicionarMedicamentoPage> createState() =>
      _AdicionarMedicamentoPageState();
}

class _AdicionarMedicamentoPageState extends State<AdicionarMedicamentoPage> {
  // Stepper
  int _currentStep = 0;

  // Form keys
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  // Controllers
  final _nomeController = TextEditingController();
  final _dosagemController = TextEditingController();
  final _observacoesController = TextEditingController();
  final _diasTratamentoController = TextEditingController(text: '30');

  // Dados do medicamento
  String? _tipoFrequencia = '2x ao dia';
  TimeOfDay _primeiroHorario = const TimeOfDay(hour: 8, minute: 0);
  List<TimeOfDay> _horariosCalculados = [];
  bool _evitarMadrugada = false;

  // Campos customizados
  int? _intervaloCustomizado;
  int? _qtdDosesCustomizada;

  @override
  void initState() {
    super.initState();
    _calcularHorarios();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dosagemController.dispose();
    _observacoesController.dispose();
    _diasTratamentoController.dispose();
    super.dispose();
  }

  /// Calcula os horários automaticamente
  void _calcularHorarios() {
    setState(() {
      if (_tipoFrequencia == 'customizada') {
        if (_intervaloCustomizado != null && _qtdDosesCustomizada != null) {
          _horariosCalculados = CalculadoraHorarios.calcular(
            primeiroHorario: _primeiroHorario,
            intervalo: _intervaloCustomizado,
            qtdDoses: _qtdDosesCustomizada,
          );
        }
      } else {
        _horariosCalculados = CalculadoraHorarios.calcular(
          primeiroHorario: _primeiroHorario,
          frequencia: _tipoFrequencia,
        );
      }

      // Ajustar para período ativo se necessário
      if (_evitarMadrugada) {
        _horariosCalculados = CalculadoraHorarios.ajustarParaPeriodoAtivo(
          _horariosCalculados,
        );
      }
    });
  }

  /// Valida e avança para o próximo passo
  void _proximoPasso() {
    if (_currentStep == 0) {
      if (_formKey1.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_formKey2.currentState!.validate()) {
        _calcularHorarios();
        setState(() => _currentStep++);
      }
    } else {
      _salvarMedicamento();
    }
  }

  /// Volta para o passo anterior
  void _voltarPasso() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  /// Salva o medicamento
  Future<void> _salvarMedicamento() async {
    try {
      final medicamento = Medicamento(
        nome: _nomeController.text.trim(),
        dosagem: _dosagemController.text.trim(),
        primeiroHorario: _primeiroHorario,
        tipoFrequencia: _tipoFrequencia,
        intervaloHoras: _intervaloCustomizado,
        qtdDosesDia: _qtdDosesCustomizada,
        diasTratamento: int.parse(_diasTratamentoController.text),
        observacoes: _observacoesController.text.trim().isEmpty
            ? null
            : _observacoesController.text.trim(),
      );

      // Salvar via provider
      final provider = context.read<MedicamentoProvider>();
      await provider.adicionarMedicamento(medicamento, _horariosCalculados);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicamento adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar medicamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Medicamento'),
        elevation: 0,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _proximoPasso,
        onStepCancel: _currentStep > 0 ? _voltarPasso : null,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: BotaoPrimario(
                    texto: _currentStep == 2 ? 'Salvar' : 'Próximo',
                    onPressed: details.onStepContinue!,
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: BotaoSecundario(
                      texto: 'Voltar',
                      onPressed: details.onStepCancel!,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          _buildPasso1(),
          _buildPasso2(),
          _buildPasso3(),
        ],
      ),
    );
  }

  /// Passo 1: Informações Básicas
  Step _buildPasso1() {
    return Step(
      title: const Text('Medicamento', style: TextStyle(fontSize: 18)),
      subtitle: const Text('Nome e dosagem'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CampoTexto(
              controlador: _nomeController,
              rotulo: 'Nome do Medicamento',
              dica: 'Ex: Losartana',
              iconePrefixo: Icons.medication,
              validador: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Digite o nome do medicamento';
                }
                if (valor.trim().length < 2) {
                  return 'Nome muito curto';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CampoTexto(
              controlador: _dosagemController,
              rotulo: 'Dosagem',
              dica: 'Ex: 50mg',
              iconePrefixo: Icons.science,
              validador: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Digite a dosagem';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CampoTexto(
              controlador: _diasTratamentoController,
              rotulo: 'Dias de Tratamento',
              dica: 'Ex: 30',
              iconePrefixo: Icons.calendar_today,
              tipoTeclado: TextInputType.number,
              validador: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Digite os dias de tratamento';
                }
                final dias = int.tryParse(valor);
                if (dias == null || dias < 1) {
                  return 'Digite um número válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Passo 2: Frequência e Horários
  Step _buildPasso2() {
    return Step(
      title: const Text('Horários', style: TextStyle(fontSize: 18)),
      subtitle: const Text('Quando tomar'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seletor de Frequência
            DropdownButtonFormField<String>(
              value: _tipoFrequencia,
              decoration: const InputDecoration(
                labelText: 'Quantas vezes por dia?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.repeat),
              ),
              items: AppConstants.frequenciasPredefinidas.map((freq) {
                final intervalo = AppConstants.intervalosPredefinidos[freq];
                final descricao = intervalo != null
                    ? '$freq (a cada $intervalo horas)'
                    : freq;
                return DropdownMenuItem(
                  value: freq,
                  child: Text(descricao),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _tipoFrequencia = value;
                  _calcularHorarios();
                });
              },
            ),
            const SizedBox(height: 16),

            // Se escolheu personalizado
            if (_tipoFrequencia == 'customizada') ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Intervalo (horas)',
                        border: OutlineInputBorder(),
                        hintText: 'Ex: 6',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _intervaloCustomizado = int.tryParse(value);
                        _calcularHorarios();
                      },
                      validator: (value) {
                        if (_tipoFrequencia == 'customizada') {
                          if (value == null || value.isEmpty) {
                            return 'Digite o intervalo';
                          }
                          final intervalo = int.tryParse(value);
                          if (intervalo == null ||
                              intervalo < 1 ||
                              intervalo > 24) {
                            return 'Entre 1 e 24';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Doses/dia',
                        border: OutlineInputBorder(),
                        hintText: 'Ex: 3',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _qtdDosesCustomizada = int.tryParse(value);
                        _calcularHorarios();
                      },
                      validator: (value) {
                        if (_tipoFrequencia == 'customizada') {
                          if (value == null || value.isEmpty) {
                            return 'Digite a qtd';
                          }
                          final qtd = int.tryParse(value);
                          if (qtd == null || qtd < 1 || qtd > 24) {
                            return 'Entre 1 e 24';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Seletor de Horário Inicial
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Colors.blue),
                title: const Text('Primeiro horário'),
                subtitle:
                    Text(_primeiroHorario.format(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _primeiroHorario,
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          alwaysUse24HourFormat: false,
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _primeiroHorario = picked;
                      _calcularHorarios();
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 8),

            // Switch para evitar madrugada
            SwitchListTile(
              title: const Text('Evitar horários de madrugada'),
              subtitle: const Text('Redistribui entre 7h e 22h'),
              value: _evitarMadrugada,
              onChanged: (value) {
                setState(() {
                  _evitarMadrugada = value;
                  _calcularHorarios();
                });
              },
            ),

            const SizedBox(height: 16),

            // Observações
            CampoTexto(
              controlador: _observacoesController,
              rotulo: 'Observações (opcional)',
              dica: 'Ex: Tomar com alimentos',
              iconePrefixo: Icons.notes,
              maxLinhas: 3,
            ),
          ],
        ),
      ),
    );
  }

  /// Passo 3: Confirmação
  Step _buildPasso3() {
    return Step(
      title: const Text('Confirmar', style: TextStyle(fontSize: 18)),
      subtitle: const Text('Revisar informações'),
      isActive: _currentStep >= 2,
      state: StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumo do medicamento
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medication, color: Colors.blue, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nomeController.text,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _dosagemController.text,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 8),
                      Text('${_diasTratamentoController.text} dias de tratamento'),
                    ],
                  ),
                  if (_observacoesController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.notes, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_observacoesController.text),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Título dos horários
          const Text(
            'Lembretes serão criados para:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Lista de horários calculados
          ..._horariosCalculados.map((horario) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.alarm, color: Colors.blue, size: 28),
                title: Text(
                  horario.format(context),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  _obterPeriodoDoDia(horario),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Aviso se houver horário na madrugada
          if (CalculadoraHorarios.temHorarioNaMadrugada(_horariosCalculados) &&
              !_evitarMadrugada)
            Card(
              color: Colors.orange.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Alguns horários são de madrugada. Volte e ative "Evitar madrugada" se preferir.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Retorna descrição do período do dia
  String _obterPeriodoDoDia(TimeOfDay horario) {
    if (horario.hour >= 6 && horario.hour < 12) {
      return 'Manhã';
    } else if (horario.hour >= 12 && horario.hour < 18) {
      return 'Tarde';
    } else if (horario.hour >= 18 && horario.hour < 22) {
      return 'Noite';
    } else {
      return 'Madrugada';
    }
  }
}
