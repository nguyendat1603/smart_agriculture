import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().currentUser;
      if (user != null) {
        setState(() {
          _nameController.text = user.fullName;
          _phoneController.text = user.phoneNumber;
          _locationController.text = user.farmLocation;
          _avatarUrlController.text = user.avatarUrl;
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _saveProfile() async {
    final authVM = context.read<AuthViewModel>();
    try {
      await authVM.updateProfile(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _locationController.text.trim(),
        avatarFile: _selectedImage,
        currentAvatarUrl: _avatarUrlController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thông tin thành công')));
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
    final user = context.watch<AuthViewModel>().currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface.withValues(alpha: 0.7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(
            color: AppTheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      )
                    ],
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : _avatarUrlController.text.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(_avatarUrlController.text),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: (_selectedImage != null || _avatarUrlController.text.isNotEmpty)
                      ? null 
                      : const Center(
                          child: Icon(Icons.person, size: 60, color: AppTheme.outline),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          )
                        ],
                      ),
                      child: const Icon(Icons.photo_camera, size: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'ẢNH ĐẠI DIỆN',
              style: TextStyle(
                color: AppTheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 32),

            // Form
            _buildTextField(label: 'Họ và tên', controller: _nameController, icon: Icons.person),
            const SizedBox(height: 16),
            _buildTextField(label: 'Số điện thoại', controller: _phoneController, keyboardType: TextInputType.phone, icon: Icons.phone),
            const SizedBox(height: 16),
            _buildTextField(label: 'Vị trí trang trại', controller: _locationController, icon: Icons.location_on),
            const SizedBox(height: 16),
            // Email (Readonly)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Email (Không thể thay đổi)',
                    style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                TextFormField(
                  initialValue: user?.email ?? '',
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surfaceVariant.withValues(alpha: 0.3),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: Icon(Icons.lock, color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Save Button
            ElevatedButton(
              onPressed: context.watch<AuthViewModel>().isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                shadowColor: AppTheme.primary.withValues(alpha: 0.4),
                elevation: 8,
              ),
              child: context.watch<AuthViewModel>().isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Lưu thay đổi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType? keyboardType,
    Function(String)? onChanged,
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: icon != null ? Icon(icon, color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5)) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
