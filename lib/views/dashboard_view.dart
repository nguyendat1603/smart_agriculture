import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../viewmodels/sensor_viewmodel.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe dữ liệu thay đổi từ ViewModel
    final vm = Provider.of<SensorViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Giám sát cây trồng"),
        backgroundColor: Colors.green,
        actions: [
          // Hiển thị Icon thời tiết mưa/nắng tự động theo nghiệp vụ 1
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              vm.isRaining ? Icons.thunderstorm : Icons.wb_sunny,
              color: vm.isRaining ? Colors.blue : Colors.yellow,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ---- KHU VỰC HIỂN THỊ CÁC THẺ TRẠNG THÁI HIỆN TẠI ----
            Row(
              children: [
                // Thẻ Độ ẩm đất đổi màu theo 3 vùng nghiệp vụ
                Expanded(
                  child: Card(
                    color: vm.soilColor.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: vm.soilColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            "Độ Ẩm Đất: ${vm.doAmDat}%",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            vm.soilStatus,
                            style: TextStyle(
                              color: vm.soilColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // NGHIỆP VỤ 3: TÌNH TRẠNG MỨC NƯỚC BỒN CHỨA
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mực nước bồn chứa: ${vm.mucNuoc}%",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: vm.mucNuoc / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        vm.mucNuoc == 0 ? Colors.red : Colors.blue,
                      ),
                      minHeight: 15,
                    ),
                    if (vm.mucNuoc == 0)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          "CẠN NƯỚC",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ---- NGHIỆP VỤ BIỂU ĐỒ CỘT 100 CHỨA CÁC THUỘC TÍNH (15 PHÚT) ----
            const Text(
              "Sơ đồ thuộc tính trong 15 phút qua (Thang 100)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  maxY: 100, // Chia theo dải cột tối đa 100 chuẩn chỉ
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: vm.nhietDo,
                          color: Colors.orange,
                          width: 15,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: vm.doAmKhongKhi,
                          color: Colors.blue,
                          width: 15,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: vm.doAmDat,
                          color: vm.soilColor,
                          width: 15,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: vm.mucNuoc,
                          color: Colors.teal,
                          width: 15,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(
                          toY: vm.doAmMua,
                          color: Colors.indigo,
                          width: 15,
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Nhiệt độ');
                            case 1:
                              return const Text('Ẩm khí');
                            case 2:
                              return const Text('Ẩm đất');
                            case 3:
                              return const Text('Mực nước');
                            case 4:
                              return const Text('Ẩm mưa');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // ---- ĐIỀU KHIỂN MÁY BƠM TỰ ĐỘNG + CHẶN LOCKOUT ----
            ElevatedButton.icon(
              icon: const Icon(Icons.water_drop),
              label: const Text("KÍCH HOẠT MÁY BƠM TỰ ĐỘNG"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                if (!vm.canTurnOnPump()) {
                  // Nghiệp vụ chặn điều khiển: Bật Pop-up khẩn cấp nếu bồn cạn
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Cảnh Báo Hệ Thống"),
                      content: const Text(
                        "Không thể bật máy bơm do bồn chứa đã hết nước. Vui lòng bơm nước vào bồn trước để tránh cháy máy.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Đã hiểu"),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Thực hiện bật bơm bình thường
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
