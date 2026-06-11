import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/automation_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class AddTriggerView extends StatefulWidget {
  const AddTriggerView({super.key});

  @override
  State<AddTriggerView> createState() => _AddTriggerViewState();
}

class _AddTriggerViewState extends State<AddTriggerView> {
  int _selectedDeviceType = 0; // 0: Quạt gió, 1: Đèn QH, 2: Tưới tiêu
  String _selectedSensor = 'temp'; // temp, soil, light
  String _selectedOperator = 'gt'; // gt, lt, eq
  double _thresholdValue = 30.0;
  String _selectedAction = 'on_duration'; // on_duration, on, off
  int _durationMinutes = 10;
  bool _isDaytimeOnly = true;

  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<SettingsViewModel>();
    final tempUnit = settingsVM.tempUnit;
    
    // Dynamic max/min for slider based on unit
    double minSlider = 0;
    double maxSlider = 50;
    if (tempUnit == 'F') {
      minSlider = 32;
      maxSlider = 122;
      // Adjust threshold if it's out of bounds
      if (_thresholdValue < minSlider) _thresholdValue = minSlider;
      if (_thresholdValue > maxSlider) _thresholdValue = maxSlider;
    } else if (tempUnit == 'K') {
      minSlider = 273.15;
      maxSlider = 323.15;
      if (_thresholdValue < minSlider) _thresholdValue = minSlider;
      if (_thresholdValue > maxSlider) _thresholdValue = maxSlider;
    } else {
      if (_thresholdValue > 50) _thresholdValue = 50;
      if (_thresholdValue < 0) _thresholdValue = 0;
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface.withValues(alpha: 0.7),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          settingsVM.isEnglish ? "Add New Trigger" : "Thêm kích hoạt mới",
          style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loại thiết bị
              Text(settingsVM.isEnglish ? "Device Type" : "Loại thiết bị", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
              const SizedBox(height: 4),
              Text(settingsVM.isEnglish ? "Select the device to automate." : "Chọn thiết bị bạn muốn điều khiển tự động.", style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildDeviceOption(0, Icons.mode_fan_off, settingsVM.isEnglish ? "Fan" : "Quạt gió"),
                  const SizedBox(width: 12),
                  _buildDeviceOption(1, Icons.lightbulb_outline, settingsVM.isEnglish ? "Light" : "Đèn QH"),
                  const SizedBox(width: 12),
                  _buildDeviceOption(2, Icons.water_drop_outlined, settingsVM.isEnglish ? "Pump" : "Tưới tiêu"),
                ],
              ),
              const SizedBox(height: 24),
              
              // Điều kiện kích hoạt
              _buildSectionCard(
                title: settingsVM.isEnglish ? "Trigger Condition" : "Điều kiện kích hoạt",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(settingsVM.isEnglish ? "Sensor" : "Cảm biến", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedSensor,
                      items: [
                        DropdownMenuItem(value: 'temp', child: Text(settingsVM.isEnglish ? "Environment Temp" : "Nhiệt độ môi trường")),
                        DropdownMenuItem(value: 'soil', child: Text(settingsVM.isEnglish ? "Soil Moisture" : "Độ ẩm đất")),
                        DropdownMenuItem(value: 'light', child: Text(settingsVM.isEnglish ? "Light Intensity" : "Cường độ ánh sáng")),
                      ],
                      onChanged: (val) => setState(() => _selectedSensor = val as String),
                    ),
                    const SizedBox(height: 16),
                    Text(settingsVM.isEnglish ? "Threshold" : "Ngưỡng kích hoạt", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildDropdown(
                            value: _selectedOperator,
                            items: [
                              DropdownMenuItem(value: 'gt', child: Text(settingsVM.isEnglish ? "> (Greater)" : "> (Lớn hơn)")),
                              DropdownMenuItem(value: 'lt', child: Text(settingsVM.isEnglish ? "< (Less)" : "< (Nhỏ hơn)")),
                              DropdownMenuItem(value: 'eq', child: Text(settingsVM.isEnglish ? "= (Equal)" : "= (Bằng)")),
                            ],
                            onChanged: (val) => setState(() => _selectedOperator = val as String),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLowest,
                              border: Border.all(color: AppTheme.outlineVariant),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_thresholdValue.toInt().toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
                                Text("°$tempUnit", style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _thresholdValue,
                      min: minSlider,
                      max: maxSlider,
                      activeColor: AppTheme.primary,
                      inactiveColor: AppTheme.surfaceVariant,
                      onChanged: (val) => setState(() => _thresholdValue = val),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${minSlider.toInt()}°$tempUnit", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant)),
                        Text("${maxSlider.toInt()}°$tempUnit", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: AppTheme.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              settingsVM.isEnglish 
                                ? "Trigger when ${_selectedSensor == 'temp' ? 'Temperature' : (_selectedSensor == 'soil' ? 'Soil Moisture' : 'Light')} ${_selectedOperator == 'gt' ? '>' : '<'} ${_thresholdValue.toInt()} ${_selectedSensor == 'temp' ? '°$tempUnit' : '%'}"
                                : "Kích hoạt khi ${_selectedSensor == 'temp' ? 'Nhiệt độ môi trường' : (_selectedSensor == 'soil' ? 'Độ ẩm đất' : 'Cường độ sáng')} ${_selectedOperator == 'gt' ? '>' : '<'} ${_thresholdValue.toInt()} ${_selectedSensor == 'temp' ? '°$tempUnit' : '%'}",
                              style: const TextStyle(fontSize: 14, color: AppTheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Hành động
              _buildSectionCard(
                title: settingsVM.isEnglish ? "Action" : "Hành động",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(settingsVM.isEnglish ? "Execution Command" : "Lệnh thực thi", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedAction,
                      items: [
                        DropdownMenuItem(value: 'on_duration', child: Text(settingsVM.isEnglish ? "Turn on for duration" : "Bật trong thời gian định trước")),
                        DropdownMenuItem(value: 'on', child: Text(settingsVM.isEnglish ? "Turn on (Hold)" : "Bật (Giữ nguyên)")),
                        DropdownMenuItem(value: 'off', child: Text(settingsVM.isEnglish ? "Turn off" : "Tắt")),
                      ],
                      onChanged: (val) => setState(() => _selectedAction = val as String),
                    ),
                    const SizedBox(height: 16),
                    Text(settingsVM.isEnglish ? "Run Duration (Minutes)" : "Thời gian chạy (Phút)", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_durationMinutes > 1) setState(() => _durationMinutes--);
                          },
                          icon: const Icon(Icons.remove),
                          style: IconButton.styleFrom(backgroundColor: AppTheme.surfaceContainerHigh),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLowest,
                              border: Border.all(color: AppTheme.outlineVariant),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text("$_durationMinutes", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => _durationMinutes++);
                          },
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(backgroundColor: AppTheme.surfaceContainerHigh),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Giới hạn thời gian
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceVariant),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(settingsVM.isEnglish ? "Time Limit" : "Giới hạn thời gian", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
                        const SizedBox(height: 4),
                        Text(settingsVM.isEnglish ? "Daytime only (06:00 - 18:00)" : "Chỉ chạy ban ngày (06:00 - 18:00)", style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                    Switch(
                      value: _isDaytimeOnly,
                      onChanged: (val) => setState(() => _isDaytimeOnly = val),
                      activeThumbColor: AppTheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          border: const Border(top: BorderSide(color: AppTheme.surfaceVariant)),
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            final vm = context.read<AutomationViewModel>();
            String deviceName = _selectedDeviceType == 0 ? (settingsVM.isEnglish ? "Fan" : "Quạt gió") : (_selectedDeviceType == 1 ? (settingsVM.isEnglish ? "Light" : "Đèn QH") : (settingsVM.isEnglish ? "Pump" : "Tưới tiêu"));
            IconData icon = _selectedDeviceType == 0 ? Icons.mode_fan_off : (_selectedDeviceType == 1 ? Icons.lightbulb_outline : Icons.water_drop_outlined);
            
            String sensorName = _selectedSensor == 'temp' ? (settingsVM.isEnglish ? "Temperature" : "Nhiệt độ") : (_selectedSensor == 'soil' ? (settingsVM.isEnglish ? "Soil Moisture" : "Độ ẩm đất") : (settingsVM.isEnglish ? "Light" : "Cường độ sáng"));
            String opName = _selectedOperator == 'gt' ? ">" : (_selectedOperator == 'lt' ? "<" : "=");
            String cond = settingsVM.isEnglish ? "Trigger when $sensorName $opName ${_thresholdValue.toInt()}" : "Kích hoạt khi $sensorName $opName ${_thresholdValue.toInt()}";
            
            String actionName = _selectedAction == 'on_duration' ? (settingsVM.isEnglish ? "Turn on ($_durationMinutes mins)" : "Bật ($_durationMinutes phút)") : (_selectedAction == 'on' ? (settingsVM.isEnglish ? "Turn on" : "Bật") : (settingsVM.isEnglish ? "Turn off" : "Tắt"));

            final authVm = context.read<AuthViewModel>();
            final userId = authVm.currentUser?.id ?? '';

            vm.addTrigger(AutomationTrigger(
              userId: userId,
              title: deviceName,
              condition: cond,
              action: actionName,
              isEnabled: true,
              icon: icon,
            ));
            Navigator.pop(context);
          },
          icon: const Icon(Icons.save),
          label: Text(settingsVM.isEnglish ? "Save Trigger" : "Lưu kích hoạt", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            foregroundColor: AppTheme.onPrimary,
            backgroundColor: AppTheme.primary,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceOption(int index, IconData icon, String label) {
    bool isSelected = _selectedDeviceType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDeviceType = index),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant, width: isSelected ? 2 : 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryContainer : AppTheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isSelected ? AppTheme.onPrimaryContainer : AppTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppTheme.onSurface : AppTheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceVariant),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
          const SizedBox(height: 8),
          const Divider(color: AppTheme.surfaceVariant),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        border: Border.all(color: AppTheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: AppTheme.onSurfaceVariant),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
