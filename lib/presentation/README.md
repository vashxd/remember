# Presentation

## Propósito
Camada de apresentação (UI/UX). Contém telas, widgets e componentes visuais da aplicação.

## Estrutura

### components/
Componentes reutilizáveis seguindo Atomic Design

#### atoms/
Elementos básicos da interface
- **botao_primario.dart**: Botão principal da aplicação
- **botao_secundario.dart**: Botão secundário
- **campo_texto.dart**: Campo de texto customizado
- **seletor_horario.dart**: Seletor de horário
- **icone_medicamento.dart**: Ícone de medicamento
- **badge_status.dart**: Badge de status (tomado/pendente/pulado)

#### molecules/
Combinação de átomos
- **card_medicamento.dart**: Card que exibe um medicamento
- **item_horario.dart**: Item de horário na lista
- **formulario_dosagem.dart**: Formulário de dosagem
- **seletor_frequencia.dart**: Seletor de frequência predefinida

#### organisms/
Seções completas
- **lista_medicamentos.dart**: Lista completa de medicamentos
- **calendario_medicacao.dart**: Calendário visual de medicações
- **formulario_medicamento.dart**: Formulário completo de cadastro

### screens/
Telas da aplicação
- **home_screen.dart**: Tela principal com lista de medicamentos
- **adicionar_medicamento_screen.dart**: Tela de cadastro (Stepper)
- **detalhes_medicamento_screen.dart**: Detalhes e edição
- **historico_screen.dart**: Histórico de medicações
- **configuracoes_screen.dart**: Configurações do app

### widgets/
Widgets específicos (não reutilizáveis)
- **empty_state.dart**: Estado vazio
- **loading_indicator.dart**: Indicador de carregamento

## Arquivos

### components/atoms/botao_primario.dart
- **Propósito**: Botão primário consistente em toda aplicação
- **Props**: `texto`, `onPressed`, `icone?`, `loading?`
- **Estilo**: Segue tema (cores, fontes grandes)
- **Acessibilidade**: Semantics, tamanho mínimo 48x48dp

### screens/home_screen.dart
- **Propósito**: Tela principal do app
- **Componentes**: AppBar, ListView, FloatingActionButton
- **Estado**: Lista de medicamentos (Provider)
- **Navegação**: Para AdicionarMedicamento, Detalhes, Configurações

### screens/adicionar_medicamento_screen.dart
- **Propósito**: Cadastro de novo medicamento
- **Componentes**: Stepper (3 passos)
- **Passos**:
  1. Nome e dosagem
  2. Frequência e primeiro horário
  3. Confirmação com preview de horários
- **Validação**: Em cada passo antes de avançar

## Padrões Específicos

### Atomic Design

```
Átomo → Molécula → Organismo → Template → Página

Botão  → Card      → Lista      → Layout  → Home
```

### Componentes Reutilizáveis

```dart
class BotaoPrimario extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final IconData? icone;
  final bool loading;

  const BotaoPrimario({
    Key? key,
    required this.texto,
    required this.onPressed,
    this.icone,
    this.loading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(20),
        textStyle: TextStyle(fontSize: 20),
        minimumSize: Size(double.infinity, 60),
      ),
      child: loading
        ? CircularProgressIndicator()
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icone != null) Icon(icone),
              if (icone != null) SizedBox(width: 8),
              Text(texto),
            ],
          ),
    );
  }
}
```

### Gerenciamento de Estado

```dart
class HomeScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MedicamentoProvider>(
      builder: (context, provider, child) {
        if (provider.loading) {
          return LoadingIndicator();
        }

        if (provider.medicamentos.isEmpty) {
          return EmptyState(
            mensagem: 'Nenhum medicamento cadastrado',
            acao: () => navegarParaAdicionar(),
          );
        }

        return ListView.builder(
          itemCount: provider.medicamentos.length,
          itemBuilder: (context, index) {
            return CardMedicamento(
              medicamento: provider.medicamentos[index],
            );
          },
        );
      },
    );
  }
}
```

### Navegação

```dart
// Navegação com retorno
final resultado = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AdicionarMedicamentoScreen(),
  ),
);

// Navegação nomeada (rotas)
Navigator.pushNamed(context, '/configuracoes');
```

### Validação de Formulários

```dart
final _formKey = GlobalKey<FormState>();

TextFormField(
  validator: (value) => validarNomeMedicamento(value),
  decoration: InputDecoration(
    labelText: 'Nome do Medicamento',
    hintText: 'Ex: Losartana',
  ),
);

// Ao submeter
if (_formKey.currentState!.validate()) {
  _formKey.currentState!.save();
  salvarMedicamento();
}
```

## Acessibilidade

### Diretrizes
1. **Tamanho mínimo de toque**: 48x48 dp
2. **Contraste**: WCAG AA (4.5:1 para texto normal)
3. **Fontes**: Mínimo 18sp, ajustáveis
4. **Semantics**: Todos os elementos interativos

```dart
Semantics(
  label: 'Adicionar medicamento',
  button: true,
  child: FloatingActionButton(
    onPressed: () => ...,
    child: Icon(Icons.add),
  ),
);
```

### Modo Idoso
- Fontes maiores por padrão
- Botões grandes e espaçados
- Cores de alto contraste
- Ícones descritivos
- Textos simples e diretos

## Responsividade

```dart
// Usar MediaQuery para adaptar layout
final tamanhoTela = MediaQuery.of(context).size;
final largura = tamanhoTela.width;

// Adaptar padding
final padding = largura > 600 ? 32.0 : 16.0;

// Adaptar grid
final colunas = largura > 600 ? 2 : 1;
```

## Tratamento de Erros

```dart
try {
  await provider.salvarMedicamento(medicamento);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Medicamento salvo com sucesso')),
  );
  Navigator.pop(context);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Erro ao salvar: ${e.toString()}'),
      backgroundColor: Colors.red,
    ),
  );
}
```

## Tema

```dart
// Aplicar tema consistente
Theme.of(context).colorScheme.primary
Theme.of(context).textTheme.headlineMedium
```

## Performance

### Otimizações
1. **const** em widgets estáticos
2. **ListView.builder** para listas longas
3. **AutomaticKeepAliveClientMixin** quando necessário
4. Evitar rebuilds desnecessários

```dart
// Widget constante
const Text('Texto fixo');

// Lista eficiente
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
);
```

## Exemplo de Fluxo

```
HomeScreen
  ↓ (FAB)
AdicionarMedicamentoScreen
  ↓ (Passo 1: Nome/Dosagem)
  ↓ (Passo 2: Frequência/Horário)
  ↓ (Passo 3: Confirmação)
  ↓ (Salvar)
← HomeScreen (atualizada)
```

## Dependências
- domain/services
- domain/calculators
- data/models
- core (themes, constants, utils)
- provider (gerenciamento de estado)

## Usado Por
- main.dart (ponto de entrada)
