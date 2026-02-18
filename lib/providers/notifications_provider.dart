import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationsProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _applicationStatusNotifications = true;
  bool _newJobNotifications = true;
  bool _newApplicationsNotifications = true;
  bool _reminderNotifications = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get applicationStatusNotifications => _applicationStatusNotifications;
  bool get newJobNotifications => _newJobNotifications;
  bool get newApplicationsNotifications => _newApplicationsNotifications;
  bool get reminderNotifications => _reminderNotifications;

  NotificationsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _applicationStatusNotifications =
        prefs.getBool('applicationStatusNotifications') ?? true;
    _newJobNotifications = prefs.getBool('newJobNotifications') ?? true;
    _newApplicationsNotifications =
        prefs.getBool('newApplicationsNotifications') ?? true;
    _reminderNotifications = prefs.getBool('reminderNotifications') ?? true;
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);

    if (!_notificationsEnabled) {
      await NotificationService().cancelAllNotifications();
    }

    notifyListeners();
  }

  Future<void> toggleApplicationStatusNotifications(bool value) async {
    _applicationStatusNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('applicationStatusNotifications', value);
    notifyListeners();
  }

  Future<void> toggleNewJobNotifications(bool value) async {
    _newJobNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('newJobNotifications', value);
    notifyListeners();
  }

  Future<void> toggleNewApplicationsNotifications(bool value) async {
    _newApplicationsNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('newApplicationsNotifications', value);
    notifyListeners();
  }

  Future<void> toggleReminderNotifications(bool value) async {
    _reminderNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminderNotifications', value);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _notificationsEnabled = true;
    _applicationStatusNotifications = true;
    _newJobNotifications = true;
    _newApplicationsNotifications = true;
    _reminderNotifications = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notificationsEnabled');
    await prefs.remove('applicationStatusNotifications');
    await prefs.remove('newJobNotifications');
    await prefs.remove('newApplicationsNotifications');
    await prefs.remove('reminderNotifications');

    notifyListeners();
  }
}
