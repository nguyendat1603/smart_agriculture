---
name: flutter-expert
description: Comprehensive Flutter 3.12+ and Dart 3 architecture skill from sickn33/agentic-awesome-skills. Tailored for Smart Agriculture App's MVVM Provider pattern, Bento UI design system, fl_chart real-time graphs, and 5000-character text limit handling.
---

# Flutter Expert — Chuẩn Kiến trúc Flutter 3.12+ & Dart 3

## 1. Kiến trúc Chuẩn của Dự án (MVVM + Provider)
Dự án **Smart Agriculture App** tuân thủ nghiêm ngặt mô hình **MVVM (Model - View - ViewModel)** với `provider`:
- **`lib/models/`**: Chứa các lớp dữ liệu thuần túy (`fromJson`, `toJson`), bất biến (`final`).
- **`lib/services/`**: Chứa logic giao tiếp ngoại vi (Firebase Realtime DB, Supabase Auth/DB, AI Vision / TFLite, SMTP Email). Không bao giờ đưa `BuildContext` hoặc widget UI vào tầng Service.
- **`lib/viewmodels/`**: Kế thừa `ChangeNotifier`, quản lý trạng thái (`isLoading`, `errorMessage`, dữ liệu hiển thị) và gọi `notifyListeners()`.
- **`lib/views/`**: Chỉ hiển thị giao diện, lắng nghe ViewModel qua `Consumer<T>` hoặc `context.watch<T>()`, gọi hành động qua `context.read<T>()`.

---

## 2. Các Quy tắc Vàng trong Flutter 3.12+ (Anti-Bug Guardrails)

### 2.1. An toàn `BuildContext` qua các khoảng chờ Bất đồng bộ (`async` gaps)
Mọi lệnh gọi `Navigator`, `ScaffoldMessenger`, hoặc `Provider` sau từ khóa `await` **bắt buộc** phải kiểm tra `mounted`:
```dart
await viewModel.analyzeSelectedImage();
if (!context.mounted) return; // Bắt buộc trong Flutter 3.x+
ScaffoldMessenger.of(context).showSnackBar(...);
```

### 2.2. Quản lý Bộ nhớ & Hiệu ứng Animation (`dispose`)
- Mọi `AnimationController` (như hiệu ứng tia laser quét ảnh lá cây trong `HealthAnalysisView`), `TextEditingController`, `ScrollController`, hoặc `StreamSubscription` **bắt buộc** phải được giải phóng trong hàm `dispose()`.
- Không khởi tạo `Future` hoặc `Stream` trực tiếp bên trong hàm `build(BuildContext context)`.

### 2.3. Xử lý Giới hạn Văn bản AI 5000 Ký tự & Cuộn Màn hình
- Kết quả phân tích AI (`aiInsight`, `expertAdvice`) có độ dài tối đa **5000 ký tự**.
- Trên giao diện (`View`):
  - Luôn bọc nội dung màn hình trong `SingleChildScrollView` hoặc `CustomScrollView` để không bao giờ xảy ra lỗi sọc vàng-đen (`RenderFlex overflowed`).
  - Không đặt `Expanded` hoặc `Flexible` trực tiếp bên trong `SingleChildScrollView` theo trục dọc mà không giới hạn chiều cao.

### 2.4. Tối ưu hóa Biểu đồ Cảm biến (`fl_chart: ^0.69.0`)
- Khi vẽ biểu đồ nhiệt độ, độ ẩm đất theo thời gian thực:
  - Giới hạn số điểm dữ liệu hiển thị trên một khung nhìn (ví dụ: 20–50 điểm gần nhất) để tránh tụt FPS khi Firebase bắn dữ liệu liên tục.
  - Kiểm tra danh sách điểm rỗng (`spots.isEmpty`) trước khi render `LineChart` để tránh lỗi chia cho 0 (`minY == maxY`).
