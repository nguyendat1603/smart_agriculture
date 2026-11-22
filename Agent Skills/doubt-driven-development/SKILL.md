---
name: doubt-driven-development
description: Subjects every non-trivial architectural, IoT, or AI integration decision to an adversarial review before implementation stands. Adapted from sickn33/agentic-awesome-skills to prevent overconfident hallucinations.
---

# Doubt-Driven Development (Phát triển Dựa trên Phản biện & Hoài nghi)

## 1. Tổng quan (Overview)
Một câu trả lời tự tin của AI không đồng nghĩa với một giải pháp đúng. Khi phiên làm việc kéo dài, AI dễ biến các giả định chưa kiểm chứng thành "sự thật hiển nhiên". **Doubt-Driven Development** buộc AI phải tự đóng vai một "Người phản biện khắt khe" (Adversarial Reviewer) để tìm điểm yếu của giải pháp trước khi chốt code.

---

## 2. Khi nào Cần Áp dụng trong Smart Agriculture App?
Áp dụng quy trình phản biện này cho các quyết định **không tầm thường (Non-trivial)**:
1. Thay đổi luồng đồng bộ dữ liệu thời gian thực giữa **ESP32 ↔ Firebase Realtime Database ↔ Flutter App**.
2. Thay đổi kiến trúc mô hình AI (ví dụ: chuyển từ **Gemini API** sang chạy mô hình **TFLite offline** trên điện thoại).
3. Thiết kế cơ chế tự động bật/tắt máy bơm tưới cây dựa trên ngưỡng cảm biến độ ẩm đất.
4. Thay đổi bảng dữ liệu người dùng hoặc phân quyền trên **Supabase**.

---

## 3. Chu trình 4 Bước Phản biện (The Doubt Cycle)

### Bước 1: CLAIM (Phát biểu Giả định)
Viết rõ quyết định kỹ thuật trong 2-3 dòng và hậu quả nếu nó sai:
- *Ví dụ:* "CLAIM: Đọc trực tiếp file ảnh 12MP từ thư viện điện thoại đưa vào mô hình AI mà không giảm kích thước vẫn chạy mượt. HẬU QUẢ NẾU SAI: Gây tràn RAM (Out of Memory) trên điện thoại Android tầm trung và làm đơ UI."

### Bước 2: EXTRACT (Cô lập Thành phần & Hợp đồng Kỹ thuật)
Tách riêng đoạn code/kiến trúc (`ARTIFACT`) và yêu cầu ràng buộc (`CONTRACT`):
- *Contract của Smart Agriculture App:* Chạy trên Android 13+, phản hồi mượt mà, độ dài text hiển thị tối đa 5000 ký tự, không crash khi mất mạng hoặc thiếu API key.

### Bước 3: DOUBT (Tự vấn Phản biện - Adversarial Check)
Đặt 6 câu hỏi tấn công trực diện vào giải pháp vừa đề xuất:
1. **Giả định ngầm nào chưa được kiểm chứng?** (Ví dụ: Nếu file `.env` trống hoặc mạng Wi-Fi ở vườn cây bị rớt thì sao?)
2. **Trường hợp biên (Edge Cases) nào chưa xử lý?** (Ví dụ: Người dùng bấm hủy khi đang mở thư viện chọn ảnh `pickImage` trả về `null` thì sao?)
3. **Có rò rỉ tài nguyên không?** (Ví dụ: `AnimationController` của tia quét laser hoặc `StreamSubscription` của Firebase có được `.dispose()` khi thoát màn hình không?)
4. **Hợp đồng UI có bị vi phạm không?** (Ví dụ: Chuỗi trả về từ AI dài 10.000 ký tự có làm vỡ layout Bento Grid không?)
5. **Có làm hỏng các tính năng cũ không?** (Dashboard, biểu đồ cảm biến, đăng nhập Supabase có bị ảnh hưởng không?)
6. **Dữ liệu đầu vào độc hại/bất thường sẽ gây ra gì?** (Ảnh bị hỏng, JSON từ AI bị cắt cụt giữa chừng).

### Bước 4: RECONCILE (Khắc phục & Gia cố)
Mọi lỗ hổng hợp lệ tìm thấy ở Bước 3 phải được vá ngay trong code (thêm kiểm tra `null`, thêm `try/catch`, thêm `.dispose()`, thêm `_truncateText`, thêm nén ảnh) trước khi bàn giao cho User.
