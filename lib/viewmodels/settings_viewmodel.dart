import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  String _currentLanguage = 'vi'; // 'vi', 'ja'
  String _tempUnit = 'C'; // 'C', 'F', 'K'

  String get currentLanguage => _currentLanguage;
  bool get isEnglish => _currentLanguage == 'ja'; // Fallback temporary
  String get tempUnit => _tempUnit;

  void setLanguage(String langCode) {
    if (['vi', 'ja'].contains(langCode)) {
      _currentLanguage = langCode;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == 'vi' ? 'ja' : 'vi';
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
