import 'package:flutter/material.dart';

class AutomationSchedule {
  final String title;
  final String time;
  final String days;
  final bool isEnabled;

  AutomationSchedule({required this.title, required this.time, required this.days, this.isEnabled = true});
}

class AutomationTrigger {
  final String title;
  final String condition;
  final String action;
  final bool isEnabled;
  final IconData icon;

  AutomationTrigger({required this.title, required this.condition, required this.action, this.isEnabled = true, required this.icon});
}

class AutomationViewModel extends ChangeNotifier {
  final List<AutomationSchedule> _schedules = [
    AutomationSchedule(title: "Tưới cây buổi sáng", time: "06:00 AM", days: "T2, T3, T4, T5, T6", isEnabled: true),
    AutomationSchedule(title: "Tưới cây buổi chiều", time: "17:00 PM", days: "T2, T4, T6", isEnabled: false),
  ];

  final List<AutomationTrigger> _triggers = [
    AutomationTrigger(title: "Độ ẩm đất", condition: "Tưới khi < 45%", action: "Bật Bơm A (5 phút)", isEnabled: true, icon: Icons.water),
    AutomationTrigger(title: "Làm mát nhà kính", condition: "Kích hoạt khi > 32°C", action: "Mở quạt thông gió", isEnabled: true, icon: Icons.device_thermostat),
  ];

  List<AutomationSchedule> get schedules => _schedules;
  List<AutomationTrigger> get triggers => _triggers;

  void addSchedule(AutomationSchedule schedule) {
    _schedules.add(schedule);
    notifyListeners();
  }

  void addTrigger(AutomationTrigger trigger) {
    _triggers.add(trigger);
    notifyListeners();
  }

  void toggleSchedule(int index) {
    final current = _schedules[index];
    _schedules[index] = AutomationSchedule(
      title: current.title,
      time: current.time,
      days: current.days,
      isEnabled: !current.isEnabled,
    );
    notifyListeners();
  }

  void toggleTrigger(int index) {
    final current = _triggers[index];
    _triggers[index] = AutomationTrigger(
      title: current.title,
      condition: current.condition,
      action: current.action,
      icon: current.icon,
      isEnabled: !current.isEnabled,
    );
    notifyListeners();
  }
}
