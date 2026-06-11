import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  bool _isEnglish = false;
  String _tempUnit = 'C'; // 'C', 'F', 'K'

  bool get isEnglish => _isEnglish;
  String get tempUnit => _tempUnit;

  void toggleLanguage() {
    _isEnglish = !_isEnglish;
    notifyListeners();
  }

  void setTempUnit(String unit) {
    if (['C', 'F', 'K'].contains(unit)) {
      _tempUnit = unit;
      notifyListeners();
    }
  }

  // Tiện ích format nhiệt độ
  String formatTemperature(double tempInC) {
    double converted = tempInC;
    if (_tempUnit == 'F') {
      converted = (tempInC * 9 / 5) + 32;
    } else if (_tempUnit == 'K') {
      converted = tempInC + 273.15;
    }
    return '${converted.toStringAsFixed(1)}°$_tempUnit';
  }
}
