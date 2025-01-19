import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class SettingsState extends ChangeNotifier {
  bool? _isVibrationEnabled = true; // Default value (fallback)
  bool? get isVibrationEnabled => _isVibrationEnabled;

  SettingsState() {
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    // print("WHY HELLO THERE");
    
    // Fetch the value asynchronously and update the state
    _isVibrationEnabled = Settings.getValue<bool>('key-vibrate'); // Provide a default value
    // print("initial vibrate setting on app open is $_isVibrationEnabled");
    notifyListeners(); // Notify listeners once the value is loaded
  }

  void toggleVibration(bool value) {
    _isVibrationEnabled = value;
    // print("vibrate setting was switched to $_isVibrationEnabled");
    Settings.setValue<bool>('key-vibrate', value); // Persist the new value
    notifyListeners(); // Notify listeners when the value changes
  }
}

final settingsState = SettingsState();