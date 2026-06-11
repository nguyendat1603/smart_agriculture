import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/automation_viewmodel.dart';

class AutomationView extends StatefulWidget {
  const AutomationView({super.key});

  @override
  State<AutomationView> createState() => _AutomationViewState();
}

class _AutomationViewState extends State<AutomationView> {
  int _selectedTab = 0; // 0: Lịch trình, 1: Kích hoạt

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AutomationViewModel>();

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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_selectedTab == 0) {
            Navigator.pushNamed(context, '/add_schedule');
          } else {
            Navigator.pushNamed(context, '/add_trigger');
          }
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
        icon: const Icon(Icons.add),
        label: Text(
          _selectedTab == 0 ? "Thêm lịch trình mới" : "Thêm kích hoạt mới",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? AppTheme.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTab == 0 ? [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                            ] : null,
                          ),
                          alignment: Alignment.center,
                          child: Text("Lịch trình", style: TextStyle(color: _selectedTab == 0 ? AppTheme.primary : AppTheme.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? AppTheme.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTab == 1 ? [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                            ] : null,
                          ),
                          alignment: Alignment.center,
                          child: Text("Kích hoạt", style: TextStyle(color: _selectedTab == 1 ? AppTheme.primary : AppTheme.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (_selectedTab == 0) ...[
                // Schedules Section
                const Text("Lịch trình đang hoạt động", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                const SizedBox(height: 16),
                
                ...vm.schedules.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var schedule = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildAutomationCard(
                      icon: Icons.schedule,
                      iconColor: AppTheme.primary,
                      iconBgColor: AppTheme.primaryContainer.withValues(alpha: 0.2),
                      title: schedule.title,
                      subtitle: schedule.days,
                      isOn: schedule.isEnabled,
                      onToggle: (val) { vm.toggleSchedule(idx); },
                      actionLabel: "Giờ kích hoạt",
                      actionValue: schedule.time,
                    ),
                  );
                }),
              ],

              if (_selectedTab == 1) ...[
                // Triggers Section
                const Text("Kích hoạt theo Cảm biến", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                const SizedBox(height: 16),

                ...vm.triggers.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var trigger = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildAutomationCard(
                      icon: trigger.icon,
                      iconColor: AppTheme.primary,
                      iconBgColor: AppTheme.secondaryContainer.withValues(alpha: 0.3),
                      title: trigger.title,
                      subtitle: trigger.condition,
                      isOn: trigger.isEnabled,
                      onToggle: (val) { vm.toggleTrigger(idx); },
                      actionLabel: "Hành động",
                      actionValue: trigger.action,
                    ),
                  );
                }),
              ],

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
