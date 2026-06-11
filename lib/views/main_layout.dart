import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import 'dashboard_view.dart';
import 'automation_view.dart';
import 'sensors_view.dart';
import 'settings_view.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/automation_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      final userId = authVm.currentUser?.id;
      if (userId != null) {
        context.read<AutomationViewModel>().fetchData(userId);
      }
    });
  }

  final List<Widget> _views = [
    const DashboardView(),
    const SensorsView(),
    const AutomationView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppTheme.primary,
              unselectedItemColor: AppTheme.onSurfaceVariant,
              selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
              items: [
                _buildNavItem(Icons.dashboard, context.watch<SettingsViewModel>().isEnglish ? "Dashboard" : "Tổng quan", 0),
                _buildNavItem(Icons.sensors, context.watch<SettingsViewModel>().isEnglish ? "Sensors" : "Cảm biến", 1),
                _buildNavItem(Icons.precision_manufacturing, context.watch<SettingsViewModel>().isEnglish ? "Automation" : "Tự động", 2),
                _buildNavItem(Icons.settings, context.watch<SettingsViewModel>().isEnglish ? "Settings" : "Cài đặt", 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondaryContainer.withValues(alpha: 0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}
