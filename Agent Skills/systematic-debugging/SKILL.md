---
name: systematic-debugging
description: Phase-gated root-cause debugging methodology from sickn33/agentic-awesome-skills. Stops AI agents from guessing or thrashing code when errors occur in Flutter, Firebase, Supabase, or AI services.
---

# Systematic Debugging (Gỡ lỗi Có Hệ thống — Cấm Đoán mò)

## 1. Nguyên tắc Cốt lõi
> **"Không bao giờ viết code sửa lỗi khi chưa tìm ra nguyên nhân gốc rễ (Root Cause)."**

Khi ứng dụng gặp lỗi, phản xạ sai lầm nhất của AI là đoán bừa một nguyên nhân rồi sửa đại code, dẫn đến lỗi cũ chưa hết mà lỗi mới lại phát sinh. Skill này bắt buộc tuân thủ quy trình 4 pha.

---

## 2. Quy trình 4 Pha Gỡ lỗi (The 4-Phase Debugging Protocol)

### Pha 1: Thu thập Bằng chứng (Observe & Reproduce)
- Đọc toàn bộ thông báo lỗi (Stack Trace), dòng code bị lỗi, và log trên console.
- Xác định lỗi xảy ra ở tầng nào:
  1. **Tầng UI (`views/`)**: Lỗi `RenderFlex overflowed`, lỗi `Null check operator used on a null value`, lỗi dùng `BuildContext` sau `async`.
  2. **Tầng State (`viewmodels/`)**: Quên gọi `notifyListeners()`, hoặc gọi `notifyListeners()` sau khi ViewModel đã `dispose`.
  3. **Tầng Dịch vụ (`services/`)**: Lỗi thiếu khóa trong `.env`, lỗi mất kết nối Firebase/Supabase, lỗi parse JSON từ AI hoặc model `.tflite` chưa khai báo trong `pubspec.yaml` mục `assets`.

### Pha 2: Đặt Giả thuyết & Khoanh vùng (Hypothesize & Isolate)
- Đưa ra giả thuyết cụ thể và kiểm tra ngay bằng cách đọc file liên quan.
- *Ví dụ:* Nếu màn hình Phân tích AI không hiển thị kết quả → Kiểm tra xem `AIAnalysisService.analyzeImage` có ném ra Exception trong khối `catch` không, hoặc chuỗi JSON trả về có bị dính ký tự markdown ```` ```json ```` không.

### Pha 3: Sửa lỗi Tối thiểu & Chính xác (Minimal Targeted Fix)
- Chỉ sửa đúng chỗ gây ra lỗi gốc rễ.
- Không tiện tay cấu trúc lại (refactor) hoặc đổi tên các biến/hàm không liên quan đang chạy ổn định.

### Pha 4: Kiểm chứng Lại (`flutter analyze`)
- Chạy `flutter analyze` để đảm bảo bản vá không tạo ra lỗi biên dịch mới.
- Giải thích ngắn gọn cho User: **(1) Nguyên nhân gốc là gì**, **(2) Đã sửa ở file/dòng nào**, và **(3) Cách kiểm tra lại**.
