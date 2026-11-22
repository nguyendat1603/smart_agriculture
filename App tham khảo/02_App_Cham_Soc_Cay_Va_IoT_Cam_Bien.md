# 📡 Nhóm 2: Các Ứng dụng Kết nối Cảm biến IoT & Quản lý Chăm sóc Cây

Tài liệu này phân tích các ứng dụng kết nối với **thiết bị phần cứng (Cảm biến đất, Nhiệt độ, Ánh sáng, Hệ thống tưới)** — có kiến trúc gần gũi nhất với luồng **ESP32 + Firebase Realtime Database + Flutter** của dự án **Smart Agriculture App**.

---

## 1. Xiaomi Flower Care (Mi Home / VegTrug Flora Care)
* **Phần cứng đi kèm:** Cảm biến cắm đất thông minh 4-trong-1 (Đo Độ ẩm đất, Nhiệt độ môi trường, Cường độ ánh sáng Lux, và Độ dẫn điện/Dinh dưỡng đất EC).
* **Cách thiết kế App & Trải nghiệm người dùng:**
  1. **Thanh Ngưỡng Trực quan (Threshold Progress Bars):**
     - Không chỉ hiện con số khô khan (ví dụ: `Độ ẩm đất: 25%`), ứng dụng hiển thị một thanh ngang có **Vùng Xanh (Lý tưởng: 30% - 60%)**. Khi kim chỉ ở `25%`, thanh chuyển sang màu Cam/Đỏ kèm dòng chữ: *"Đất đang khô - Cần tưới nước"*.
  2. **Cơ sở dữ liệu >6.000 loài cây:**
     - Người dùng chọn loại cây đang trồng trong chậu (ví dụ: Cà chua, Dâu tây, Hoa hồng). App tự động áp bộ ngưỡng chuẩn của đúng loài cây đó lên cảm biến.
  3. **Biểu đồ Lịch sử (Ngày / Tuần / Tháng):**
     - Vẽ đường biểu đồ mượt mà (tương tự `fl_chart` trong dự án của bạn) để người trồng thấy được tốc độ khô của đất sau mỗi lần tưới.

---

## 2. Blynk IoT — Nền tảng Điều khiển & Giám sát Phần cứng
* **Phần cứng đi kèm:** ESP32, ESP8266, Arduino, Raspberry Pi.
* **Các tính năng cốt lõi đáng học hỏi:**
  1. **Trạng thái Kết nối Thiết bị (Online / Offline Badge):**
     - Luôn có chấm xanh/đỏ ở góc màn hình báo hiệu mạch ESP32 đang Online hay mất kết nối Wi-Fi, kèm thời gian cập nhật gói tin cuối cùng (`Last seen: 2 minutes ago`).
  2. **Widget Điều khiển Máy bơm / Quạt / Đèn (Actuator Controls):**
     - Nút bấm bật/tắt máy bơm có trạng thái `Loading` chờ ESP32 xác nhận đã đóng rơ-le thành công, tránh việc người dùng bấm trên App thấy sáng đèn nhưng thực tế ngoài vườn máy bơm chưa chạy.
  3. **Hệ thống Cảnh báo Tự động (Automations & Alerts):**
     - Cho phép cài đặt luật: *"Nếu Nhiệt độ > 38°C HOẶC Độ ẩm đất < 20% → Gửi Email / Push Notification cảnh báo ngay lập tức"*. (Dự án của bạn đã có package `mailer`, rất phù hợp để phát triển mạnh tính năng này!).

---

## 3. Planta — Smart Plant Care Assistant (Thụy Điển)
* **Điểm mạnh cốt lõi:** Thiết kế giao diện (UI/UX) đạt giải thưởng quốc tế, cực kỳ hiện đại và thân thiện.
* **Các tính năng nổi bật:**
  1. **Dr. Planta & Smart Watering Schedule:** Tự động tính toán lại ngày tưới nước nếu trời mưa hoặc độ ẩm không khí tăng cao.
  2. **Light Meter (Đo ánh sáng):** Hướng dẫn người dùng đặt chậu cây ở vị trí có lượng ánh sáng phù hợp.
  3. **Nhật ký phát triển của cây (Plant Journal):** Lưu lại ảnh chụp của cây theo từng tháng kèm kết quả các lần quét bệnh trước đó để theo dõi quá trình hồi phục.

---

## 4. Blossom — Plant Care & Hydroponics Guide
* **Điểm mạnh cốt lõi:** Tích hợp công cụ tính lượng nước (Water Calculator) và hướng dẫn chi tiết cho cả trồng đất lẫn thủy canh.
* **Các tính năng nổi bật:**
  1. **Thẻ Tóm tắt Yêu cầu Sinh trưởng (Quick Care Cards):** Hiển thị 4 ô vuông nhỏ gọn (Bento Grid) gồm: *Nhu cầu nước*, *Ánh sáng*, *Nhiệt độ*, *Loại đất & Phân bón*.
  2. **Nhắc nhở Đa tác vụ:** Không chỉ nhắc tưới nước mà còn nhắc: *Bón phân (Fertilize)*, *Phun sương (Mist)*, *Cắt tỉa (Prune)*, *Xoay chậu cây (Rotate)*.

---

## 💡 Gợi ý Tối ưu cho `Smart Agriculture App` từ Nhóm App IoT

1. **Hiển thị Ngưỡng Chuẩn trên Dashboard:** Bên cạnh con số nhiệt độ, độ ẩm, ánh sáng lấy từ Firebase Realtime Database, hãy hiển thị nhãn trạng thái nhanh (`Tối ưu`, `Thiếu nước`, `Quá nóng`) để người dùng hiểu ngay tình trạng cây chỉ trong 1 giây nhìn màn hình.
2. **Lưu Lịch sử Quét Bệnh AI vào Supabase:** Mỗi khi người dùng dùng tính năng `HealthAnalysisView` để quét ảnh lá cây, bạn có thể lưu lại kết quả (`diseaseName`, `severity`, `createdAt`) lên bảng Supabase để tạo thành "Bệnh án điện tử của vườn cây".
