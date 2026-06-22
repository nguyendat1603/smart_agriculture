import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../viewmodels/sensor_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../theme/app_theme.dart';
import '../l10n/app_translations.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  Widget _buildMicroChart(List<FlSpot> spots, Color color) {
    if (spots.isEmpty) return const SizedBox();
    
    double minX = 0;
    double maxX = spots.length > 1 ? (spots.length - 1).toDouble() : 1.0;
    
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: minX,
        maxX: maxX,
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String statusText,
    required Color statusColor,
    required String value,
    required String unit,
    required String trendStr,
    required IconData trendIcon,
    required List<FlSpot> chartSpots,
  }) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
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
                      color: AppTheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(icon, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(statusText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: statusColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: iconColor)),
                      Text(unit, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(trendIcon, size: 14, color: AppTheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(trendStr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 120,
                height: 60,
                child: _buildMicroChart(chartSpots, iconColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SensorViewModel>(context);
    final settingsVM = Provider.of<SettingsViewModel>(context);

    List<FlSpot> tempSpots = [];
    List<FlSpot> airHumidSpots = [];
    List<FlSpot> soilHumidSpots = [];
    List<FlSpot> waterLevelSpots = [];
    List<FlSpot> rainSpots = [];

    for (int i = 0; i < vm.historyLogs.length; i++) {
      final log = vm.historyLogs[i];
      tempSpots.add(FlSpot(i.toDouble(), log.nhietDo));
      airHumidSpots.add(FlSpot(i.toDouble(), log.doAmKhongKhi));
      soilHumidSpots.add(FlSpot(i.toDouble(), log.doAmDat));
      waterLevelSpots.add(FlSpot(i.toDouble(), log.mucNuoc));
      rainSpots.add(FlSpot(i.toDouble(), log.doAmMua));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Live Sensor Data".tr(context), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                const SizedBox(height: 4),
                Text("Real-time monitoring across all field zones.".tr(context), style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: settingsVM.tempUnit,
                  items: const [
                    DropdownMenuItem(value: 'C', child: Text('°C')),
                    DropdownMenuItem(value: 'F', child: Text('°F')),
                    DropdownMenuItem(value: 'K', child: Text('°K')),
                  ],
                  onChanged: (val) {
                    if (val != null) settingsVM.setTempUnit(val);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Nút truy cập AI Phân Tích Sức Khỏe
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/health_analysis');
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.document_scanner, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AI Health Analysis".tr(context),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Scan plant images for diseases".tr(context),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        _buildSensorCard(
          icon: Icons.water_drop,
          iconColor: AppTheme.secondary,
          title: "Air Humidity".tr(context),
          subtitle: "Optimal: 60-70%".tr(context),
          statusText: vm.doAmKhongKhi >= 60 && vm.doAmKhongKhi <= 70 ? "Healthy".tr(context) : "Warning".tr(context),
          statusColor: vm.doAmKhongKhi >= 60 && vm.doAmKhongKhi <= 70 ? AppTheme.secondary : AppTheme.error,
          value: vm.doAmKhongKhi.toStringAsFixed(1),
          unit: "%",
          trendStr: "Dynamic Realtime".tr(context),
          trendIcon: Icons.show_chart,
          chartSpots: airHumidSpots,
        ),
        
        _buildSensorCard(
          icon: Icons.thermostat,
          iconColor: AppTheme.error,
          title: "Temperature".tr(context),
          subtitle: "Optimal: 22-26°C".tr(context),
          statusText: vm.nhietDo > 26 ? "Elevated".tr(context) : (vm.nhietDo < 22 ? "Cold".tr(context) : "Optimal".tr(context)),
          statusColor: vm.nhietDo > 26 ? AppTheme.error : AppTheme.tertiary,
          value: settingsVM.formatTemperature(vm.nhietDo).replaceAll(RegExp(r'°[CFK]'), ''),
          unit: "°${settingsVM.tempUnit}",
          trendStr: "Dynamic Realtime".tr(context),
          trendIcon: Icons.show_chart,
          chartSpots: tempSpots,
        ),

        _buildSensorCard(
          icon: Icons.grass,
          iconColor: AppTheme.primaryContainer,
          title: "Soil Moisture".tr(context),
          subtitle: "Optimal: 40-50%".tr(context),
          statusText: vm.doAmDat < 40 ? "Dry".tr(context) : "Healthy".tr(context),
          statusColor: vm.doAmDat < 40 ? Colors.orange : AppTheme.primary,
          value: vm.doAmDat.toStringAsFixed(1),
          unit: "%",
          trendStr: "Dynamic Realtime".tr(context),
          trendIcon: Icons.show_chart,
          chartSpots: soilHumidSpots,
        ),

        _buildSensorCard(
          icon: Icons.waves,
          iconColor: Colors.blue.shade700,
          title: "Water Tank Level".tr(context),
          subtitle: "Capacity: 10,000L".tr(context),
          statusText: vm.mucNuoc < 20 ? "Low Level".tr(context) : "Normal".tr(context),
          statusColor: vm.mucNuoc < 20 ? AppTheme.error : Colors.blue.shade700,
          value: vm.mucNuoc.toStringAsFixed(1),
          unit: "%",
          trendStr: "Dynamic Realtime".tr(context),
          trendIcon: Icons.show_chart,
          chartSpots: waterLevelSpots,
        ),

        _buildSensorCard(
          icon: Icons.water_drop_outlined,
          iconColor: Colors.indigo,
          title: "Rain Sensor".tr(context),
          subtitle: "Rain: >10%".tr(context),
          statusText: vm.doAmMua > 10 ? "Raining".tr(context) : "Clear".tr(context),
          statusColor: vm.doAmMua > 10 ? Colors.indigo : AppTheme.onSurfaceVariant,
          value: vm.doAmMua.toStringAsFixed(1),
          unit: "%",
          trendStr: "Dynamic Realtime".tr(context),
          trendIcon: Icons.show_chart,
          chartSpots: rainSpots,
        ),
      ],
    );
  }
}
