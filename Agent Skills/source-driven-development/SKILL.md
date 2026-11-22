---
name: source-driven-development
description: Grounds every implementation decision in official documentation and project dependency files. Adapted from sickn33/agentic-awesome-skills for Smart Agriculture App to eliminate outdated Flutter/Dart, Firebase, Supabase, and TFLite API hallucinations.
---

# Source-Driven Development (Lập trình Dựa trên Tài liệu Chính thức)

## 1. Tổng quan (Overview)
Dữ liệu huấn luyện của AI luôn có độ trễ so với các bản cập nhật SDK thực tế. Nhiều đoạn code Flutter, Firebase hoặc Supabase viết theo "trí nhớ" của AI sử dụng các API đã bị khai tử (deprecated). Skill này bắt buộc Agent phải kiểm tra phiên bản thực tế trong `pubspec.yaml` và đối chiếu tài liệu chính thức trước khi viết code.

---

## 2. Quy trình 4 Bước Bắt buộc (The 4-Step Process)

```text
DETECT (Đọc pubspec.yaml) ──→ VERIFY (Đối chiếu Docs) ──→ IMPLEMENT (Code chuẩn) ──→ CITE (Trích dẫn)
```

### Bước 1: Nhận diện Stack & Phiên bản (`pubspec.yaml`)
Trước khi viết code cho **Smart Agriculture App**, luôn kiểm tra các phiên bản hiện tại của dự án:
- **Dart SDK:** `^3.12.0`
- **State Management:** `provider: ^6.1.2`
- **Biểu đồ:** `fl_chart: ^0.69.0` (Lưu ý: API của `fl_chart` thay đổi lớn giữa bản `0.55`, `0.69` và `1.x` — tuyệt đối không dùng thuộc tính cũ như `SideTitles(showTitles: true)` mà không bọc trong `AxisTitles`).
- **Firebase:** `firebase_core: ^3.1.0`, `firebase_database: ^11.0.0`
- **Supabase:** `supabase_flutter: ^2.14.2` (Sử dụng cú pháp `.select()`, `.insert()` mới của v2, không dùng `.execute()` đã bị xóa ở v1).
- **Chọn ảnh:** `image_picker: ^1.2.2` (`ImagePicker().pickImage(source: ImageSource.gallery)`).
- **AI SDK:** `google_generative_ai: ^0.4.7` (hoặc `tflite_flutter` khi chạy offline).

### Bước 2: Phân cấp Nguồn Tài liệu Tin cậy
Chỉ sử dụng các nguồn chính thức sau để xác thực cú pháp:
1. **Flutter & Dart Official Docs:** `docs.flutter.dev`, `dart.dev/guides`
2. **Pub.dev Package API Reference:** Trang API chính thức của đúng phiên bản package trong `pubspec.yaml`.
3. **Supabase Flutter v2 Docs:** `supabase.com/docs/reference/dart`
4. **Firebase Flutter (FlutterFire) Docs:** `firebase.flutter.dev`

*Không bao giờ lấy các bài viết StackOverflow cũ từ năm 2020-2022 làm chuẩn chính thức.*

### Bước 3: Thực thi theo Chuẩn Hiện tại
- Không dùng các API đã deprecated trong Flutter 3.12+ (ví dụ: dùng `withValues(alpha: ...)` hoặc `Color.fromRGBO` thay vì các hàm cũ sắp bỏ; dùng `PopScope` thay cho `WillPopScope`; dùng `TextTheme.bodyLarge` thay cho `bodyText1`).
- Nếu phát hiện xung đột giữa code hiện tại trong dự án và chuẩn mới, phải thông báo rõ cho User lựa chọn.

### Bước 4: Ghi chú Minh bạch khi Chưa xác thực
Nếu không thể truy cập tài liệu của một hàm ngoại vi, phải ghi rõ:
```dart
// [UNVERIFIED]: Cần kiểm tra lại chữ ký hàm trên thiết bị Android 13+ thực tế.
```

---

## 3. Các Dấu hiệu Cảnh báo Đỏ (Red Flags)
- ❌ Viết code `fl_chart` hoặc `supabase_flutter` theo thói quen cũ mà không kiểm tra phiên bản trong `pubspec.yaml`.
- ❌ Dùng từ ngữ phỏng đoán như *"Tôi nghĩ hàm này có tham số..."* thay vì kiểm tra định nghĩa class trong `.dart_tool` hoặc tài liệu.
- ❌ Tự ý gọi phương thức không có sẵn trong SDK.

## 4. Checklist Kiểm chứng
- [ ] Đã đối chiếu phiên bản package trong `pubspec.yaml`?
- [ ] Không có cảnh báo `deprecated_member_use` khi chạy `flutter analyze`?
- [ ] Cú pháp Supabase v2 và Firebase v11 đúng chuẩn?
