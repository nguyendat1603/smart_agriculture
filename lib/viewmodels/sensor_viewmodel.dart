import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_model.dart';

class SensorViewModel extends ChangeNotifier {
  // Cấu hình các biến lưu trữ cục bộ trên giao diện
  double _nhietDo = 0.0;
  double _doAmKhongKhi = 0.0;
  double _doAmDat = 0.0;
  double _mucNuoc = 0.0;
  double _doAmMua = 0.0;

  bool isRaining = false;
  Timer? _rainTimer;
  final List<SensorModel> _historyLogs = [];

  // Khởi tạo tham chiếu đến nút dữ liệu gốc trên Firebase của bạn
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("NongNghiep");

  // Getters để giao diện Dashboard kết nối lấy dữ liệu
  double get nhietDo => _nhietDo;
  double get doAmKhongKhi => _doAmKhongKhi;
  double get doAmDat => _doAmDat;
  double get mucNuoc => _mucNuoc;
  double get doAmMua => _doAmMua;
  List<SensorModel> get historyLogs => _historyLogs;

  SensorViewModel() {
    // Kích hoạt lắng nghe dữ liệu thời gian thực từ Firebase ngay khi khởi động app
    _listenToFirebaseRealtime();
  }

  void _listenToFirebaseRealtime() {
    _dbRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        // Ép kiểu dữ liệu an toàn tránh lỗi crash nếu Firebase trả về dạng int thay vì double
        double parseValue(dynamic val) {
          if (val == null) return 0.0;
          return double.tryParse(val.toString()) ?? 0.0;
        }

        // Đọc chính xác các Key từ dữ liệu gốc Firebase của bạn
        _updateSensorData(
          nhietDo: parseValue(data['NhietDo']),
          doAmKhongKhi: parseValue(data['DoAmKhongKhi']),
          doAmDat: parseValue(data['DoAmDat']),
          mucNuoc: parseValue(data['MucNuoc']),
          doAmMua: parseValue(
            data['DoAm'],
          ), // 'DoAm' trên Firebase của bạn là cảm biến mưa
        );
      }
    }, onError: (error) {
      debugPrint("Lỗi kết nối Firebase Realtime Database: $error");
    });
  }

  void _updateSensorData({
    required double nhietDo,
    required double doAmKhongKhi,
    required double doAmDat,
    required double mucNuoc,
    required double doAmMua,
  }) {
    _nhietDo = nhietDo;
    _doAmKhongKhi = doAmKhongKhi;
    _doAmDat = doAmDat;
    _mucNuoc = mucNuoc;
    _doAmMua = doAmMua;

    DateTime now = DateTime.now();

    // NGHIỆP VỤ 1: Đệm thời gian phát hiện trời mưa (1 phút liên tục)
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

    // NGHIỆP VỤ 2: Ghi nhật ký tiến trình cuốn chiếu trong dải 15 phút
    _historyLogs.add(
      SensorModel(
        nhietDo: _nhietDo,
        doAmKhongKhi: _doAmKhongKhi,
        doAmDat: _doAmDat,
        mucNuoc: _mucNuoc,
        doAmMua: _doAmMua,
        timestamp: now,
      ),
    );

    // Giải phóng bộ nhớ, xóa bỏ các bản ghi cũ hơn 15 phút trước
    _historyLogs.removeWhere(
      (log) => now.difference(log.timestamp).inMinutes > 15,
    );

    // Phát lệnh cho toàn bộ Widget giao diện (Thẻ trạng thái + Biểu đồ cột) cập nhật lại số liệu
    notifyListeners();
  }

  // Phân vùng màu sắc độ ẩm đất theo tài liệu nghiệp vụ
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
}
