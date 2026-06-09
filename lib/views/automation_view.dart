import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AutomationView extends StatefulWidget {
  const AutomationView({super.key});

  @override
  State<AutomationView> createState() => _AutomationViewState();
}

class _AutomationViewState extends State<AutomationView> {
  bool isMorningWateringOn = true;
  bool isEveningWateringOn = false;
  bool isSoilMoistureTriggerOn = true;
  bool isCoolingTriggerOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant),
          onPressed: () {},
        ),
        title: const Text(
          "Cài đặt Tự động",
          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tabs Mock
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                          ]
                        ),
                        alignment: Alignment.center,
                        child: const Text("Lịch trình", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        child: const Text("Kích hoạt", style: TextStyle(color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Schedules Section
              const Text("Lịch trình đang hoạt động", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
              const SizedBox(height: 16),
              
              _buildAutomationCard(
                icon: Icons.water_drop,
                iconColor: AppTheme.primary,
                iconBgColor: AppTheme.secondaryContainer.withValues(alpha: 0.3),
                title: "Tưới nước buổi sáng",
                subtitle: "06:00 AM • T2, T4, T6",
                isOn: isMorningWateringOn,
                onToggle: (val) { setState(() { isMorningWateringOn = val; }); },
                actionLabel: "Thời lượng",
                actionValue: "15 phút",
              ),

              const SizedBox(height: 16),

              _buildAutomationCard(
                icon: Icons.nightlight,
                iconColor: AppTheme.onSurfaceVariant,
                iconBgColor: AppTheme.surfaceVariant.withValues(alpha: 0.5),
                title: "Tưới nước buổi tối",
                subtitle: "18:30 PM • Hàng ngày",
                isOn: isEveningWateringOn,
                onToggle: (val) { setState(() { isEveningWateringOn = val; }); },
                actionLabel: "Thời lượng",
                actionValue: "10 phút",
              ),

              const SizedBox(height: 32),

              // Triggers Section
              const Text("Kích hoạt theo Cảm biến", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
              const SizedBox(height: 16),

              _buildAutomationCard(
                icon: Icons.water,
                iconColor: AppTheme.primary,
                iconBgColor: AppTheme.secondaryContainer.withValues(alpha: 0.3),
                title: "Độ ẩm đất",
                subtitle: "Tưới khi < 45%",
                isOn: isSoilMoistureTriggerOn,
                onToggle: (val) { setState(() { isSoilMoistureTriggerOn = val; }); },
                actionLabel: "Hành động",
                actionValue: "Bật Bơm A (5 phút)",
              ),

              const SizedBox(height: 16),

              _buildAutomationCard(
                icon: Icons.device_thermostat,
                iconColor: AppTheme.primary,
                iconBgColor: AppTheme.secondaryContainer.withValues(alpha: 0.3),
                title: "Làm mát nhà kính",
                subtitle: "Kích hoạt khi > 32°C",
                isOn: isCoolingTriggerOn,
                onToggle: (val) { setState(() { isCoolingTriggerOn = val; }); },
                actionLabel: "Hành động",
                actionValue: "Mở quạt thông gió",
              ),

              const SizedBox(height: 80), // Padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutomationCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required bool isOn,
    required Function(bool) onToggle,
    required String actionLabel,
    required String actionValue,
  }) {
    return Opacity(
      opacity: isOn ? 1.0 : 0.7,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
                        Text(subtitle, style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: isOn,
                  onChanged: onToggle,
                  activeThumbColor: AppTheme.primary,
                  activeTrackColor: AppTheme.primaryContainer.withValues(alpha: 0.3),
                  inactiveThumbColor: AppTheme.onSurfaceVariant,
                  inactiveTrackColor: AppTheme.surfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppTheme.outlineVariant, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(actionLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant)),
                Text(actionValue, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.onSurface)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
