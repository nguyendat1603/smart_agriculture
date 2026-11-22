---
name: verification-before-completion
description: Enforces the strict rule "No completion claims without fresh verification evidence" from sickn33/agentic-awesome-skills. Prevents AI agents from claiming code works without running flutter analyze, tests, or verifying file states.
---

# Verification Before Completion (Kiểm chứng Thực tế Trước khi Báo cáo Hoàn thành)

## 1. Nguyên tắc Sắt (The Iron Law)
> **"Không bao giờ tuyên bố hoàn thành công việc nếu chưa có bằng chứng kiểm chứng thực tế vừa mới chạy."**  
> *(No completion claims without fresh verification evidence.)*

Một lỗi phổ biến của các AI Agent là sau khi sửa file xong liền tuyên bố *"Tôi đã sửa xong và ứng dụng hoạt động hoàn hảo"* trong khi code vẫn còn lỗi cú pháp, thiếu dấu ngoặc, hoặc sai kiểu dữ liệu Dart. Skill này chặn đứng hành vi ảo giác trạng thái đó.

---

## 2. Quy trình Kiểm chứng Bắt buộc cho Smart Agriculture App

Trước khi trả lời User rằng một tính năng hoặc bản vá lỗi đã hoàn tất, Agent **bắt buộc** phải thực hiện các bước sau:

### Bước 1: Kiểm tra Tĩnh & Phân tích Lỗi Dart (`flutter analyze`)
Chạy lệnh phân tích trên file vừa sửa hoặc toàn bộ dự án:
```bash
flutter analyze
```
- **Tiêu chuẩn đạt:** Không có bất kỳ `error` nào. Nếu có `warning` hoặc `unused_import` ở file vừa tạo/sửa, phải dọn dẹp sạch sẽ.

### Bước 2: Kiểm tra Liên kết Tuyến đường & Provider (`main.dart`)
Khi thêm một màn hình mới (View) hoặc một ViewModel mới:
- [ ] ViewModel đã được đăng ký vào `MultiProvider` trong `lib/main.dart` chưa?
- [ ] Route điều hướng đã được khai báo hoặc truyền đúng qua `Navigator.push` chưa?
- [ ] Các biến môi trường mới (nếu có) đã được xử lý fallback an toàn khi `.env` chưa có khóa đó chưa?

### Bước 3: Kiểm tra Ràng buộc Nghiệp vụ & UI của Dự án
Đối với các yêu cầu đặc thù của **Smart Agriculture App**:
- [ ] **Nguồn ảnh:** Đã lấy từ thư viện điện thoại (`ImageSource.gallery`) đúng yêu cầu chưa?
- [ ] **Giới hạn văn bản AI:** Đã kiểm tra hàm cắt chuỗi `<= 5000` ký tự để tránh tràn bộ nhớ giao diện chưa?
- [ ] **Xử lý bất đồng bộ (`async/await`):** Đã kiểm tra `if (!context.mounted) return;` trước khi dùng `BuildContext` sau các lệnh `await` chưa?

### Bước 4: Báo cáo Trung thực Bằng chứng
Khi phản hồi cho User:
- Nêu rõ lệnh nào đã được chạy và kết quả trả về là gì.
- Nếu một bước không thể kiểm tra trên máy tính mà cần thiết bị thật (ví dụ: chọn ảnh trên máy Android 13 thật hoặc kết nối mạch ESP32 thật), phải nói rõ phần nào đã kiểm chứng bằng code và phần nào cần User test trên điện thoại.

---

## 3. Các Ngụy biện Bị Cấm (Forbidden Rationalizations)
| Ngụy biện của AI | Thực tế bắt buộc |
| :--- | :--- |
| *"Thay đổi này nhỏ thôi, không cần chạy `flutter analyze`"* | Thay đổi 1 dòng vẫn có thể làm thiếu dấu `;` hoặc lệch ngoặc `}`. Luôn phải kiểm tra. |
| *"Code nhìn có vẻ đúng rồi"* | Mắt đọc code của LLM thường bỏ sót lỗi kiểu dữ liệu (Type mismatch) của Dart 3 Null Safety. Trình biên dịch mới là trọng tài duy nhất. |
| *"Lần chạy trước đã pass rồi"* | Sau bất kỳ lệnh `edit_file` hay `write_file` nào, kết quả kiểm tra cũ đều vô giá trị. Phải kiểm tra lại bản mới nhất. |
