import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../l10n/app_translations.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface.withValues(alpha: 0.7),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings'.tr(context),
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
                        user?.fullName ?? 'User'.tr(context),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.role ?? 'Unknown'.tr(context),
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
          _buildSectionHeader('ACCOUNT'.tr(context)),
          _buildSettingsGroup([
            _buildSettingsItem(
              icon: Icons.person,
              title: 'Personal Information'.tr(context),
              onTap: () {
                Navigator.pushNamed(context, '/edit_profile');
              },
            ),
            _buildSettingsItem(
              icon: Icons.lock,
              title: 'Security & Password'.tr(context),
              onTap: () {
                Navigator.pushNamed(context, '/change_password');
              },
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // THÔNG BÁO
          _buildSectionHeader('NOTIFICATIONS'.tr(context)),
          _buildSettingsGroup([
            _buildSettingsItem(
              icon: Icons.notifications_active,
              title: 'Sensor Alerts'.tr(context),
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.info,
              title: 'System Notifications'.tr(context),
              onTap: () {},
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // TÙY CHỈNH
          _buildSectionHeader('PREFERENCES'.tr(context)),
          _buildSettingsGroup([
            _buildSettingsItemWithWidget(
              icon: Icons.translate,
              title: 'Language'.tr(context),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: settingsVM.currentLanguage,
                  items: const [
                    DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt', style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w500))),
                    DropdownMenuItem(value: 'ja', child: Text('日本語 (Nhật)', style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w500))),
                  ],
                  onChanged: (val) {
                    if (val != null) settingsVM.setLanguage(val);
                  },
                  icon: const Icon(Icons.expand_more, color: AppTheme.primary, size: 16),
                ),
              ),
            ),
            _buildSettingsItemWithWidget(
              icon: Icons.thermostat,
              title: 'Measurement Unit'.tr(context),
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
          _buildSectionHeader('SUPPORT'.tr(context)),
          _buildSettingsGroup([
            _buildSettingsItem(
              icon: Icons.help,
              title: 'Help Center'.tr(context),
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.support_agent,
              title: 'Contact Technical Support'.tr(context),
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.policy,
              title: 'Terms & Policies'.tr(context),
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
              'Log Out'.tr(context),
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
