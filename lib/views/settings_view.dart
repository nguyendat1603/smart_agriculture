import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVM = context.watch<AuthViewModel>();
    final settingsVM = context.watch<SettingsViewModel>();
    final user = authVM.currentUser;
    final isEnglish = settingsVM.isEnglish;
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface.withValues(alpha: 0.7),
        elevation: 0,
        centerTitle: true,
        title: Text(
          isEnglish ? 'Settings' : 'Cài đặt',
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.primary),
            onPressed: () {},
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100), // padding bottom for nav bar
        children: [
          // User Profile Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryContainer.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        image: user?.avatarUrl.isNotEmpty == true
                            ? DecorationImage(
                                image: NetworkImage(user!.avatarUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: user?.avatarUrl.isNotEmpty == true 
                          ? null 
                          : const Center(
                              child: Icon(Icons.person, size: 32, color: AppTheme.primary),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? (isEnglish ? 'User' : 'Người dùng'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.role ?? (isEnglish ? 'Unknown' : 'Chưa xác định'),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit_profile');
                  },
                  icon: const Icon(Icons.edit, color: AppTheme.onSecondaryContainer),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.secondaryContainer,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // TÀI KHOẢN
          _buildSectionHeader(isEnglish ? 'ACCOUNT' : 'TÀI KHOẢN'),
          _buildSettingsGroup([
            _buildSettingsItem(
              icon: Icons.person,
              title: isEnglish ? 'Personal Information' : 'Thông tin cá nhân',
              onTap: () {
                Navigator.pushNamed(context, '/edit_profile');
              },
            ),
            _buildSettingsItem(
              icon: Icons.lock,
              title: isEnglish ? 'Security & Password' : 'Bảo mật & Mật khẩu',
              onTap: () {
                Navigator.pushNamed(context, '/change_password');
              },
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // THÔNG BÁO
          _buildSectionHeader(isEnglish ? 'NOTIFICATIONS' : 'THÔNG BÁO'),
          _buildSettingsGroup([
            _buildSettingsItem(
              icon: Icons.notifications_active,
              title: isEnglish ? 'Sensor Alerts' : 'Cảnh báo cảm biến',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.info,
              title: isEnglish ? 'System Notifications' : 'Thông báo hệ thống',
              onTap: () {},
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // TÙY CHỈNH
          _buildSectionHeader(isEnglish ? 'PREFERENCES' : 'TÙY CHỈNH'),
          _buildSettingsGroup([
            _buildSettingsItemWithWidget(
              icon: Icons.translate,
              title: isEnglish ? 'Language' : 'Ngôn ngữ',
              trailing: GestureDetector(
                onTap: () {
                  settingsVM.toggleLanguage();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: !isEnglish ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text('VN', style: TextStyle(color: !isEnglish ? Colors.white : AppTheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isEnglish ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text('EN', style: TextStyle(color: isEnglish ? Colors.white : AppTheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildSettingsItemWithWidget(
              icon: Icons.thermostat,
              title: isEnglish ? 'Measurement Unit' : 'Đơn vị đo lường',
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: settingsVM.tempUnit,
                  items: const [
                    DropdownMenuItem(value: 'C', child: Text('Celsius (°C)', style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w500))),
                    DropdownMenuItem(value: 'F', child: Text('Fahrenheit (°F)', style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w500))),
                    DropdownMenuItem(value: 'K', child: Text('Kelvin (°K)', style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w500))),
                  ],
                  onChanged: (val) {
                    if (val != null) settingsVM.setTempUnit(val);
                  },
                  icon: const Icon(Icons.expand_more, color: AppTheme.primary, size: 16),
                ),
              ),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // HỖ TRỢ
          _buildSectionHeader(isEnglish ? 'SUPPORT' : 'HỖ TRỢ'),
          _buildSettingsGroup([
            _buildSettingsItem(
              icon: Icons.help,
              title: isEnglish ? 'Help Center' : 'Trung tâm trợ giúp',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.support_agent,
              title: isEnglish ? 'Contact Technical Support' : 'Liên hệ hỗ trợ kỹ thuật',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.policy,
              title: isEnglish ? 'Terms & Policies' : 'Điều khoản & Chính sách',
              onTap: () {},
            ),
          ]),
          
          const SizedBox(height: 32),
          
          // Logout Button
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout, color: AppTheme.error),
            label: Text(
              isEnglish ? 'Log Out' : 'Đăng xuất',
              style: const TextStyle(color: AppTheme.error, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.error, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'AgriPulse v2.4.0 (Enterprise)',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    List<Widget> groupChildren = [];
    for (int i = 0; i < children.length; i++) {
      groupChildren.add(children[i]);
      if (i < children.length - 1) {
        groupChildren.add(
          const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.surfaceVariant),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: groupChildren,
      ),
    );
  }

  Widget _buildSettingsItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItemWithWidget({required IconData icon, required String title, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
