import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/automation_viewmodel.dart';

class AddScheduleView extends StatefulWidget {
  const AddScheduleView({super.key});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  bool _isScheduleEnabled = true;
  TimeOfDay _startTime = const TimeOfDay(hour: 6, minute: 0);
  final List<bool> _selectedDays = [true, false, true, false, true, false, false]; // Mon-Sun

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface.withValues(alpha: 0.7),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Thêm lịch trình mới",
          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image/Hero
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuC_MrAa_Sgd0DzgD72JRlJHq7nFpYUOAr3KvXjMXBvwGBLbCgznaKxdiDcsfGMNrVYzit_e1R8XJwIzV1mZM1-krA3f0Q6bq99ttu2_r4oOjRYNWyItBKLwgygvOmyGVpjnaSa5C0-xInqqHj2_RcGq7bGvDa7ZB1cQwzu976LIsk_rshEr7SWuh12lq5V0NICE1LzT2EmxSEmVXYSAG5OibosZpRINmzX5pnUrvU7kHTPx2i5rDoLnabB92u2TlwFsrLpXSfptIheb"),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Cấu hình tự động", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                      Text("Tối ưu hóa nguồn nước", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Cấu hình Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.schedule, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Kích hoạt lịch trình", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant)),
                            Text("Chế độ tự động hiện tại", style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _isScheduleEnabled,
                      onChanged: (val) => setState(() => _isScheduleEnabled = val),
                      activeThumbColor: AppTheme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Giờ bắt đầu
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("GIỜ BẮT ĐẦU", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant, letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(context: context, initialTime: _startTime);
                        if (time != null) setState(() => _startTime = time);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          border: Border.all(color: AppTheme.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _startTime.format(context),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Hệ thống sẽ tự động kích hoạt vào khung giờ này.", style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Ngày lặp lại
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("NGÀY LẶP LẠI", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        final days = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
                        final isSelected = _selectedDays[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedDays[index] = !isSelected);
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryContainer : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? AppTheme.primaryContainer : AppTheme.outlineVariant, width: 2),
                            ),
                            child: Text(
                              days[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48), // Padding bottom for button
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
            final daysLabels = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
            List<String> selected = [];
            for (int i = 0; i < 7; i++) {
              if (_selectedDays[i]) selected.add(daysLabels[i]);
            }
            String daysStr = selected.isEmpty ? "Không lặp" : selected.join(", ");
            
            vm.addSchedule(AutomationSchedule(
              title: "Lịch trình tùy chỉnh",
              time: _startTime.format(context),
              days: daysStr,
              isEnabled: _isScheduleEnabled,
            ));
            Navigator.pop(context);
          },
          icon: const Icon(Icons.check),
          label: const Text("Lưu lịch trình", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
}
