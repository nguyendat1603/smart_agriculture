# Smart Agriculture App

Ứng dụng Nông nghiệp Thông minh (Smart Agriculture App) giúp người dùng theo dõi và quản lý các chỉ số môi trường cây trồng (như nhiệt độ, độ ẩm, ánh sáng, độ ẩm đất...) từ xa, hiển thị biểu đồ và quản lý thiết bị IoT.

## 📋 Yêu cầu ứng dụng (Requirements)

### 1. Yêu cầu Phần cứng (Hardware)
* **Thiết bị IoT:** ESP32 (hoặc vi điều khiển tương đương có kết nối Wi-Fi) để thu thập dữ liệu từ các cảm biến.
* **Thiết bị Di động:** Điện thoại thông minh chạy hệ điều hành **Android 13** trở lên.

### 2. Yêu cầu Phần mềm & Công cụ (Software)
* **Flutter SDK:** Phiên bản 3.12.0 trở lên.
* **IDE:** Android Studio, VS Code, hoặc IntelliJ IDEA có cài đặt plugin Flutter & Dart.
* **Dịch vụ Backend:**
  * **Firebase Realtime Database:** Lưu trữ và đồng bộ dữ liệu thời gian thực.
  * **Supabase:** Quản lý cơ sở dữ liệu / Xác thực người dùng.
  * **SMTP Email:** Dùng package `mailer` để gửi email thông báo, xác thực.

## ⚙️ Cách cài đặt App (Installation)

**Bước 1: Tải mã nguồn**
Mở mã nguồn dự án bằng IDE của bạn (ví dụ: VS Code hoặc Android Studio) tại thư mục `smart_agriculture_app`.

**Bước 2: Tải các thư viện (Dependencies)**
Mở Terminal tại thư mục gốc của dự án và chạy lệnh sau để cài đặt các package được khai báo trong `pubspec.yaml`:
```bash
flutter pub get
```

**Bước 3: Cấu hình biến môi trường (.env)**
Ứng dụng sử dụng gói `flutter_dotenv`. Bạn cần tạo một file tên là `.env` ở thư mục gốc của dự án (ngang hàng với `pubspec.yaml`).
Khai báo các cấu hình cần thiết (như API Key, URL, thông tin Email) vào file `.env`:
```env
# Mẫu file .env (Điền thông tin thực tế của dự án vào đây)
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
# ...
```

**Bước 4: Cấu hình Firebase**
Đảm bảo bạn đã có file `google-services.json` đặt tại thư mục `android/app/` để ứng dụng có thể kết nối với Firebase project của bạn.

## 🚀 Cách chạy App (Running the App)

**Bước 1: Kết nối thiết bị**
* Bật máy ảo Android (Emulator) thông qua Android Studio.
* **Hoặc** kết nối điện thoại thật chạy Android 13+ bằng cáp USB, đảm bảo đã bật tính năng **USB Debugging** (Gỡ lỗi USB).

**Bước 2: Kiểm tra thiết bị**
Chạy lệnh sau trên Terminal để xác nhận thiết bị đã được nhận diện:
```bash
flutter devices
```

**Bước 3: Khởi chạy ứng dụng**
Tại thư mục gốc của dự án, chạy lệnh:
```bash
flutter run
```
*(Nếu có nhiều thiết bị, bạn có thể chạy `flutter run -d <device_id>`)*

**Bước 4: Xuất file APK cài đặt (Khi muốn phát hành)**
Để tạo file `.apk` cài đặt trực tiếp lên điện thoại Android, chạy lệnh:
```bash
flutter build apk --release
```
File APK sau khi build thành công sẽ nằm ở đường dẫn: `build/app/outputs/flutter-apk/app-release.apk`.

---
**Một số thư viện chính được sử dụng:**
- `provider`: Quản lý trạng thái (State management).
- `fl_chart`: Vẽ biểu đồ thống kê dữ liệu.
- `firebase_core` & `firebase_database`: Kết nối Firebase.
- `supabase_flutter`: Kết nối dịch vụ Supabase.
- `mailer`: Gửi email.
- `image_picker`: Chọn ảnh từ thiết bị.
/////
