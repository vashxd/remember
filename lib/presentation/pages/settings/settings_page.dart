import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../data/preferences/user_preferences.dart';
import '../../../domain/services/permission_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late UserPreferences _prefs;
  bool _isLoading = true;

  // State variables
  late String _ringtone;
  late double _volume;
  late bool _vibration;
  late bool _avoidEarlyMorning;
  late TimeOfDay _wakeUpTime;
  late TimeOfDay _bedTime;
  late int _snoozeMinutes;
  late bool? _darkMode;

  // Lista de toques disponíveis
  final Map<String, String> _availableRingtones = {
    'assets/sounds/gentle_bell.mp3': 'Sino Suave',
    'assets/sounds/chime.mp3': 'Carrilhão',
    'assets/sounds/beep.mp3': 'Bipe',
    'assets/sounds/alarm_clock.mp3': 'Despertador',
    'assets/sounds/notification.mp3': 'Notificação',
  };

  final PermissionService _permissionService = PermissionService();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await UserPreferences.init();
    setState(() {
      _ringtone = _prefs.ringtone;
      _volume = _prefs.volume;
      _vibration = _prefs.vibration;
      _avoidEarlyMorning = _prefs.avoidEarlyMorning;
      _wakeUpTime = _prefs.wakeUpTime;
      _bedTime = _prefs.bedTime;
      _snoozeMinutes = _prefs.snoozeMinutes;
      _darkMode = _prefs.isDarkMode;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Geral'),
          SwitchListTile(
            title: const Text('Modo Escuro'),
            subtitle: Text(_darkMode == null
                ? 'Padrão do sistema'
                : (_darkMode! ? 'Ativado' : 'Desativado')),
            value: _darkMode ?? false,

            // Let's implement a simple toggle for now: System -> Light -> Dark is complex with a switch.
            // Using a dialog selector might be better, but for now let's stick to a simple toggle or just handle Light/Dark.
            // Let's assume false = Light, true = Dark for simplicity in UI, but logic handles null.
            onChanged: (bool? value) {
               // Cycle: System (null) -> Light (false) -> Dark (true) -> System (null)
               bool? newValue;
               if (_darkMode == null) newValue = false;
               else if (_darkMode == false) newValue = true;
               else newValue = null;
               
               setState(() => _darkMode = newValue);
               _prefs.setDarkMode(newValue);
               // Note: You'll need a ThemeProvider to listen to this change and update the app theme.
            },
            secondary: const Icon(Icons.brightness_6),
          ),

          _buildSectionHeader('Alarmes'),
          ListTile(
            title: const Text('Toque de Alarme'),
            subtitle: Text(_getRingtoneName(_ringtone)),
            leading: const Icon(Icons.music_note),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showRingtonePicker,
          ),
          ListTile(
            title: const Text('Volume do Alarme'),
            subtitle: Slider(
              value: _volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: '${(_volume * 100).round()}%',
              onChanged: (value) {
                setState(() => _volume = value);
                _prefs.setVolume(value);
              },
            ),
            leading: const Icon(Icons.volume_up),
          ),
          SwitchListTile(
            title: const Text('Vibração'),
            value: _vibration,
            onChanged: (value) {
              setState(() => _vibration = value);
              _prefs.setVibration(value);
            },
            secondary: const Icon(Icons.vibration),
          ),
          ListTile(
            title: const Text('Tempo de Soneca'),
            subtitle: Text('$_snoozeMinutes minutos'),
            leading: const Icon(Icons.snooze),
            onTap: () async {
              // Simple dialog to pick minutes
              final newValue = await showDialog<int>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('Tempo de Soneca'),
                  children: [5, 10, 15, 20, 30].map((m) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, m),
                    child: Text('$m minutos'),
                  )).toList(),
                ),
              );
              if (newValue != null) {
                setState(() => _snoozeMinutes = newValue);
                _prefs.setSnoozeMinutes(newValue);
              }
            },
          ),

          _buildSectionHeader('Horários'),
          SwitchListTile(
            title: const Text('Evitar Madrugada'),
            subtitle: const Text('Não agendar alarmes enquanto durmo'),
            value: _avoidEarlyMorning,
            onChanged: (value) {
              setState(() => _avoidEarlyMorning = value);
              _prefs.setAvoidEarlyMorning(value);
            },
            secondary: const Icon(Icons.nights_stay),
          ),
          if (_avoidEarlyMorning) ...[
            ListTile(
              title: const Text('Horário de Acordar'),
              trailing: Text(_wakeUpTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _wakeUpTime,
                );
                if (time != null) {
                  setState(() => _wakeUpTime = time);
                  _prefs.setWakeUpTime(time);
                }
              },
            ),
            ListTile(
              title: const Text('Horário de Dormir'),
              trailing: Text(_bedTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _bedTime,
                );
                if (time != null) {
                  setState(() => _bedTime = time);
                  _prefs.setBedTime(time);
                }
              },
            ),
          ],
          
          _buildSectionHeader('Sobre'),
          const ListTile(
            title: Text('Versão'),
            subtitle: Text('1.0.0'),
            leading: Icon(Icons.info),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getRingtoneName(String path) {
    // Se é um arquivo customizado, mostra apenas o nome do arquivo
    if (!_availableRingtones.containsKey(path)) {
      final fileName = path.split('/').last;
      return 'Toque Personalizado: $fileName';
    }
    return _availableRingtones[path] ?? 'Sino Suave';
  }

  Future<void> _showRingtonePicker() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Toque de Alarme'),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toques padrão
              ListView.builder(
                shrinkWrap: true,
                itemCount: _availableRingtones.length,
                itemBuilder: (context, index) {
                  final entry = _availableRingtones.entries.elementAt(index);
                  final isSelected = entry.key == _ringtone;

                  return ListTile(
                    title: Text(entry.value),
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        // TODO: Preview do toque
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Preview: ${entry.value}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      tooltip: 'Testar',
                    ),
                    onTap: () => Navigator.pop(context, entry.key),
                  );
                },
              ),
              const Divider(),
              // Botão para escolher do dispositivo
              ListTile(
                leading: const Icon(Icons.folder_open, color: Colors.blue),
                title: const Text(
                  'Escolher do Dispositivo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Selecionar arquivo de áudio'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickCustomRingtone();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (selected != null && mounted) {
      setState(() => _ringtone = selected);
      await _prefs.setRingtone(selected);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Toque alterado para: ${_getRingtoneName(selected)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Permite escolher um arquivo de áudio do dispositivo
  Future<void> _pickCustomRingtone() async {
    // Primeiro, solicitar permissão
    final hasPermission =
        await _permissionService.requestAudioPermissionWithRationale(context);

    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão negada. Não é possível acessar arquivos de áudio.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // Selecionar arquivo de áudio
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final path = file.path;

        if (path != null) {
          // Verificar tamanho do arquivo (máximo 5MB)
          final fileSize = file.size;
          if (fileSize > 5 * 1024 * 1024) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Arquivo muito grande. Escolha um arquivo menor que 5MB.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }

          setState(() => _ringtone = path);
          await _prefs.setRingtone(path);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Toque personalizado selecionado: ${file.name}'),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar arquivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
