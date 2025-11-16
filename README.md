# Lembrete de Medicamentos

Aplicativo móvel totalmente gratuito e offline para gerenciamento de lembretes de medicamentos, especialmente desenvolvido para facilitar o uso por idosos.

## Características Principais

- **100% Gratuito**: Sem custos operacionais, sem anúncios
- **Totalmente Offline**: Funciona sem internet
- **Cálculo Automático**: Informa apenas o primeiro horário, o app calcula os demais
- **Interface Simples**: Design pensado para idosos
- **Alarmes Confiáveis**: Funcionam mesmo com app fechado (Android)
- **Privacidade Total**: Dados armazenados apenas no seu dispositivo

## Funcionalidades

### Essenciais
- ✅ Cadastro de medicamentos com dosagem
- ✅ Cálculo automático de horários (8/8h, 12/12h, etc)
- ✅ Alarmes persistentes e confiáveis
- ✅ Histórico de medicações tomadas
- ✅ Modo simplificado para idosos

### Extras
- 📅 Calendário visual de medicações
- 📊 Relatórios em PDF para médicos
- 👨‍⚕️ Modo cuidador (notificar responsável)
- 💊 Lembrete de reabastecimento
- ⚕️ Tratamento de casos especiais (antibióticos, jejum, SOS)

## Stack Tecnológica

- **Framework**: Flutter 3.x
- **Banco de Dados**: SQLite (local)
- **Notificações**: flutter_local_notifications
- **Alarmes**: alarm_manager_plus (Android) / Background Fetch (iOS)
- **Gerenciamento de Estado**: Provider

## Estrutura do Projeto

```
lib/
├── core/               # Núcleo (constantes, temas, utils)
├── data/               # Camada de dados (database, models)
├── domain/             # Lógica de negócio (calculators, services)
└── presentation/       # UI (components, screens, widgets)
```

Para detalhes completos da arquitetura, veja [DEVELOPMENT.md](DEVELOPMENT.md)

## Como Usar

### Adicionar um Medicamento

1. Toque em "Adicionar Medicamento"
2. Digite o nome e dosagem
3. Escolha a frequência (1x, 2x, 3x ao dia ou personalizado)
4. Selecione apenas o primeiro horário
5. O app calcula automaticamente os demais horários
6. Confirme e pronto!

### Exemplo

**Medicamento**: Losartana 50mg
**Frequência**: 2x ao dia
**Primeiro horário**: 08:00

**Horários calculados automaticamente**:
- 08:00 (informado)
- 20:00 (calculado - 12h depois)

## Documentação

- [Guia de Desenvolvimento](DEVELOPMENT.md) - Padrões, boas práticas e arquitetura
- [Especificações Técnicas](orientacoes.md) - Documento original com todas as especificações
- Cada pasta contém seu próprio README explicando sua estrutura

## Requisitos

- Flutter SDK 3.0+
- Dart 3.0+
- Android 6.0+ ou iOS 12.0+

## Instalação para Desenvolvimento

```bash
# Clone o repositório
git clone <repo-url>

# Entre na pasta
cd remember

# Instale as dependências
flutter pub get

# Execute o app
flutter run
```

## Testes

```bash
# Testes unitários
flutter test

# Testes de integração
flutter test integration_test

# Cobertura de testes
flutter test --coverage
```

## Distribuição

### Opções Gratuitas
- **GitHub Releases**: APK direto
- **F-Droid**: Loja open source

### Opção Paga (Recomendada)
- **Google Play Store**: $25 taxa única vitalícia

## Contribuindo

1. Leia o [DEVELOPMENT.md](DEVELOPMENT.md)
2. Siga os padrões estabelecidos
3. Documente suas mudanças
4. Adicione testes
5. Atualize os READMEs correspondentes

## Licença

MIT License - Livre para uso pessoal e comercial

## Princípios

- **Offline First**: Tudo funciona sem internet
- **Zero Custo**: Sem servidores, sem APIs pagas
- **Acessibilidade**: Interface simples e clara
- **Confiabilidade**: Alarmes funcionam sempre
- **Privacidade**: Dados apenas no seu dispositivo

## Roadmap

### Fase 1 - MVP (Em Desenvolvimento)
- [ ] Estrutura básica do projeto
- [ ] Banco de dados SQLite
- [ ] Calculadora de horários
- [ ] Sistema de alarmes
- [ ] Telas principais (Home, Adicionar)

### Fase 2 - Funcionalidades Extras
- [ ] Histórico e calendário
- [ ] Relatórios PDF
- [ ] Modo cuidador
- [ ] Lembrete de reabastecimento

### Fase 3 - Polimento
- [ ] Testes completos
- [ ] Otimização de performance
- [ ] Acessibilidade avançada
- [ ] Localização (i18n)

### Fase 4 - Lançamento
- [ ] Build de produção
- [ ] Publicação nas lojas
- [ ] Documentação de usuário

## Suporte

Para dúvidas, sugestões ou problemas, abra uma issue no repositório.

---

**Desenvolvido com ❤️ pensando em facilitar a vida de quem mais precisa**
