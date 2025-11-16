# Domain

## Propósito
Camada de lógica de negócio. Contém algoritmos, calculadoras e serviços que implementam as regras de negócio da aplicação.

## Estrutura

### calculators/
Algoritmos de cálculo
- **calculadora_horarios.dart**: Calcula horários baseado em frequência/intervalo
- **calculadora_estoque.dart**: Calcula quando acabará o medicamento

### services/
Serviços de negócio
- **gerenciador_alarmes.dart**: Gerencia criação e cancelamento de alarmes
- **gerenciador_notificacoes.dart**: Gerencia notificações locais
- **historico_service.dart**: Lógica de registro de histórico
- **medicamento_service.dart**: Lógica de negócio de medicamentos

## Arquivos

### calculadora_horarios.dart
- **Propósito**: Calcular horários de doses automaticamente
- **Algoritmo central**: Baseado no primeiro horário, calcula demais
- **Principais métodos**:
  - `calcular()`: Método principal de cálculo
  - `calcularPorFrequencia()`: Cálculo por frequência predefinida
  - `calcularPorIntervalo()`: Cálculo por intervalo customizado
  - `ajustarParaPeriodoAtivo()`: Evita horários de madrugada
- **Dependências**: core/constants
- **Usado por**: presentation/screens, services

### gerenciador_alarmes.dart
- **Propósito**: Gerenciar alarmes do sistema
- **Principais métodos**:
  - `configurarAlarmes()`: Criar alarmes para medicamento
  - `criarAlarmeRecorrente()`: Criar alarme individual
  - `cancelarAlarme()`: Cancelar alarme específico
  - `reagendarAlarme()`: Reagendar para próxima ocorrência
  - `confirmarDoseTomada()`: Registrar dose e reagendar
  - `adiarAlarme()`: Soneca de X minutos
- **Dependências**: flutter_local_notifications, data/models
- **Usado por**: presentation/screens

## Padrões Específicos

### Calculadoras
- Métodos estáticos (sem estado)
- Entrada: parâmetros nomeados
- Saída: tipos imutáveis
- Sem efeitos colaterais

```dart
class CalculadoraHorarios {
  // Sem construtor (apenas métodos estáticos)

  static List<TimeOfDay> calcular({
    required TimeOfDay primeiroHorario,
    String? frequencia,
    int? intervalo,
    int? qtdDoses,
  }) {
    // Lógica pura, sem side effects
    return horarios;
  }
}
```

### Serviços
- Singleton ou injetado via Provider
- Métodos assíncronos quando necessário
- Tratamento de erros completo
- Logging de operações importantes

```dart
class GerenciadorAlarmes {
  static final GerenciadorAlarmes _instance = GerenciadorAlarmes._internal();
  factory GerenciadorAlarmes() => _instance;
  GerenciadorAlarmes._internal();

  Future<void> configurarAlarmes(Medicamento med) async {
    try {
      // Lógica
      logger.info('Alarmes configurados para ${med.nome}');
    } catch (e, stackTrace) {
      logger.error('Erro ao configurar alarmes', e, stackTrace);
      rethrow;
    }
  }
}
```

## Regras de Negócio Implementadas

### Cálculo de Horários
1. Frequência predefinida (1x, 2x, 3x, 4x, 6x ao dia)
2. Intervalo customizado (ex: 5 em 5 horas)
3. Ajuste para evitar madrugada (7h às 22h)
4. Validação de conflitos de horários

### Alarmes
1. Criar alarmes para cada horário calculado
2. Reagendar automaticamente após disparo
3. Soneca de 10 minutos (configurável)
4. Persistência após reinicialização do dispositivo

### Histórico
1. Registrar quando dose foi tomada
2. Registrar quando dose foi pulada
3. Registrar quando dose foi adiada
4. Calcular taxa de adesão ao tratamento

## Testes

Camada crítica - 100% de cobertura recomendada

```dart
group('CalculadoraHorarios', () {
  test('Deve calcular 3 doses corretamente', () {
    final horarios = CalculadoraHorarios.calcular(
      primeiroHorario: TimeOfDay(hour: 8, minute: 0),
      frequencia: '3x ao dia',
    );

    expect(horarios.length, 3);
    expect(horarios[0].hour, 8);
    expect(horarios[1].hour, 16);
    expect(horarios[2].hour, 0);
  });
});
```

## Segurança

### Validações
- Validar todos os parâmetros de entrada
- Lançar exceções descritivas para entradas inválidas
- Não permitir valores absurdos (ex: 100 doses por dia)

```dart
static List<TimeOfDay> calcular({required TimeOfDay primeiroHorario, ...}) {
  if (intervalo != null && (intervalo < 1 || intervalo > 24)) {
    throw ArgumentError('Intervalo deve estar entre 1 e 24 horas');
  }

  if (qtdDoses != null && (qtdDoses < 1 || qtdDoses > 24)) {
    throw ArgumentError('Quantidade de doses deve estar entre 1 e 24');
  }

  // Continua...
}
```

## Exemplo de Uso

```dart
// Calcular horários
final horarios = CalculadoraHorarios.calcular(
  primeiroHorario: TimeOfDay(hour: 8, minute: 0),
  frequencia: '3x ao dia',
);

// Criar alarmes
final gerenciador = GerenciadorAlarmes();
await gerenciador.configurarAlarmes(medicamento);

// Confirmar dose tomada
await gerenciador.confirmarDoseTomada(alarmId);
```

## Dependências
- data/models (modelos)
- data/database (persistência)
- core (constantes e utils)
- flutter_local_notifications

## Usado Por
- presentation/screens
- presentation/widgets
