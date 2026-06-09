import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../viewmodels/sensor_viewmodel.dart';
import '../theme/app_theme.dart';

class SensorsView extends StatelessWidget {
  const SensorsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SensorViewModel>(context);

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
                children: const [
                  Text("Device Connection", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                  Text("Manage and monitor your agricultural IoT network.", style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
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
              label: const Text("Scan"),
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
              label: const Text("Add"),
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
                      const Text("Main Reservoir", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text("Critical Level", style: TextStyle(fontSize: 12, color: AppTheme.error)),
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
                        const Text("VOLUME", style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
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
                      const Text("Pump Status", style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: vm.isPumpOn ? AppTheme.primary : AppTheme.outline, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(vm.isPumpOn ? "Running" : "Stopped", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.onSurface)),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => vm.togglePump(),
                    icon: const Icon(Icons.power_settings_new),
                    label: Text(vm.isPumpOn ? "Stop" : "Start"),
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
          children: const [
            Icon(Icons.router, color: AppTheme.onSurface),
            SizedBox(width: 8),
            Text("Active Network", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
          ],
        ),
        const SizedBox(height: 12),
        
        _buildDeviceRow(
          icon: Icons.hub,
          iconColor: AppTheme.primary,
          title: "Field Gateway Alpha",
          subtitle: "Online • 192.168.1.10",
          rightTop: "Signal 98%",
          rightBottom: "Uptime: 45d",
          isWarning: false,
        ),
        _buildDeviceRow(
          icon: Icons.grass,
          iconColor: AppTheme.tertiary,
          title: "Soil Probe - Zone B",
          subtitle: "Online • LoRaWAN",
          rightTop: "Battery 82%",
          rightBottom: "Sync: 2m ago",
          isWarning: false,
        ),
        _buildDeviceRow(
          icon: Icons.cloud,
          iconColor: AppTheme.secondary,
          title: "Microclimate Station 1",
          subtitle: "Online • WiFi",
          rightTop: "Charging",
          rightBottom: "Sync: Just now",
          isWarning: false,
        ),
        _buildDeviceRow(
          icon: Icons.water,
          iconColor: AppTheme.error,
          title: "Valve Controller C",
          subtitle: "Connection Lost",
          rightTop: "Troubleshoot",
          rightBottom: "Last seen: 1h ago",
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
