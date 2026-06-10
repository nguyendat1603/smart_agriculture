import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailService {
  // Thay thế bằng tài khoản Gmail của bạn và App Password (Mật khẩu ứng dụng)
  // Lưu ý: KHÔNG dùng mật khẩu đăng nhập thông thường của Google.
  // Xem hướng dẫn tạo App Password: https://support.google.com/accounts/answer/185833
  static String get _smtpUsername =>
      dotenv.env['SMTP_EMAIL'] ?? 'YOUR_EMAIL@gmail.com';
  static String get _smtpPassword =>
      dotenv.env['SMTP_PASSWORD'] ?? 'YOUR_APP_PASSWORD';

  static Future<void> sendOtpEmail(
    String recipientEmail,
    String otpCode,
  ) async {
    if (_smtpUsername == 'YOUR_EMAIL@gmail.com') {
      debugPrint(
        "Chưa cấu hình Email. MOCK OTP -> Email: $recipientEmail | Mã: $otpCode",
      );
      return;
    }

    final smtpServer = gmail(_smtpUsername, _smtpPassword);

    final message = Message()
      ..from = Address(_smtpUsername, 'AgriPulse AI')
      ..recipients.add(recipientEmail)
      ..subject = 'Mã xác thực OTP - AgriPulse AI'
      ..text =
          'Xin chào,\n\nMã OTP của bạn là: $otpCode.\nMã này sẽ hết hạn trong vòng 5 phút.\n\nTrân trọng,\nĐội ngũ AgriPulse AI.'
      ..html =
          '''
        <h3>Xin chào,</h3>
        <p>Mã OTP của bạn là: <strong>$otpCode</strong>.</p>
        <p>Mã này sẽ hết hạn trong vòng 5 phút.</p>
        <br>
        <p>Trân trọng,<br>Đội ngũ AgriPulse AI.</p>
      ''';

    try {
      final sendReport = await send(message, smtpServer);
      debugPrint('Đã gửi mail OTP thành công: $sendReport');
    } on MailerException catch (e) {
      debugPrint('Lỗi gửi mail OTP: $e');
      for (var p in e.problems) {
        debugPrint('Problem: ${p.code}: ${p.msg}');
      }
      throw Exception('Không thể gửi email OTP.');
    }
  }

  static Future<void> sendResetPasswordEmail(
    String recipientEmail,
    String resetToken,
  ) async {
    if (_smtpUsername == 'YOUR_EMAIL@gmail.com') {
      debugPrint(
        "Chưa cấu hình Email. MOCK TOKEN -> Email: $recipientEmail | Token: $resetToken",
      );
      return;
    }

    final smtpServer = gmail(_smtpUsername, _smtpPassword);

    final message = Message()
      ..from = Address(_smtpUsername, 'AgriPulse AI')
      ..recipients.add(recipientEmail)
      ..subject = 'Khôi phục mật khẩu - AgriPulse AI'
      ..text =
          'Xin chào,\n\nBạn đã yêu cầu khôi phục mật khẩu.\nMã Token của bạn là: $resetToken.\nVui lòng nhập mã này vào ứng dụng để đổi mật khẩu mới (Mã có hiệu lực 15 phút).\n\nTrân trọng.'
      ..html =
          '''
        <h3>Xin chào,</h3>
        <p>Bạn đã yêu cầu khôi phục mật khẩu.</p>
        <p>Mã Token của bạn là: <strong>$resetToken</strong></p>
        <p>Vui lòng nhập mã này vào ứng dụng để đổi mật khẩu mới (Mã có hiệu lực 15 phút).</p>
        <br>
        <p>Trân trọng,<br>Đội ngũ AgriPulse AI.</p>
      ''';

    try {
      final sendReport = await send(message, smtpServer);
      debugPrint('Đã gửi mail khôi phục MK thành công: $sendReport');
    } on MailerException catch (e) {
      debugPrint('Lỗi gửi mail khôi phục MK: $e');
      for (var p in e.problems) {
        debugPrint('Problem: ${p.code}: ${p.msg}');
      }
      throw Exception('Không thể gửi email khôi phục mật khẩu.');
    } catch (e) {
      debugPrint('Lỗi gửi mail không xác định: $e');
      throw Exception('Không thể gửi email khôi phục mật khẩu.');
    }
  }
}
