Desenvolva um aplicativo móvel de lembretes de medicamentos totalmente gratuito para operar, usando apenas recursos locais do dispositivo. O sistema deve ser especialmente acessível para idosos, com interface simples e funcionalidade de cálculo automático de horários baseado em intervalos.
ESPECIFICAÇÕES TÉCNICAS DETALHADAS
1. STACK TECNOLÓGICA (100% GRATUITA)
yamlFramework: Flutter (gratuito, cross-platform)
Banco de Dados: SQLite (local, sem servidor)
Notificações: flutter_local_notifications
Alarmes Android: alarm_manager_plus
iOS: flutter_local_notifications + Background Fetch
Armazenamento: Tudo local no dispositivo
2. ESTRUTURA DO BANCO DE DADOS
sql-- Tabela de Medicamentos
CREATE TABLE medicamentos (
  id INTEGER PRIMARY KEY,
  nome TEXT NOT NULL,
  dosagem TEXT NOT NULL,
  primeiro_horario TIME NOT NULL,
  intervalo_horas INTEGER,
  qtd_doses_dia INTEGER,
  tipo_frequencia TEXT, -- "2x ao dia", "3x ao dia", etc
  dias_tratamento INTEGER,
  observacoes TEXT,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Horários Calculados
CREATE TABLE horarios_alarmes (
  id INTEGER PRIMARY KEY,
  medicamento_id INTEGER,
  horario TIME NOT NULL,
  ativo BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (medicamento_id) REFERENCES medicamentos(id)
);

-- Tabela de Histórico
CREATE TABLE historico_doses (
  id INTEGER PRIMARY KEY,
  medicamento_id INTEGER,
  horario_previsto TIME,
  horario_tomado TIMESTAMP,
  status TEXT, -- 'tomado', 'pulado', 'adiado'
  FOREIGN KEY (medicamento_id) REFERENCES medicamentos(id)
);
3. CLASSES PRINCIPAIS DO SISTEMA
dart// Modelo de Configuração do Medicamento
class MedicamentoConfig {
  int? id;
  String nome;
  String dosagem;
  TimeOfDay primeiroHorario;
  int? intervalorHoras;
  int? qtdDosesPorDia;
  String? tipoFrequencia; // "1x ao dia", "2x ao dia", etc
  int diasTratamento;
  String? observacoes;
  List<TimeOfDay> horariosCalculados = [];
  
  // Método para calcular horários automaticamente
  void calcularHorarios() {
    horariosCalculados = CalculadoraHorarios.calcular(
      primeiroHorario: primeiroHorario,
      frequencia: tipoFrequencia,
      intervalo: intervalorHoras,
      qtdDoses: qtdDosesPorDia,
    );
  }
}

// Configuração de Alarme
class AlarmSettings {
  int id;
  DateTime dateTime;
  String assetAudioPath;
  bool loopAudio = true;
  bool vibrate = true;
  double volume = 0.8;
  bool volumeEnforced = true;
  NotificationSettings notificationSettings;
  bool androidFullScreenIntent = true;
  String? warningNotificationOnKill = "O app precisa estar ativo para lembretes";
}

// Configuração de Notificação
class NotificationSettings {
  String title;
  String body;
  String stopButton = "Tomei";
}
4. ALGORITMO CENTRAL - CÁLCULO AUTOMÁTICO DE HORÁRIOS
dartclass CalculadoraHorarios {
  
  // MÉTODO PRINCIPAL - Calcula todos os horários baseado no primeiro
  static List<TimeOfDay> calcular({
    required TimeOfDay primeiroHorario,
    String? frequencia,
    int? intervalo,
    int? qtdDoses,
  }) {
    // Se tem frequência predefinida
    if (frequencia != null) {
      return _calcularPorFrequencia(primeiroHorario, frequencia);
    }
    
    // Se tem intervalo customizado
    if (intervalo != null && qtdDoses != null) {
      return _calcularPorIntervalo(primeiroHorario, intervalo, qtdDoses);
    }
    
    // Default: apenas o horário fornecido
    return [primeiroHorario];
  }
  
  static List<TimeOfDay> _calcularPorFrequencia(
    TimeOfDay primeiro, 
    String frequencia
  ) {
    Map<String, int> intervalos = {
      "1x ao dia": 24,
      "2x ao dia": 12,
      "3x ao dia": 8,
      "4x ao dia": 6,
      "6x ao dia": 4,
    };
    
    int? intervaloHoras = intervalos[frequencia];
    if (intervaloHoras == null) return [primeiro];
    
    int qtdDoses = 24 ~/ intervaloHoras;
    return _calcularPorIntervalo(primeiro, intervaloHoras, qtdDoses);
  }
  
  static List<TimeOfDay> _calcularPorIntervalo(
    TimeOfDay primeiro,
    int intervaloHoras,
    int qtdDoses,
  ) {
    List<TimeOfDay> horarios = [];
    
    for (int i = 0; i < qtdDoses; i++) {
      int hora = (primeiro.hour + (intervaloHoras * i)) % 24;
      horarios.add(TimeOfDay(hour: hora, minute: primeiro.minute));
    }
    
    return horarios;
  }
  
  // Método para ajustar horários evitando madrugada
  static List<TimeOfDay> ajustarParaPeriodoAtivo(
    List<TimeOfDay> horarios,
    {TimeOfDay horaAcordar = const TimeOfDay(hour: 7, minute: 0),
     TimeOfDay horaDormir = const TimeOfDay(hour: 22, minute: 0)}
  ) {
    // Redistribui horários apenas no período acordado
    List<TimeOfDay> ajustados = [];
    int horasAtivas = horaDormir.hour - horaAcordar.hour;
    int intervalo = horasAtivas ~/ horarios.length;
    
    for (int i = 0; i < horarios.length; i++) {
      int novaHora = horaAcordar.hour + (intervalo * i);
      ajustados.add(TimeOfDay(hour: novaHora, minute: 0));
    }
    
    return ajustados;
  }
}
5. INTERFACE DE USUÁRIO - FLUXO SIMPLIFICADO
dart// TELA 1: Lista de Medicamentos (Home)
class HomeScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meus Medicamentos"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(context, ConfiguracoesScreen()),
          ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return CardMedicamento(medicamento: medicamentos[index]);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, AdicionarMedicamentoScreen()),
        label: Text("Adicionar Medicamento"),
        icon: Icon(Icons.add),
      ),
    );
  }
}

// TELA 2: Adicionar Medicamento (3 PASSOS)
class AdicionarMedicamentoScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Novo Medicamento")),
      body: Stepper(
        currentStep: currentStep,
        steps: [
          // PASSO 1: Informações Básicas
          Step(
            title: Text("Medicamento"),
            content: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: "Nome do Medicamento",
                    hintText: "Ex: Losartana",
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Dosagem",
                    hintText: "Ex: 50mg",
                  ),
                ),
              ],
            ),
          ),
          
          // PASSO 2: Frequência e Primeiro Horário
          Step(
            title: Text("Horários"),
            content: Column(
              children: [
                // Seletor de Frequência
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Quantas vezes por dia?"),
                  items: [
                    DropdownMenuItem(value: "1x ao dia", child: Text("1x ao dia")),
                    DropdownMenuItem(value: "2x ao dia", child: Text("2x ao dia (12 em 12h)")),
                    DropdownMenuItem(value: "3x ao dia", child: Text("3x ao dia (8 em 8h)")),
                    DropdownMenuItem(value: "4x ao dia", child: Text("4x ao dia (6 em 6h)")),
                    DropdownMenuItem(value: "custom", child: Text("Personalizado")),
                  ],
                  onChanged: (value) => setState(() => frequencia = value),
                ),
                
                // Seletor de Horário Inicial
                ListTile(
                  title: Text("Primeiro horário: ${primeiroHorario.format(context)}"),
                  trailing: Icon(Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: primeiroHorario,
                    );
                    if (picked != null) {
                      setState(() {
                        primeiroHorario = picked;
                        // CALCULA AUTOMATICAMENTE OS OUTROS HORÁRIOS
                        calcularHorarios();
                      });
                    }
                  },
                ),
                
                // Se escolheu personalizado
                if (frequencia == "custom") ...[
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Intervalo entre doses (horas)",
                      hintText: "Ex: 6",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Número de doses por dia",
                      hintText: "Ex: 3",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ],
            ),
          ),
          
          // PASSO 3: Confirmação com Preview
          Step(
            title: Text("Confirmar"),
            content: Column(
              children: [
                Text(
                  "Medicamento: $nome $dosagem",
                  style: Theme.of(context).textTheme.headline6,
                ),
                Divider(),
                Text("Lembretes serão criados para:"),
                
                // MOSTRA TODOS OS HORÁRIOS CALCULADOS
                ...horariosCalculados.map((horario) => 
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.alarm, color: Colors.blue),
                      title: Text(
                        horario.format(context),
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => editarHorarioIndividual(horario),
                      ),
                    ),
                  ),
                ).toList(),
                
                SwitchListTile(
                  title: Text("Evitar horários de madrugada"),
                  subtitle: Text("Redistribui entre 7h e 22h"),
                  value: evitarMadrugada,
                  onChanged: (value) {
                    setState(() {
                      evitarMadrugada = value;
                      if (value) {
                        horariosCalculados = CalculadoraHorarios
                          .ajustarParaPeriodoAtivo(horariosCalculados);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ],
        onStepContinue: () {
          if (currentStep < 2) {
            setState(() => currentStep++);
          } else {
            salvarMedicamento();
          }
        },
      ),
    );
  }
}
6. SISTEMA DE NOTIFICAÇÕES E ALARMES
dartclass GerenciadorAlarmes {
  
  // Criar alarme para cada horário calculado
  static Future<void> configurarAlarmes(MedicamentoConfig config) async {
    for (var horario in config.horariosCalculados) {
      await criarAlarmeRecorrente(
        medicamento: config,
        horario: horario,
      );
    }
  }
  
  static Future<void> criarAlarmeRecorrente({
    required MedicamentoConfig medicamento,
    required TimeOfDay horario,
  }) async {
    // Calcular próxima ocorrência
    final now = DateTime.now();
    var proximaOcorrencia = DateTime(
      now.year, now.month, now.day,
      horario.hour, horario.minute,
    );
    
    // Se já passou hoje, agendar para amanhã
    if (proximaOcorrencia.isBefore(now)) {
      proximaOcorrencia = proximaOcorrencia.add(Duration(days: 1));
    }
    
    final alarmSettings = AlarmSettings(
      id: '${medicamento.id}_${horario.hour}${horario.minute}'.hashCode,
      dateTime: proximaOcorrencia,
      assetAudioPath: 'assets/sounds/alarme_medicamento.mp3',
      loopAudio: true,
      vibrate: true,
      volume: 0.8,
      volumeEnforced: true,
      notificationSettings: NotificationSettings(
        title: '💊 Hora do Medicamento!',
        body: '${medicamento.nome} ${medicamento.dosagem}\n'
              'Toque para confirmar que tomou',
        stopButton: 'Tomei',
      ),
      androidFullScreenIntent: true,
      warningNotificationOnKill: Platform.isIOS 
        ? 'Mantenha o app aberto para receber lembretes'
        : null,
    );
    
    await Alarm.set(alarmSettings);
    
    // Reagendar para o próximo dia após disparar
    // Implementar callback para recriar o alarme
  }
  
  // Função chamada quando usuário confirma que tomou
  static Future<void> confirmarDoseTomada(int alarmId) async {
    await Alarm.stop(alarmId);
    
    // Registrar no histórico
    await DatabaseHelper.registrarDose(alarmId, 'tomado');
    
    // Reagendar para o próximo dia
    await reagendarParaAmanha(alarmId);
  }
  
  // Soneca de 10 minutos
  static Future<void> adiarAlarme(int alarmId) async {
    await Alarm.stop(alarmId);
    
    // Reagendar para 10 minutos
    final novoHorario = DateTime.now().add(Duration(minutes: 10));
    // ... recriar alarme com novo horário
  }
}
7. PERMISSÕES E CONFIGURAÇÕES DE PLATAFORMA
Android (android/app/src/main/AndroidManifest.xml)
xml<manifest>
  <!-- Permissões necessárias -->
  <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
  <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
  <uses-permission android:name="android.permission.VIBRATE" />
  <uses-permission android:name="android.permission.WAKE_LOCK" />
  <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
  
  <application>
    <!-- Receiver para manter alarmes após reinicialização -->
    <receiver 
      android:name="com.example.app.BootReceiver"
      android:enabled="true"
      android:exported="true">
      <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
      </intent-filter>
    </receiver>
  </application>
</manifest>
iOS (ios/Runner/Info.plist)
xml<dict>
  <!-- Background modes para iOS -->
  <key>UIBackgroundModes</key>
  <array>
    <string>fetch</string>
    <string>audio</string>
  </array>
  
  <!-- Mensagem sobre notificações -->
  <key>NSUserNotificationUsageDescription</key>
  <string>Precisamos enviar lembretes para seus medicamentos</string>
</dict>
8. FUNCIONALIDADES EXTRAS IMPORTANTES
dartclass RecursosAdicionais {
  
  // Widget de histórico visual
  static Widget buildCalendarioMedicacao(int medicamentoId) {
    // Calendário mostrando dias tomados/perdidos
    // Verde = tomou, Vermelho = não tomou, Amarelo = atrasou
  }
  
  // Exportar relatório para médico
  static Future<File> gerarRelatorioPDF(DateRange periodo) async {
    // Gerar PDF com histórico de medicação
    // Útil para consultas médicas
  }
  
  // Modo Cuidador
  static void configurarModoCuidador(String telefoneResponsavel) {
    // Enviar SMS se medicamento não foi tomado
    // Útil para idosos com supervisão
  }
  
  // Lembrete de Reabastecimento
  static void calcularQuandoAcaba(MedicamentoConfig med) {
    // Baseado na quantidade de comprimidos
    // Alerta quando restar 7 dias
  }
  
  // Modo Simplificado para Idosos
  static Widget buildInterfaceSimplificada() {
    // Apenas 2 botões grandes: TOMEI / ADIAR
    // Fonte size 24+, alto contraste
  }
}
9. TRATAMENTO DE CASOS ESPECIAIS
dartclass CasosEspeciais {
  
  // Medicamentos SOS (quando necessário)
  static void configurarMedicamentoSOS(Medicamento med) {
    // Não criar alarmes automáticos
    // Apenas botão rápido na tela inicial
    // Registrar quando foi tomado
  }
  
  // Medicamentos com jejum
  static TimeOfDay calcularHorarioJejum() {
    // 30 min antes do café da manhã
    // Avisar para não comer por X tempo
  }
  
  // Antibióticos (curso completo)
  static void configurarAntibiotico(int diasTratamento) {
    // Contador regressivo de dias
    // Alerta para não parar mesmo se melhorar
    // Badge motivacional: "Dia 5 de 7"
  }
  
  // Conflito de horários
  static void verificarConflitos(List<Medicamento> todos) {
    // Se 2+ medicamentos no mesmo horário
    // Sugerir espaçamento de 15 minutos
    // Ou agrupar se podem ser tomados juntos
  }
}
10. CONFIGURAÇÕES DO USUÁRIO
dartclass ConfiguracoesUsuario {
  // Som do alarme
  String somAlarme = 'assets/sounds/gentle_bell.mp3';
  
  // Volume
  double volume = 0.8;
  
  // Vibração
  bool vibrar = true;
  
  // Período ativo (evitar madrugada)
  TimeOfDay horaAcordar = TimeOfDay(hour: 7, minute: 0);
  TimeOfDay horaDormir = TimeOfDay(hour: 22, minute: 0);
  
  // Modo
  String modo = 'normal'; // 'normal', 'idoso', 'cuidador'
  
  // Snooze
  int tempoSoneca = 10; // minutos
  
  // Persistência
  bool alarmeInsistente = true; // Tocar até interação
}
11. TESTES ESSENCIAIS
dartvoid main() {
  group('Calculadora de Horários', () {
    test('Deve calcular 3 doses corretamente', () {
      final horarios = CalculadoraHorarios.calcular(
        primeiroHorario: TimeOfDay(hour: 8, minute: 0),
        frequencia: "3x ao dia",
      );
      
      expect(horarios.length, 3);
      expect(horarios[0].hour, 8);
      expect(horarios[1].hour, 16);
      expect(horarios[2].hour, 0); // meia-noite
    });
    
    test('Deve evitar madrugada quando configurado', () {
      final horarios = CalculadoraHorarios.ajustarParaPeriodoAtivo(
        [TimeOfDay(hour: 2, minute: 0)], // 2 da manhã
      );
      
      expect(horarios[0].hour, greaterThanOrEqualTo(7));
      expect(horarios[0].hour, lessThanOrEqualTo(22));
    });
  });
}
12. PUBLICAÇÃO E DISTRIBUIÇÃO
yaml# Opções sem custo:
1. GitHub Releases:
   - APK direto para Android
   - Instruções de instalação
   
2. F-Droid:
   - Loja open source
   - Sem taxas
   
3. PWA (Progressive Web App):
   - Flutter Web
   - Instalar do navegador
   
# Custo único (recomendado):
4. Google Play Store:
   - $25 taxa única vitalícia
   - Alcance maior
   - Atualizações automáticas
IMPORTANTE - PRINCÍPIOS DE DESENVOLVIMENTO

Offline First: Tudo funciona sem internet
Zero Custo Operacional: Sem servidores, sem APIs pagas
Acessibilidade: Fontes grandes, contraste alto, interface simples
Confiabilidade: Alarmes funcionam mesmo com app fechado (Android)
Privacidade: Dados apenas no dispositivo do usuário

ENTREGA FINAL
O sistema deve estar 100% funcional com:

✅ Cálculo automático de horários baseado no primeiro horário
✅ Alarmes que funcionam com app fechado (Android)
✅ Interface simples para idosos
✅ Histórico de medicações
✅ Zero custos operacionais
✅ Funcionamento totalmente offline

Este prompt contém TODAS as especificações necessárias para desenvolver o sistema completo, com foco especial no cálculo automático de horários que facilita muito o uso para idosos.