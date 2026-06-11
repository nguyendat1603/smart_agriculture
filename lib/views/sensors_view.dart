import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../viewmodels/sensor_viewmodel.dart';
import '../theme/app_theme.dart';
import '../viewmodels/settings_viewmodel.dart';

class SensorsView extends StatelessWidget {
  const SensorsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SensorViewModel>(context);

    final settingsVM = Provider.of<SettingsViewModel>(context);
    final isEn = settingsVM.isEnglish;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEn ? "Device Connection" : "Kết nối Thiết bị", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                  Text(isEn ? "Manage and monitor your agricultural IoT network." : "Quản lý và theo dõi mạng IoT nông nghiệp của bạn.", style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.sync, size: 18),
              label: Text(isEn ? "Scan" : "Quét"),
              style: ElevatedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                backgroundColor: AppTheme.surface,
                side: const BorderSide(color: AppTheme.outlineVariant),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: Text(isEn ? "Add" : "Thêm"),
              style: ElevatedButton.styleFrom(
                foregroundColor: AppTheme.onPrimary,
                backgroundColor: AppTheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Water Tank Card
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(
                      color: AppTheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.water_drop, color: AppTheme.onErrorContainer),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEn ? "Main Reservoir" : "Bồn chứa chính", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(isEn ? "Critical Level" : "Mức nguy hiểm", style: const TextStyle(fontSize: 12, color: AppTheme.error)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.more_vert, color: AppTheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 24),
              // Gauge
              SizedBox(
                width: 160,
                height: 160,
                child: CustomPaint(
                  painter: GaugePainter(percentage: vm.mucNuoc / 100.0, color: AppTheme.error),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${vm.mucNuoc.toInt()}%", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.error)),
                        Text(isEn ? "VOLUME" : "THỂ TÍCH", style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: AppTheme.surfaceVariant),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEn ? "Pump Status" : "Trạng thái Bơm", style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: vm.isPumpOn ? AppTheme.primary : AppTheme.outline, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(vm.isPumpOn ? (isEn ? "Running" : "Đang chạy") : (isEn ? "Stopped" : "Đã dừng"), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.onSurface)),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => vm.togglePump(),
                    icon: const Icon(Icons.power_settings_new),
                    label: Text(vm.isPumpOn ? (isEn ? "Stop" : "Tắt") : (isEn ? "Start" : "Bật")),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: vm.isPumpOn ? AppTheme.onError : AppTheme.onPrimary,
                      backgroundColor: vm.isPumpOn ? AppTheme.error : AppTheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.router, color: AppTheme.onSurface),
            const SizedBox(width: 8),
            Text(isEn ? "Active Network" : "Mạng hoạt động", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
          ],
        ),
        const SizedBox(height: 12),
        
        _buildDeviceRow(
          icon: Icons.hub,
          iconColor: AppTheme.primary,
          title: isEn ? "Field Gateway Alpha" : "Cổng kết nối Alpha",
          subtitle: isEn ? "Online • 192.168.1.10" : "Đang kết nối • 192.168.1.10",
          rightTop: isEn ? "Signal 98%" : "Tín hiệu 98%",
          rightBottom: isEn ? "Uptime: 45d" : "H.động: 45 ngày",
          isWarning: false,
        ),
        _buildDeviceRow(
          icon: Icons.grass,
          iconColor: AppTheme.tertiary,
          title: isEn ? "Soil Probe - Zone B" : "Cảm biến đất - Khu B",
          subtitle: "Online • LoRaWAN",
          rightTop: isEn ? "Battery 82%" : "Pin 82%",
          rightBottom: isEn ? "Sync: 2m ago" : "Đ.bộ: 2p trước",
          isWarning: false,
        ),
        _buildDeviceRow(
          icon: Icons.cloud,
          iconColor: AppTheme.secondary,
          title: isEn ? "Microclimate Station 1" : "Trạm khí hậu 1",
          subtitle: "Online • WiFi",
          rightTop: isEn ? "Charging" : "Đang sạc",
          rightBottom: isEn ? "Sync: Just now" : "Đ.bộ: Vừa xong",
          isWarning: false,
        ),
        _buildDeviceRow(
          icon: Icons.water,
          iconColor: AppTheme.error,
          title: isEn ? "Valve Controller C" : "Van điều khiển C",
          subtitle: isEn ? "Connection Lost" : "Mất kết nối",
          rightTop: isEn ? "Troubleshoot" : "Sửa lỗi",
          rightBottom: isEn ? "Last seen: 1h ago" : "H.động: 1h trước",
          isWarning: true,
        ),
      ],
    );
  }

  Widget _buildDeviceRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String rightTop,
    required String rightBottom,
    required bool isWarning,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning ? AppTheme.errorContainer.withValues(alpha: 0.3) : AppTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isWarning ? AppTheme.error.withValues(alpha: 0.3) : Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: isWarning ? AppTheme.errorContainer : AppTheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.onSurface)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(isWarning ? Icons.warning : Icons.check_circle, size: 14, color: isWarning ? AppTheme.error : AppTheme.primary),
                    const SizedBox(width: 4),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: isWarning ? AppTheme.error : AppTheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isWarning ? AppTheme.errorContainer : AppTheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(rightTop, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isWarning ? AppTheme.error : AppTheme.onSurfaceVariant)),
              ),
              const SizedBox(height: 4),
              Text(rightBottom, style: const TextStyle(fontSize: 12, color: AppTheme.outline)),
            ],
          ),
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double percentage;
  final Color color;

  GaugePainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = AppTheme.surfaceContainerHighest
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    
    canvas.drawCircle(center, radius, bgPaint);

    // Foreground arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;

    final sweepAngle = 2 * math.pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
