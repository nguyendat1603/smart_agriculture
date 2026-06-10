import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();

  void _submit() async {
    final authVM = context.read<AuthViewModel>();
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập email')));
      return;
    }

    try {
      await authVM.forgotPassword(email);
      if (mounted) {
        Navigator.pushNamed(context, '/reset_password');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background pattern and colors
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceVariant.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Accent line
                        Container(
                          height: 8,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primary, AppTheme.secondary],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(Icons.eco, color: AppTheme.primary, size: 32),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Quên mật khẩu',
                                style: TextStyle(
                                  color: AppTheme.onSurface,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Nhập email đã đăng ký để nhận hướng dẫn khôi phục mật khẩu.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Form
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      'Địa chỉ Email',
                                      style: TextStyle(
                                        color: AppTheme.onSurface,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: 'manager@farm.com',
                                      prefixIcon: const Icon(Icons.mail, color: AppTheme.onSurfaceVariant),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: AppTheme.outlineVariant),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: AppTheme.outlineVariant),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Actions
                              ElevatedButton(
                                onPressed: authVM.isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: authVM.isLoading 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Gửi yêu cầu',
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.send, size: 18),
                                      ],
                                    ),
                              ),
                              const SizedBox(height: 16),
                              
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_back, size: 18, color: AppTheme.primary),
                                    SizedBox(width: 8),
                                    Text(
                                      'Quay lại Đăng nhập',
                                      style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                '© 2024 AgriPulse AI. All rights reserved.',
                style: TextStyle(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
