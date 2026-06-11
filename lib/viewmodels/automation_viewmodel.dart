import 'dart:async';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'sensor_viewmodel.dart';

class AutomationSchedule {
  final String? id;
  final String userId;
  final String title;
  final String time;
  final String days;
  final bool isEnabled;

  AutomationSchedule({
    this.id,
    required this.userId,
    required this.title,
    required this.time,
    required this.days,
    this.isEnabled = true,
  });

  factory AutomationSchedule.fromJson(Map<String, dynamic> json) {
    return AutomationSchedule(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      time: json['time'],
      days: json['days'],
      isEnabled: json['is_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'time': time,
      'days': days,
      'is_enabled': isEnabled,
    };
  }
}

class AutomationTrigger {
  final String? id;
  final String userId;
  final String title;
  final String condition;
  final String action;
  final bool isEnabled;
  final IconData icon;

  AutomationTrigger({
    this.id,
    required this.userId,
    required this.title,
    required this.condition,
    required this.action,
    this.isEnabled = true,
    required this.icon,
  });

  factory AutomationTrigger.fromJson(Map<String, dynamic> json) {
    return AutomationTrigger(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      condition: json['condition'],
      action: json['action'],
      isEnabled: json['is_enabled'] ?? true,
      icon: _getIconFromCodePoint(json['icon_code_point']),
    );
  }

  static IconData _getIconFromCodePoint(dynamic codePoint) {
    if (codePoint == null) return Icons.device_unknown;
    int code = codePoint is int ? codePoint : int.tryParse(codePoint.toString()) ?? 0;
    
    if (code == Icons.water.codePoint) return Icons.water;
    if (code == Icons.device_thermostat.codePoint) return Icons.device_thermostat;
    if (code == Icons.lightbulb.codePoint) return Icons.lightbulb;
    
    return Icons.device_unknown;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'condition': condition,
      'action': action,
      'is_enabled': isEnabled,
      'icon_code_point': icon.codePoint,
      'icon_font_family': icon.fontFamily ?? 'MaterialIcons',
    };
  }
}

class AutomationViewModel extends ChangeNotifier {
  List<AutomationSchedule> _schedules = [];
  List<AutomationTrigger> _triggers = [];
  bool _isLoading = false;

  SensorViewModel? _sensorVM;
  Timer? _engineTimer;

  // Tránh spam trigger liên tục: lưu lại trạng thái xem trigger đã đc kích hoạt chưa
  final Map<String, bool> _triggerActiveStates = {};
  // Lưu ngày chạy cuối của schedule để tránh chạy lại nhiều lần trong cùng 1 phút
  final Map<String, String> _scheduleLastRunDates = {};

  AutomationViewModel() {
    _startEngine();
  }

  @override
  void dispose() {
    _engineTimer?.cancel();
    super.dispose();
  }

  void updateSensor(SensorViewModel vm) {
    _sensorVM = vm;
  }

  void _startEngine() {
    // Kiểm tra mỗi 10 giây
    _engineTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _evaluateTriggers();
      _evaluateSchedules();
    });
  }

  void _evaluateTriggers() {
    if (_sensorVM == null) return;
    final sensor = _sensorVM!;

    for (var trigger in _triggers) {
      if (!trigger.isEnabled || trigger.id == null) continue;

      bool conditionMet = false;
      // condition mẫu: "Kích hoạt khi Nhiệt độ > 30" hoặc "Trigger when Temperature > 30"
      final match = RegExp(r'(?:Kích hoạt khi|Trigger when) (.*) (>|<|=) (\d+)').firstMatch(trigger.condition);
      if (match != null) {
        String sensorName = match.group(1)!;
        String op = match.group(2)!;
        double threshold = double.parse(match.group(3)!);

        double currentValue = 0.0;
        if (sensorName.contains("Nhiệt độ") || sensorName.contains("Temperature")) {
          currentValue = sensor.nhietDo;
        } else if (sensorName.contains("Độ ẩm đất") || sensorName.contains("Soil Moisture")) {
          currentValue = sensor.doAmDat;
        } else if (sensorName.contains("Cường độ sáng") || sensorName.contains("Light")) {
          currentValue = sensor.doAmDat; // Fallback or implement light sensor
        }

        if (op == '>') {
          conditionMet = currentValue > threshold;
        } else if (op == '<') {
          conditionMet = currentValue < threshold;
        } else if (op == '=') {
          conditionMet = currentValue == threshold;
        }
      }

      // Cập nhật logic: Nếu điều kiện đúng, kiểm tra xem có cần re-trigger không (ví dụ: máy bơm đã tắt nhưng nhiệt độ vẫn < 50)
      bool wasActive = _triggerActiveStates[trigger.id!] ?? false;
      if (conditionMet) {
        bool canReTrigger = false;
        // Kiểm tra xem hiện tại có đang chạy action này không
        if (trigger.action.contains("phút") || trigger.action.contains("mins")) {
          canReTrigger = !sensor.isPumpOn && sensor.pumpCountdownRemaining == 0;
        } else if (trigger.action == "Bật" || trigger.action == "Turn on") {
          canReTrigger = !sensor.isPumpOn;
        } else if (trigger.action == "Tắt" || trigger.action == "Turn off") {
          canReTrigger = sensor.isPumpOn;
        }

        if (!wasActive || canReTrigger) {
          _triggerActiveStates[trigger.id!] = true;
          _executeAction(trigger.action, sensor);
        }
      } else {
        _triggerActiveStates[trigger.id!] = false;
      }
    }
  }

  void _evaluateSchedules() {
    if (_sensorVM == null) return;
    final sensor = _sensorVM!;
    final now = DateTime.now();

    // Mapping thứ hiện tại
    // DateTime.weekday: 1 (Monday) to 7 (Sunday)
    List<String> daysMap = ["", "T2", "T3", "T4", "T5", "T6", "T7", "CN"];
    String todayStr = daysMap[now.weekday];
    String dateStr = "${now.year}-${now.month}-${now.day}";

    for (var schedule in _schedules) {
      if (!schedule.isEnabled || schedule.id == null) continue;
      
      // Kiểm tra ngày lặp
      if (schedule.days != "Không lặp" && !schedule.days.contains(todayStr)) {
        continue;
      }

      // Kiểm tra đã chạy hôm nay chưa
      if (_scheduleLastRunDates[schedule.id!] == dateStr) {
        continue; // Đã chạy rồi
      }

      // Parse giờ (Mẫu time: "06:00 AM" hoặc "18:30" - tuỳ locale đt)
      // Để đơn giản, ta chỉ trích xuất số giờ và phút từ chuỗi
      final timeMatch = RegExp(r'(\d+):(\d+)').firstMatch(schedule.time);
      if (timeMatch != null) {
        int h = int.parse(timeMatch.group(1)!);
        int m = int.parse(timeMatch.group(2)!);
        bool isPM = schedule.time.toLowerCase().contains("pm");
        bool isAM = schedule.time.toLowerCase().contains("am");

        if (isPM && h < 12) {
          h += 12;
        }
        if (isAM && h == 12) {
          h = 0;
        }

        // Nếu khớp giờ phút
        if (now.hour == h && now.minute == m) {
          _scheduleLastRunDates[schedule.id!] = dateStr;
          // Action mặc định của lịch trình là bật 15 phút (có thể mở rộng sau)
          if (!sensor.isPumpOn && sensor.pumpCountdownRemaining == 0) {
            sensor.startPumpWithTimer(15);
          }
        }
      }
    }
  }

  void _executeAction(String action, SensorViewModel sensor) {
    if (action.contains("phút") || action.contains("mins")) {
      final match = RegExp(r'(?:Bật|Turn on) \((\d+) (?:phút|mins)\)').firstMatch(action);
      if (match != null) {
        int mins = int.parse(match.group(1)!);
        if (!sensor.isPumpOn && sensor.pumpCountdownRemaining == 0) {
          sensor.startPumpWithTimer(mins);
        }
      }
    } else if (action == "Bật" || action == "Turn on") {
      if (!sensor.isPumpOn) {
        sensor.togglePump();
      }
    } else if (action == "Tắt" || action == "Turn off") {
      if (sensor.isPumpOn) {
        sensor.togglePump();
      }
    }
  }

  List<AutomationSchedule> get schedules => _schedules;
  List<AutomationTrigger> get triggers => _triggers;
  bool get isLoading => _isLoading;

  Future<void> fetchData(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final client = SupabaseService.client;
      final schedulesRes = await client.from('automation_schedules').select().eq('user_id', userId);
      final triggersRes = await client.from('automation_triggers').select().eq('user_id', userId);

      _schedules = (schedulesRes as List).map((e) => AutomationSchedule.fromJson(e)).toList();
      _triggers = (triggersRes as List).map((e) => AutomationTrigger.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Lỗi tải dữ liệu tự động hóa: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSchedule(AutomationSchedule schedule) async {
    try {
      final client = SupabaseService.client;
      final res = await client.from('automation_schedules').insert(schedule.toJson()).select().single();
      _schedules.add(AutomationSchedule.fromJson(res));
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi thêm schedule: $e");
    }
  }

  Future<void> addTrigger(AutomationTrigger trigger) async {
    try {
      final client = SupabaseService.client;
      final res = await client.from('automation_triggers').insert(trigger.toJson()).select().single();
      _triggers.add(AutomationTrigger.fromJson(res));
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi thêm trigger: $e");
    }
  }

  Future<void> toggleSchedule(int index) async {
    final current = _schedules[index];
    if (current.id == null) return;
    try {
      final client = SupabaseService.client;
      await client.from('automation_schedules').update({'is_enabled': !current.isEnabled}).eq('id', current.id!);
      _schedules[index] = AutomationSchedule(
        id: current.id,
        userId: current.userId,
        title: current.title,
        time: current.time,
        days: current.days,
        isEnabled: !current.isEnabled,
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi toggle schedule: $e");
    }
  }

  Future<void> toggleTrigger(int index) async {
    final current = _triggers[index];
    if (current.id == null) return;
    try {
      final client = SupabaseService.client;
      await client.from('automation_triggers').update({'is_enabled': !current.isEnabled}).eq('id', current.id!);
      _triggers[index] = AutomationTrigger(
        id: current.id,
        userId: current.userId,
        title: current.title,
        condition: current.condition,
        action: current.action,
        icon: current.icon,
        isEnabled: !current.isEnabled,
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi toggle trigger: $e");
    }
  }

  Future<void> deleteSchedule(int index) async {
    final current = _schedules[index];
    if (current.id == null) return;
    try {
      final client = SupabaseService.client;
      await client.from('automation_schedules').delete().eq('id', current.id!);
      _schedules.removeAt(index);
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi xóa schedule: $e");
    }
  }

  Future<void> deleteTrigger(int index) async {
    final current = _triggers[index];
    if (current.id == null) return;
    try {
      final client = SupabaseService.client;
      await client.from('automation_triggers').delete().eq('id', current.id!);
      _triggers.removeAt(index);
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi xóa trigger: $e");
    }
  }
}

