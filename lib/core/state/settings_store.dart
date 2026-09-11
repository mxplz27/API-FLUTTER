import 'package:flutter/foundation.dart';

/// Preferencias de la aplicación. En memoria mientras no haya persistencia.
class SettingsStore extends ChangeNotifier {
  SettingsStore._();

  static final SettingsStore instance = SettingsStore._();

  bool _emailNotifications = true;
  bool _appointmentReminders = true;
  bool _weeklySummary = false;
  bool _compactList = false;
  int _reminderMinutes = 30;
  String _currency = 'COP';

  bool get emailNotifications => _emailNotifications;
  bool get appointmentReminders => _appointmentReminders;
  bool get weeklySummary => _weeklySummary;
  bool get compactList => _compactList;
  int get reminderMinutes => _reminderMinutes;
  String get currency => _currency;

  /// Opciones ofrecidas en el selector de antelación del recordatorio.
  static const List<int> reminderOptions = [15, 30, 60, 120];
  static const List<String> currencyOptions = ['COP', 'USD', 'EUR'];

  set emailNotifications(bool value) {
    _emailNotifications = value;
    notifyListeners();
  }

  set appointmentReminders(bool value) {
    _appointmentReminders = value;
    // Sin recordatorios activos la antelación no aplica.
    if (!value) _reminderMinutes = SettingsStore.reminderOptions.first;
    notifyListeners();
  }

  set weeklySummary(bool value) {
    _weeklySummary = value;
    notifyListeners();
  }

  set compactList(bool value) {
    _compactList = value;
    notifyListeners();
  }

  set reminderMinutes(int value) {
    _reminderMinutes = value;
    notifyListeners();
  }

  set currency(String value) {
    _currency = value;
    notifyListeners();
  }

  /// Vuelve a los valores de fábrica.
  void restoreDefaults() {
    _emailNotifications = true;
    _appointmentReminders = true;
    _weeklySummary = false;
    _compactList = false;
    _reminderMinutes = 30;
    _currency = 'COP';
    notifyListeners();
  }
}
