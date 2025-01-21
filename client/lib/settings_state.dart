import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class SettingsState extends ChangeNotifier {

  bool? _isVibrationEnabled = true; // Default value (fallback)
  bool? get isVibrationEnabled => _isVibrationEnabled;

  bool? _isTimeTicksEnabled = false; // Default value (fallback)
  bool? get isTimeTickEnabled => _isTimeTicksEnabled;

  double? _timeSteps = 5.0;
  double? get timeSteps => _timeSteps;

  String? _lastChangedSetting;
  String? get lastChangedSetting => _lastChangedSetting;

  SettingsState() {
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {  

    if (Settings.containsKey('key-time-ticks') == false) {
      Settings.setValue<bool>('key-time-ticks', false);
    }
    if (Settings.containsKey('key-time-steps') == false) {
      Settings.setValue<double>('key-time-steps', 5.0);
    }
    if (Settings.containsKey('key-vibrate') == false) {
      Settings.setValue<bool>('key-vibrate', true);
    } 
    // Fetch the value asynchronously and update the state
    _isVibrationEnabled = Settings.getValue<bool>('key-vibrate');
    _isTimeTicksEnabled = Settings.getValue<bool>('key-time-ticks');
    _timeSteps = Settings.getValue<double>('key-time-steps');
    notifyListeners(); // Notify listeners once the value is loaded
  }

  void toggleVibration(bool value) {
    _isVibrationEnabled = value;
    Settings.setValue<bool>('key-vibrate', value); // Persist the new value
    _lastChangedSetting = 'key-vibrate';
    notifyListeners(); // Notify listeners when the value changes
  }

  void toggleTimeTicks(bool value) {
    _isTimeTicksEnabled = value;
    Settings.setValue<bool>('key-time-ticks', value); // Persist the new value
    _lastChangedSetting = 'key-time-ticks';
    notifyListeners(); // Notify listeners when the value changes
  }

  void setTimeSteps(double value) {
    _timeSteps = value;
    Settings.setValue<double>('key-time-steps', value); // Persist the new value
    _lastChangedSetting = 'key-time-steps';
    notifyListeners();
  }

  void resetLastChangedSettings() {
    _lastChangedSetting = null;
  }

}

final settingsState = SettingsState();