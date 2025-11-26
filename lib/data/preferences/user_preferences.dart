import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _keyRingtone = 'ringtone';
  static const String _keyVolume = 'volume';
  static const String _keyVibration = 'vibration';
  static const String _keySnoozeMinutes = 'snooze_minutes';
  static const String _keyAvoidEarlyMorning = 'avoid_early_morning';
  static const String _keyWakeUpTime = 'wake_up_time';
  static const String _keyBedTime = 'bed_time';
  static const String _keyDarkMode = 'dark_mode';

  final SharedPreferences _prefs;

  UserPreferences(this._prefs);

  static Future<UserPreferences> init() async {
    final prefs = await SharedPreferences.getInstance();
    return UserPreferences(prefs);
  }

  // Ringtone
  String get ringtone => _prefs.getString(_keyRingtone) ?? 'assets/sounds/alarm.mp3';
  Future<void> setRingtone(String value) => _prefs.setString(_keyRingtone, value);

  // Volume (0.0 to 1.0)
  double get volume => _prefs.getDouble(_keyVolume) ?? 0.8;
  Future<void> setVolume(double value) => _prefs.setDouble(_keyVolume, value);

  // Vibration
  bool get vibration => _prefs.getBool(_keyVibration) ?? true;
  Future<void> setVibration(bool value) => _prefs.setBool(_keyVibration, value);

  // Snooze Duration (minutes)
  int get snoozeMinutes => _prefs.getInt(_keySnoozeMinutes) ?? 10;
  Future<void> setSnoozeMinutes(int value) => _prefs.setInt(_keySnoozeMinutes, value);

  // Avoid Early Morning
  bool get avoidEarlyMorning => _prefs.getBool(_keyAvoidEarlyMorning) ?? false;
  Future<void> setAvoidEarlyMorning(bool value) => _prefs.setBool(_keyAvoidEarlyMorning, value);

  // Wake Up Time (stored as "HH:mm")
  TimeOfDay get wakeUpTime {
    final stored = _prefs.getString(_keyWakeUpTime);
    if (stored == null) return const TimeOfDay(hour: 7, minute: 0);
    final parts = stored.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> setWakeUpTime(TimeOfDay value) =>
      _prefs.setString(_keyWakeUpTime, '${value.hour}:${value.minute}');

  // Bed Time (stored as "HH:mm")
  TimeOfDay get bedTime {
    final stored = _prefs.getString(_keyBedTime);
    if (stored == null) return const TimeOfDay(hour: 22, minute: 0);
    final parts = stored.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> setBedTime(TimeOfDay value) =>
      _prefs.setString(_keyBedTime, '${value.hour}:${value.minute}');
      
  // Dark Mode
  bool? get isDarkMode => _prefs.getBool(_keyDarkMode); // null = system default
  Future<void> setDarkMode(bool? value) async {
    if (value == null) {
      await _prefs.remove(_keyDarkMode);
    } else {
      await _prefs.setBool(_keyDarkMode, value);
    }
  }
}
