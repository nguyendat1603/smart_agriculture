class SensorModel {
  final double nhietDo;
  final double doAmKhongKhi;
  final double doAmDat;
  final double mucNuoc;
  final double doAmMua; // Biến DoAm (MH-RD) trên Firebase của bạn
  final DateTime timestamp; // Mốc thời gian để lọc log 15 phút

  SensorModel({
    required this.nhietDo,
    required this.doAmKhongKhi,
    required this.doAmDat,
    required this.mucNuoc,
    required this.doAmMua,
    required this.timestamp,
  });
}
