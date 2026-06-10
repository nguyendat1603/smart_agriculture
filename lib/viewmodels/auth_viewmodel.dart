import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import '../services/supabase_service.dart';
import '../services/email_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _currentUserEmail;
  String? get currentUserEmail => _currentUserEmail;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Helper function to hash password
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 1. Luồng Đăng nhập
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final client = SupabaseService.client;

      final String hashedPw = _hashPassword(password);
      
      final response = await client
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        throw Exception("Tài khoản không tồn tại");
      }

      if (response['password_hash'] != hashedPw) {
        throw Exception("Sai mật khẩu");
      }

      if (response['is_verified'] != true) {
        _currentUserEmail = email;
        throw Exception("Tài khoản chưa được xác thực. Vui lòng kiểm tra OTP.");
      }

      _currentUserEmail = email;
      _currentUser = UserModel.fromJson(response);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      debugPrint("Login Error: $e");
      rethrow;
    }
  }

  // Đăng xuất
  void logout() {
    _currentUserEmail = null;
    _currentUser = null;
    notifyListeners();
  }

  // 2. Luồng Đăng ký & Kích hoạt (Sinh OTP)
  Future<bool> register(String fullName, String email, String phone, String password) async {
    _setLoading(true);
    try {
      final client = SupabaseService.client;

      // Check if user already exists
      final existingUser = await client.from('users').select().eq('email', email).maybeSingle();
      if (existingUser != null) {
        throw Exception("Email đã tồn tại.");
      }

      // Sinh OTP 6 số ngẫu nhiên
      final random = Random();
      final String otpCode = (100000 + random.nextInt(900000)).toString();
      final DateTime expiresAt = DateTime.now().add(const Duration(minutes: 5));

      final String hashedPw = _hashPassword(password);

      // Thêm user với is_verified = FALSE
      await client.from('users').insert({
        'email': email,
        'full_name': fullName,
        'phone_number': phone,
        'password_hash': hashedPw,
        'is_verified': false,
        'otp_code': otpCode,
        'otp_expires_at': expiresAt.toIso8601String(),
      });

      _currentUserEmail = email;
      
      // Gửi OTP qua Email
      await EmailService.sendOtpEmail(email, otpCode);

      _setLoading(false);
      return true; // Thành công, chuyển sang màn OTP
    } catch (e) {
      _setLoading(false);
      debugPrint("Register Error: $e");
      rethrow;
    }
  }

  // Xác thực OTP
  Future<bool> verifyOtp(String otpCode) async {
    if (_currentUserEmail == null) throw Exception("Email is null. Please register/login first.");
    _setLoading(true);
    try {
      final client = SupabaseService.client;

      final response = await client
          .from('users')
          .select()
          .eq('email', _currentUserEmail!)
          .maybeSingle();

      if (response == null) throw Exception("User not found");

      final String? dbOtp = response['otp_code'];
      final String? expiresStr = response['otp_expires_at'];

      if (dbOtp == null || expiresStr == null) {
        throw Exception("Không tìm thấy OTP cho tài khoản này.");
      }

      if (dbOtp != otpCode) {
        throw Exception("Mã OTP không chính xác.");
      }

      final DateTime expiresAt = DateTime.parse(expiresStr);
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception("Mã OTP đã hết hạn.");
      }

      // Hợp lệ, cập nhật DB
      await client.from('users').update({
        'is_verified': true,
        'otp_code': null,
        'otp_expires_at': null,
      }).eq('email', _currentUserEmail!);

      // Lấy lại data để cập nhật currentUser
      final updatedUser = await client.from('users').select().eq('email', _currentUserEmail!).single();
      _currentUser = UserModel.fromJson(updatedUser);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      debugPrint("Verify OTP Error: $e");
      rethrow;
    }
  }

  // 3. Luồng Quên mật khẩu (Tạo Token)
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    try {
      final client = SupabaseService.client;

      // Check if user exists
      final user = await client.from('users').select().eq('email', email).maybeSingle();
      if (user == null) {
        throw Exception("Không tìm thấy tài khoản với email này.");
      }

      // Tạo chuỗi token ngẫu nhiên
      final String token = _generateRandomToken(32);
      final DateTime expiresAt = DateTime.now().add(const Duration(minutes: 15));

      await client.from('users').update({
        'reset_password_token': token,
        'reset_token_expires_at': expiresAt.toIso8601String(),
      }).eq('email', email);

      // Gửi link chứa token qua Email
      await EmailService.sendResetPasswordEmail(email, token);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      debugPrint("Forgot Password Error: $e");
      rethrow;
    }
  }

  // Đặt lại mật khẩu với Token
  Future<bool> resetPassword(String token, String newPassword) async {
    _setLoading(true);
    try {
      final client = SupabaseService.client;

      // Tìm user theo token
      final response = await client
          .from('users')
          .select()
          .eq('reset_password_token', token)
          .maybeSingle();

      if (response == null) {
        throw Exception("Token không hợp lệ hoặc không tồn tại.");
      }

      final String email = response['email'];
      final String expiresStr = response['reset_token_expires_at'];
      final DateTime expiresAt = DateTime.parse(expiresStr);

      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception("Token đã hết hạn.");
      }

      final String hashedPw = _hashPassword(newPassword);

      // Cập nhật password mới và xóa token
      await client.from('users').update({
        'password_hash': hashedPw,
        'reset_password_token': null,
        'reset_token_expires_at': null,
      }).eq('email', email);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      debugPrint("Reset Password Error: $e");
      rethrow;
    }
  }

  // 4. Cập nhật hồ sơ (Update Profile)
  Future<bool> updateProfile(String fullName, String phoneNumber, String farmLocation, {String? currentAvatarUrl, dynamic avatarFile}) async {
    if (_currentUser == null) throw Exception("Bạn chưa đăng nhập.");
    _setLoading(true);
    try {
      final client = SupabaseService.client;
      String finalAvatarUrl = currentAvatarUrl ?? '';

      // Upload file to Supabase Storage if a new file is provided
      if (avatarFile != null) {
        final fileExt = avatarFile.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = 'avatars/$_currentUserEmail/$fileName';
        
        await client.storage.from('avatars').upload(filePath, avatarFile);
        finalAvatarUrl = client.storage.from('avatars').getPublicUrl(filePath);
      }

      await client.from('users').update({
        'full_name': fullName,
        'phone_number': phoneNumber,
        'farm_location': farmLocation,
        'avatar_url': finalAvatarUrl,
      }).eq('id', _currentUser!.id);

      // Update local state
      _currentUser = _currentUser!.copyWith(
        fullName: fullName,
        phoneNumber: phoneNumber,
        farmLocation: farmLocation,
        avatarUrl: finalAvatarUrl,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      debugPrint("Update Profile Error: $e");
      rethrow;
    }
  }

  // 5. Đổi mật khẩu trong Settings
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) throw Exception("Bạn chưa đăng nhập.");
    _setLoading(true);
    try {
      final client = SupabaseService.client;

      // Verify current password
      final response = await client.from('users').select('password_hash').eq('id', _currentUser!.id).single();
      final String dbHash = response['password_hash'];
      final String currentHashedPw = _hashPassword(currentPassword);

      if (dbHash != currentHashedPw) {
        throw Exception("Mật khẩu hiện tại không đúng.");
      }

      // Update to new password
      final String newHashedPw = _hashPassword(newPassword);
      await client.from('users').update({
        'password_hash': newHashedPw,
      }).eq('id', _currentUser!.id);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      debugPrint("Change Password Error: $e");
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _generateRandomToken(int length) {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final rnd = Random.secure();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}
