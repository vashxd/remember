/// Tela principal (Home)
///
/// Página que exibe a lista de medicamentos cadastrados.
/// Integra com Provider para gerenciar estado.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/models.dart';
import '../../providers/medicamento_provider.dart';
import '../../components/molecules/molecules.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Carrega medicamentos ao iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicamentoProvider>().carregarMedicamentos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Medicamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _abrirConfiguracoes,
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: Consumer<MedicamentoProvider>(
        builder: (context, provider, child) {
          // Estado de loading
          if (provider.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(strokeWidth: 3),
                  SizedBox(height: 24),
                  Text(
                    'Carregando medicamentos...',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          // Estado de erro
          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Erro ao carregar medicamentos',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.error!,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.carregarMedicamentos();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Estado vazio
          if (!provider.temMedicamentos) {
            return _buildEstadoVazio(context);
          }

          // Lista de medicamentos
          return RefreshIndicator(
            onRefresh: () => provider.carregarMedicamentos(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: provider.medicamentos.length,
              itemBuilder: (context, index) {
                final medicamento = provider.medicamentos[index];
                return FutureBuilder<List<HorarioAlarme>>(
                  future: provider.buscarHorarios(medicamento.id!),
                  builder: (context, snapshot) {
                    final horarios = snapshot.data ?? [];

                    return CardMedicamento(
                      medicamento: medicamento,
                      horarios: horarios,
                      aoClicar: () => _abrirDetalhesMedicamento(medicamento),
                      aoEditar: () => _editarMedicamento(medicamento),
                      aoExcluir: () => _confirmarExclusao(medicamento),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarMedicamento,
        label: const Text('Adicionar Medicamento'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEstadoVazio(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 32),
            Text(
              'Nenhum medicamento cadastrado',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Toque no botão abaixo para adicionar\nseu primeiro medicamento',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Icon(
              Icons.arrow_downward,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _adicionarMedicamento() {
    // TODO: Navegar para tela de adicionar medicamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tela de adicionar medicamento em desenvolvimento'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _abrirDetalhesMedicamento(Medicamento medicamento) {
    // TODO: Navegar para tela de detalhes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detalhes de ${medicamento.nome}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _editarMedicamento(Medicamento medicamento) {
    // TODO: Navegar para tela de edição
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar ${medicamento.nome}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _confirmarExclusao(Medicamento medicamento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o medicamento "${medicamento.nome}"?\n\n'
          'Esta ação não pode ser desfeita e todos os horários e histórico '
          'serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      final sucesso = await context
          .read<MedicamentoProvider>()
          .removerMedicamento(medicamento.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sucesso
                  ? 'Medicamento excluído com sucesso'
                  : 'Erro ao excluir medicamento',
            ),
            backgroundColor: sucesso ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  void _abrirConfiguracoes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configurações em desenvolvimento'),
      ),
    );
  }
}
