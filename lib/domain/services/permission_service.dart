/// Serviço de Gerenciamento de Permissões
///
/// Gerencia todas as permissões necessárias para o app funcionar:
/// - Notificações
/// - Alarmes exatos
/// - Armazenamento (para sons personalizados)
///
/// Autor: Sistema
/// Data: 2025-11-26
library;

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Verifica e solicita todas as permissões necessárias
  ///
  /// Returns: true se todas as permissões foram concedidas
  Future<bool> checkAndRequestAllPermissions() async {
    final permissions = await Future.wait([
      checkAndRequestNotification(),
      checkAndRequestExactAlarms(),
      checkAndRequestStorage(),
    ]);

    return permissions.every((granted) => granted);
  }

  /// Verifica e solicita permissão de notificações
  Future<bool> checkAndRequestNotification() async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }

    // Se foi permanentemente negado, precisa ir nas configurações
    if (status.isPermanentlyDenied) {
      return false;
    }

    return false;
  }

  /// Verifica e solicita permissão de alarmes exatos (Android 12+)
  Future<bool> checkAndRequestExactAlarms() async {
    // Alarmes exatos são necessários para notificações pontuais
    final status = await Permission.scheduleExactAlarm.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.scheduleExactAlarm.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      return false;
    }

    return false;
  }

  /// Verifica e solicita permissão de armazenamento
  ///
  /// Necessário para acessar arquivos de áudio do dispositivo
  Future<bool> checkAndRequestStorage() async {
    // Android 13+ usa permissões granulares
    final status = await Permission.audio.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.audio.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      return false;
    }

    return false;
  }

  /// Verifica se todas as permissões essenciais estão concedidas
  Future<bool> hasAllEssentialPermissions() async {
    final notification = await Permission.notification.isGranted;
    final alarms = await Permission.scheduleExactAlarm.isGranted;

    return notification && alarms;
  }

  /// Verifica se a permissão de áudio está concedida
  Future<bool> hasAudioPermission() async {
    return await Permission.audio.isGranted;
  }

  /// Abre as configurações do app para o usuário ajustar permissões
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Mostra diálogo explicando por que as permissões são necessárias
  Future<bool?> showPermissionRationale(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Agora não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Conceder'),
          ),
        ],
      ),
    );
  }

  /// Mostra diálogo quando permissão foi negada permanentemente
  Future<void> showPermanentlyDeniedDialog(BuildContext context) async {
    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.block, color: Colors.red),
            SizedBox(width: 12),
            Expanded(child: Text('Permissão Negada')),
          ],
        ),
        content: const Text(
          'Você negou as permissões necessárias. '
          'Para usar todas as funcionalidades do app, '
          'você precisa conceder as permissões nas configurações.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Abrir Configurações'),
          ),
        ],
      ),
    );

    if (shouldOpenSettings == true) {
      await openAppSettings();
    }
  }

  /// Solicita permissões com diálogos explicativos
  Future<bool> requestPermissionsWithRationale(BuildContext context) async {
    // 1. Notificações
    final notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      if (notificationStatus.isPermanentlyDenied) {
        if (context.mounted) {
          await showPermanentlyDeniedDialog(context);
        }
        return false;
      }

      final shouldRequest = await showPermissionRationale(
        context,
        title: 'Permissão de Notificações',
        message: 'O app precisa enviar notificações para lembrá-lo '
            'de tomar seus medicamentos nos horários corretos.',
      );

      if (shouldRequest != true) return false;

      final result = await Permission.notification.request();
      if (!result.isGranted) return false;
    }

    // 2. Alarmes Exatos
    final alarmStatus = await Permission.scheduleExactAlarm.status;
    if (!alarmStatus.isGranted) {
      if (alarmStatus.isPermanentlyDenied) {
        if (context.mounted) {
          await showPermanentlyDeniedDialog(context);
        }
        return false;
      }

      final shouldRequest = await showPermissionRationale(
        context,
        title: 'Permissão de Alarmes Exatos',
        message: 'O app precisa definir alarmes exatos para garantir '
            'que você seja notificado pontualmente nos horários dos medicamentos.',
      );

      if (shouldRequest != true) return false;

      final result = await Permission.scheduleExactAlarm.request();
      if (!result.isGranted) return false;
    }

    return true;
  }

  /// Solicita permissão de áudio quando usuário quiser escolher som do dispositivo
  Future<bool> requestAudioPermissionWithRationale(
      BuildContext context) async {
    final status = await Permission.audio.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await showPermanentlyDeniedDialog(context);
      }
      return false;
    }

    final shouldRequest = await showPermissionRationale(
      context,
      title: 'Permissão de Áudio',
      message: 'O app precisa acessar seus arquivos de áudio '
          'para você escolher um toque personalizado do seu dispositivo.',
    );

    if (shouldRequest != true) return false;

    final result = await Permission.audio.request();
    return result.isGranted;
  }
}
