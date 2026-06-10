import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  void _submitChangePassword() async {
    final currentPw = _currentPasswordController.text;
    final newPw = _newPasswordController.text;
    final confirmPw = _confirmPasswordController.text;

    if (currentPw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đủ thông tin')));
      return;
    }

    if (newPw != confirmPw) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu mới không khớp')));
      return;
    }

    if (newPw.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu mới phải có ít nhất 6 ký tự')));
      return;
    }

    final authVM = context.read<AuthViewModel>();
    try {
      await authVM.changePassword(currentPw, newPw);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface.withValues(alpha: 0.7),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Đổi mật khẩu',
          style: TextStyle(
            color: AppTheme.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Info box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info, color: AppTheme.primary, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Mật khẩu mới của bạn phải có ít nhất 6 ký tự, bao gồm chữ cái và số.',
                              style: TextStyle(
                                color: AppTheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Current Password
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      label: 'Mật khẩu hiện tại',
                      icon: Icons.lock,
                      obscureText: _obscureCurrent,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureCurrent = !_obscureCurrent;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppTheme.surfaceVariant, height: 32),

                    // New Password
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: 'Mật khẩu mới',
                      icon: Icons.lock_reset,
                      iconColor: AppTheme.primary,
                      obscureText: _obscureNew,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureNew = !_obscureNew;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Xác nhận mật khẩu mới',
                      icon: Icons.check_circle,
                      iconColor: AppTheme.primary,
                      obscureText: _obscureConfirm,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Save Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppTheme.surface,
                    AppTheme.surface.withValues(alpha: 0.9),
                    AppTheme.surface.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: context.watch<AuthViewModel>().isLoading ? null : _submitChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: AppTheme.primary.withValues(alpha: 0.2),
                  elevation: 8,
                ),
                child: context.watch<AuthViewModel>().isLoading
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Cập nhật mật khẩu',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.save),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Color iconColor = AppTheme.onSurfaceVariant,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.surfaceVariant),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(icon, color: iconColor),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.onSurfaceVariant,
                ),
                onPressed: onToggleVisibility,
              ),
              border: InputBorder.none,
              hintText: label,
              hintStyle: const TextStyle(color: AppTheme.outline),
            ),
          ),
        ),
      ],
    );
  }
}
