import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_model.dart';

class SensorViewModel extends ChangeNotifier {
  // Biến lưu trữ số liệu hiện tại
  double _nhietDo = 0.0;
  double _doAmKhongKhi = 0.0;
  double _doAmDat = 0.0;
  double _mucNuoc = 0.0;
  double _doAmMua = 0.0;
  // Thêm 1 biến vào phần khai báo đầu class SensorViewModel
  bool _isPumpOn = false;
  bool get isPumpOn => _isPumpOn;

  int _pumpCountdownRemaining = 0;
  int get pumpCountdownRemaining => _pumpCountdownRemaining;
  Timer? _pumpAutomationTimer;

  bool isRaining = false;
  Timer? _rainTimer;

  // Mảng chứa tối đa 90 bản ghi lịch sử phục vụ biểu đồ dịch chuyển
  final List<SensorModel> _historyLogs = [];

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  double get nhietDo => _nhietDo;
  double get doAmKhongKhi => _doAmKhongKhi;
  double get doAmDat => _doAmDat;
  double get mucNuoc => _mucNuoc;
  double get doAmMua => _doAmMua;
  List<SensorModel> get historyLogs => _historyLogs;

  DateTime? _lastLogTime;

  SensorViewModel() {
    _listenToRealtimeData();
  }

  // Lắng nghe dữ liệu tức thời để cập nhật các thẻ trạng thái
  void _listenToRealtimeData() {
    _dbRef
        .child("NongNghiep")
        .onValue
        .listen(
          (DatabaseEvent event) {
            final data = event.snapshot.value;

            if (data is Map) {
              double parseValue(dynamic val) {
                if (val == null) return 0.0;
                return double.tryParse(val.toString()) ?? 0.0;
              }

              _nhietDo = parseValue(data['NhietDo']);
              _doAmKhongKhi = parseValue(data['DoAmKhongKhi']);
              _doAmDat = parseValue(data['DoAmDat']);
              _mucNuoc = parseValue(data['MucNuoc']);
              _doAmMua = parseValue(data['DoAm']);

              // -- THÊM DÒNG NÀY ĐỂ ĐỌC TRẠNG THÁI MÁY BƠM --
              _isPumpOn =
                  data['TrangThaiBom'] ==
                  true; // Nếu Firebase trả về true thì gán true
                  
              if (!_isPumpOn && _pumpAutomationTimer != null) {
                _pumpAutomationTimer?.cancel();
                _pumpAutomationTimer = null;
                _pumpCountdownRemaining = 0;
              }

              _handleRainLogic();
              
              // Cập nhật lịch sử biểu đồ (giới hạn 10 giây/lần)
              final now = DateTime.now();
              if (_lastLogTime == null || now.difference(_lastLogTime!).inSeconds >= 10) {
                _lastLogTime = now;
                _historyLogs.add(SensorModel(
                  nhietDo: _nhietDo,
                  doAmKhongKhi: _doAmKhongKhi,
                  doAmDat: _doAmDat,
                  mucNuoc: _mucNuoc,
                  doAmMua: _doAmMua,
                  timestamp: now,
                ));
                if (_historyLogs.length > 90) {
                  _historyLogs.removeAt(0);
                }
              }

              notifyListeners();
            }
          },
          onError: (error) {
            debugPrint("Lỗi kết nối Firebase Realtime Database: $error");
          },
        );
  }


  void _handleRainLogic() {
    if (_doAmMua > 10.0) {
      if (_rainTimer == null && !isRaining) {
        _rainTimer = Timer(const Duration(minutes: 1), () {
          isRaining = true;
          notifyListeners();
        });
      }
    } else {
      _rainTimer?.cancel();
      _rainTimer = null;
      if (isRaining) {
        isRaining = false;
      }
    }
  }

  String get soilStatus {
    if (_doAmDat >= 60.0 && _doAmDat <= 80.0) return "TỐT";
    if (_doAmDat >= 25.0 && _doAmDat < 60.0) return "BẮT ĐẦU KHÔ";
    return "NGUY HIỂM";
  }

  Color get soilColor {
    if (soilStatus == "TỐT") return Colors.green;
    if (soilStatus == "BẮT ĐẦU KHÔ") return Colors.orange;
    return Colors.red;
  }

  bool canTurnOnPump() {
    return _mucNuoc > 0.0;
  }

  Future<void> togglePump() async {
    // Chỉ cho phép bật nếu mức nước > 0. Nếu đang bật rồi thì luôn cho phép ấn để tắt.
    if (canTurnOnPump() || _isPumpOn) {
      bool newState =
          !_isPumpOn; // Đảo trạng thái hiện tại (Đang Tắt thì thành Bật)

      // Ghi đè trạng thái mới lên Firebase
      await _dbRef.child("NongNghiep").update({"TrangThaiBom": newState});
      
      if (!newState) {
        _pumpAutomationTimer?.cancel();
        _pumpAutomationTimer = null;
        _pumpCountdownRemaining = 0;
        // Giao diện sẽ tự cập nhật do stream listener Firebase thay đổi
      }

      // Lưu ý: Không cần gọi notifyListeners() ở đây vì hàm _listenToRealtimeData()
      // sẽ tự động phát hiện Firebase vừa bị thay đổi và cập nhật lại giao diện.
    }
  }

  Future<void> startPumpWithTimer(int minutes) async {
    if (canTurnOnPump() || _isPumpOn) {
      if (!_isPumpOn) {
        await togglePump(); // Bật máy bơm
      }
      _pumpCountdownRemaining = minutes * 60;
      _pumpAutomationTimer?.cancel();
      _pumpAutomationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_pumpCountdownRemaining > 0) {
          _pumpCountdownRemaining--;
          notifyListeners();
        } else {
          _pumpAutomationTimer?.cancel();
          _pumpAutomationTimer = null;
          if (_isPumpOn) {
            togglePump(); // Tắt máy bơm khi hết thời gian
          }
        }
      });
      notifyListeners();
    }
  }
}
