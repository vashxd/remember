# Guia de Desenvolvimento - Lembrete de Medicamentos

## Princípios de Desenvolvimento

### 1. Boas Práticas de Programação
- **DRY (Don't Repeat Yourself)**: Evitar duplicação de código através de componentes reutilizáveis
- **SOLID**: Aplicar princípios de orientação a objetos
- **Clean Code**: Código limpo, legível e bem documentado
- **Modularização**: Separar responsabilidades em módulos distintos
- **Componentização**: Criar widgets reutilizáveis para toda a aplicação

### 2. Segurança
- **Validação de Dados**: Validar todas as entradas do usuário
- **Sanitização**: Limpar dados antes de armazenar no banco
- **Criptografia**: Dados sensíveis devem ser criptografados no SQLite
- **Permissões**: Solicitar apenas permissões necessárias
- **Offline First**: Dados armazenados apenas localmente, sem exposição externa

### 3. Arquitetura do Projeto

```
lib/
├── core/                  # Núcleo da aplicação
│   ├── constants/         # Constantes globais
│   ├── themes/            # Temas e estilos
│   └── utils/             # Utilitários gerais
├── data/                  # Camada de dados
│   ├── database/          # SQLite e helpers
│   └── models/            # Modelos de dados
├── domain/                # Lógica de negócio
│   ├── calculators/       # Calculadoras de horários
│   └── services/          # Serviços (alarmes, notificações)
├── presentation/          # Camada de apresentação
│   ├── components/        # Componentes reutilizáveis
│   ├── screens/           # Telas da aplicação
│   └── widgets/           # Widgets específicos
└── main.dart              # Ponto de entrada
```

### 4. Padrão de Nomenclatura
- **Arquivos**: snake_case (ex: `calculadora_horarios.dart`)
- **Classes**: PascalCase (ex: `CalculadoraHorarios`)
- **Variáveis/Funções**: camelCase (ex: `calcularHorarios`)
- **Constantes**: UPPER_SNAKE_CASE (ex: `MAX_DOSES_DIA`)
- **Widgets**: PascalCase com sufixo descritivo (ex: `CardMedicamento`, `BotaoPrimario`)

### 5. Documentação de Código
Cada arquivo deve conter:
```dart
/// Descrição breve do arquivo
///
/// Descrição detalhada da funcionalidade,
/// casos de uso e exemplos quando necessário.
///
/// Autor: [Nome]
/// Data: [Data de criação]
```

Cada classe/método público deve ter:
```dart
/// Descrição do que a função faz
///
/// [parametro1] Descrição do parâmetro
/// [parametro2] Descrição do parâmetro
///
/// Returns: Descrição do retorno
///
/// Throws: Exceções que podem ser lançadas
///
/// Example:
/// ```dart
/// final resultado = minhaFuncao(param1, param2);
/// ```
```

### 6. Controle de Versão
- **Commits**: Mensagens claras e descritivas em português
- **Formato**: `tipo(escopo): descrição`
  - `feat`: Nova funcionalidade
  - `fix`: Correção de bug
  - `docs`: Documentação
  - `refactor`: Refatoração
  - `test`: Testes
  - `chore`: Tarefas gerais

Exemplo: `feat(alarmes): implementar cálculo automático de horários`

### 7. Testes
- Cobertura mínima de 80% para lógica de negócio
- Testes unitários para todas as calculadoras e serviços
- Testes de widget para componentes reutilizáveis
- Testes de integração para fluxos principais

### 8. Componentização

#### Componentes Básicos (Atomic Design)
1. **Átomos**: Elementos básicos
   - `BotaoPrimario`, `BotaoSecundario`
   - `CampoTexto`, `SeletorHorario`
   - `IconeMedicamento`, `BadgeStatus`

2. **Moléculas**: Combinação de átomos
   - `CardMedicamento`, `ItemHorario`
   - `FormularioDosagem`, `SeletorFrequencia`

3. **Organismos**: Seções completas
   - `ListaMedicamentos`, `CalendarioMedicacao`
   - `FormularioMedicamento`

4. **Templates**: Estruturas de página
   - `LayoutPrincipal`, `LayoutFormulario`

5. **Pages**: Páginas completas
   - `HomeScreen`, `AdicionarMedicamentoScreen`

### 9. Gerenciamento de Estado
- **Provider**: Para estado global da aplicação
- **StatefulWidget**: Para estado local de componentes
- **ChangeNotifier**: Para notificar mudanças nos modelos

### 10. Tratamento de Erros
```dart
try {
  // Operação
} on TipoErroEspecifico catch (e) {
  // Tratamento específico
  logger.error('Erro específico: $e');
} catch (e, stackTrace) {
  // Tratamento genérico
  logger.error('Erro inesperado: $e', stackTrace);
  // Mostrar mensagem amigável ao usuário
}
```

### 11. Acessibilidade
- Fontes grandes e ajustáveis (mínimo 16sp para texto normal)
- Alto contraste (WCAG AA compliance)
- Suporte a leitores de tela
- Navegação por teclado
- Labels descritivos para todos os elementos interativos

### 12. Performance
- Lazy loading para listas grandes
- Cache de dados quando apropriado
- Otimização de queries no banco de dados
- Debounce em operações de busca
- Evitar rebuilds desnecessários de widgets

### 13. Documentação Contínua
Sempre que criar/modificar uma pasta ou funcionalidade:
1. Atualizar o arquivo `README.md` da pasta correspondente
2. Documentar interfaces públicas
3. Adicionar exemplos de uso quando necessário
4. Manter changelog atualizado

### 14. Checklist de Code Review
Antes de considerar uma funcionalidade completa:
- [ ] Código segue os padrões de nomenclatura
- [ ] Componentes são reutilizáveis
- [ ] Documentação adequada
- [ ] Testes implementados
- [ ] Tratamento de erros adequado
- [ ] Acessibilidade considerada
- [ ] Performance otimizada
- [ ] README da pasta atualizado
- [ ] Sem código duplicado
- [ ] Validação de dados implementada

### 15. Prioridades de Segurança

#### Validação de Entrada
```dart
// Sempre validar antes de usar
String validarNomeMedicamento(String nome) {
  if (nome.trim().isEmpty) {
    throw ValidationException('Nome não pode ser vazio');
  }
  if (nome.length > 100) {
    throw ValidationException('Nome muito longo');
  }
  // Sanitizar caracteres especiais
  return nome.trim().replaceAll(RegExp(r'[<>]'), '');
}
```

#### SQL Injection Prevention
```dart
// SEMPRE usar prepared statements
await db.query(
  'medicamentos',
  where: 'id = ?',
  whereArgs: [id], // Nunca interpolar strings diretamente
);
```

#### Dados Sensíveis
```dart
// Usar encrypt package para dados sensíveis
final encrypted = encrypter.encrypt(sensitiveData);
```

## Estrutura de Documentação de Pastas

Cada pasta deve conter um `README.md` com:
```markdown
# Nome da Pasta

## Propósito
Descrição do que esta pasta contém e sua responsabilidade

## Arquivos
### arquivo1.dart
- **Propósito**: O que este arquivo faz
- **Classes/Funções principais**: Lista das principais exportações
- **Dependências**: Do que depende
- **Usado por**: Quem usa este arquivo

## Padrões Específicos
Padrões de código específicos desta pasta

## Exemplos de Uso
Código de exemplo quando aplicável
```

## Workflow de Desenvolvimento

1. **Planejamento**: Definir a funcionalidade e seus requisitos
2. **Estrutura**: Criar estrutura de pastas e arquivos vazios
3. **Documentação Prévia**: Criar READMEs explicando o que será feito
4. **Implementação**: Desenvolver a funcionalidade
5. **Testes**: Escrever e executar testes
6. **Documentação**: Atualizar documentação com implementação real
7. **Code Review**: Verificar checklist
8. **Commit**: Commit com mensagem descritiva

## Convenções de UI/UX

### Cores (Modo Idoso)
- Texto principal: #000000 (preto puro)
- Background: #FFFFFF (branco puro)
- Destaque: #2196F3 (azul suave)
- Sucesso: #4CAF50 (verde)
- Alerta: #FF9800 (laranja)
- Erro: #F44336 (vermelho)

### Tamanhos de Fonte
- Título: 24sp
- Subtítulo: 20sp
- Corpo: 18sp
- Botões: 20sp

### Espaçamento
- Padding padrão: 16dp
- Padding botões: 20dp
- Margem entre elementos: 12dp

## Observações Finais

- **Prioridade 1**: Funcionalidade confiável (alarmes devem funcionar)
- **Prioridade 2**: Simplicidade de uso (idosos devem entender)
- **Prioridade 3**: Performance (deve ser rápido)
- **Prioridade 4**: Features extras (calendário, relatórios, etc)

Este é um documento vivo que deve ser atualizado conforme o projeto evolui.
