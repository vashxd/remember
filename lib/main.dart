import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alarm/alarm.dart';
import 'dart:async';
import 'core/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'presentation/providers/medicamento_provider.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/alarm/alarm_ring_page.dart';

import 'domain/services/notification_service.dart';
import 'domain/services/alarm_service.dart';
import 'domain/services/permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar serviços
  await NotificationService().init();
  await AlarmService().init();

  runApp(const LembreteMedicamentosApp());
}

class LembreteMedicamentosApp extends StatefulWidget {
  const LembreteMedicamentosApp({super.key});

  @override
  State<LembreteMedicamentosApp> createState() => _LembreteMedicamentosAppState();
}

class _LembreteMedicamentosAppState extends State<LembreteMedicamentosApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<AlarmSettings>? _alarmSubscription;
  final Set<int> _showingAlarmIds = {}; // Track currently showing alarms

  @override
  void initState() {
    super.initState();
    _listenToAlarms();
  }

  void _listenToAlarms() {
    _alarmSubscription = Alarm.ringStream.stream.listen((alarmSettings) {
      debugPrint('Alarme tocando: ${alarmSettings.id}');

      // Prevent duplicate navigation for the same alarm
      if (_showingAlarmIds.contains(alarmSettings.id)) {
        debugPrint('Alarme ${alarmSettings.id} já está sendo exibido, ignorando duplicata');
        return;
      }

      // Mark this alarm as showing
      _showingAlarmIds.add(alarmSettings.id);

      // Navegar para a tela de alarme
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => AlarmRingPage(
            alarmSettings: alarmSettings,
            onDismissed: () {
              // Remove from showing set when dismissed
              _showingAlarmIds.remove(alarmSettings.id);
            },
          ),
          fullscreenDialog: true,
        ),
      );
    });
  }

  @override
  void dispose() {
    _alarmSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MedicamentoProvider()..init(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        home: const PermissionCheckPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Página para verificar e solicitar permissões no primeiro uso
class PermissionCheckPage extends StatefulWidget {
  const PermissionCheckPage({super.key});

  @override
  State<PermissionCheckPage> createState() => _PermissionCheckPageState();
}

class _PermissionCheckPageState extends State<PermissionCheckPage> {
  final PermissionService _permissionService = PermissionService();
  bool _isChecking = true;
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _isChecking = true);

    // Verificar se já tem permissões
    final hasEssential = await _permissionService.hasAllEssentialPermissions();

    if (hasEssential) {
      // Já tem permissões, ir para home
      setState(() {
        _hasPermissions = true;
        _isChecking = false;
      });
      _navigateToHome();
    } else {
      // Não tem permissões, solicitar
      setState(() => _isChecking = false);
    }
  }

  Future<void> _requestPermissions() async {
    if (!mounted) return;

    final granted =
        await _permissionService.requestPermissionsWithRationale(context);

    if (granted) {
      setState(() => _hasPermissions = true);
      _navigateToHome();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Algumas funcionalidades podem não funcionar sem as permissões.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
        // Ainda assim, navegar para home
        _navigateToHome();
      }
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(strokeWidth: 3),
              const SizedBox(height: 24),
              Text(
                'Inicializando...',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone
              Icon(
                Icons.medication,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),

              // Título
              Text(
                'Bem-vindo!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Descrição
              Text(
                'Para funcionar corretamente, o app precisa de algumas permissões.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Lista de permissões
              _buildPermissionItem(
                icon: Icons.notifications_active,
                title: 'Notificações',
                description: 'Para lembrá-lo de tomar os medicamentos',
              ),
              const SizedBox(height: 16),
              _buildPermissionItem(
                icon: Icons.alarm,
                title: 'Alarmes Exatos',
                description: 'Para avisos pontuais nos horários corretos',
              ),
              const SizedBox(height: 48),

              // Botão de continuar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _requestPermissions,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botão de pular
              TextButton(
                onPressed: _navigateToHome,
                child: const Text('Pular por enquanto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
