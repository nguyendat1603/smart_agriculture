---
name: firebase-supabase-backend
description: Dual-backend architecture skill combining Firebase Realtime Database and Supabase best practices from sickn33/agentic-awesome-skills. Prevents listener leaks, security vulnerabilities, and state desynchronization in Smart Agriculture App.
---

# Firebase & Supabase Dual-Backend Expert

## 1. Phân định Trách nhiệm Kiến trúc (Separation of Concerns)
Dự án **Smart Agriculture App** kết hợp sức mạnh của 2 nền tảng Backend, do đó Agent tuyệt đối không được trộn lẫn vai trò của chúng:
1. **Firebase Realtime Database (`firebase_database: ^11.0.0`):**
   - Chuyên trách luồng dữ liệu **IoT thời gian thực tần suất cao** từ vi điều khiển ESP32 (Nhiệt độ, Độ ẩm không khí, Độ ẩm đất, Cường độ ánh sáng, Trạng thái máy bơm/rơ-le).
2. **Supabase (`supabase_flutter: ^2.14.2`):**
   - Chuyên trách **Xác thực người dùng (Auth)**, quản lý hồ sơ, nhật ký canh tác, lịch sử phân tích bệnh cây và dữ liệu quan hệ (PostgreSQL).

---

## 2. Quy tắc An toàn với Firebase Realtime Database

### 2.1. Chống Rò rỉ Listener (`StreamSubscription` Leak Prevention)
- Mỗi khi lắng nghe một node trên Firebase (`DatabaseReference.onValue.listen(...)`), bắt buộc phải lưu lại biến `StreamSubscription` và gọi `.cancel()` trong hàm `dispose()` của ViewModel.
- Không đăng ký nhiều listener trùng lặp trên cùng một node mỗi khi UI rebuild.

### 2.2. Xử lý An toàn Kiểu dữ liệu JSON từ ESP32
- Vi điều khiển ESP32 đôi khi gửi số nguyên (`28`)แทน số thực (`28.0`) hoặc gửi chuỗi (`"28.5"`).
- Khi parse dữ liệu từ `DataSnapshot.value`, luôn dùng hàm ép kiểu an toàn thay vì ép cứng `as double`:
```dart
double parseSafeDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}
```

---

## 3. Quy tắc An toàn với Supabase & Bảo mật `.env`

### 3.1. Bảo mật Khóa & Biến môi trường (`flutter_dotenv`)
- Không bao giờ hardcode `SUPABASE_URL`, `SUPABASE_ANON_KEY`, mật khẩu SMTP, hoặc API Key trực tiếp trong file `.dart`. Tất cả phải đọc từ `dotenv.env[...]`.
- Không bao giờ sử dụng `service_role` key của Supabase ở phía ứng dụng Flutter (chỉ dùng `anon` public key kết hợp với Row Level Security - RLS trên server).

### 3.2. Xử lý Ngoại lệ Mạng (Offline & Timeout Resilience)
- Người dùng nông nghiệp thường sử dụng điện thoại ở vườn/đồng ruộng nơi sóng 4G/Wi-Fi chập chờn.
- Mọi lời gọi Supabase và Firebase phải bọc trong `try-catch` có thông báo tiếng Việt rõ ràng, không để văng `Unhandled Exception` làm đơ màn hình.
