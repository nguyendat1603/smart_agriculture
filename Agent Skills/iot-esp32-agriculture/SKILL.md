---
name: iot-esp32-agriculture
description: IoT hardware-software integration playbook adapted from sickn33/agentic-awesome-skills for ESP32 smart agriculture sensors, telemetry filtering, offline resilience, and safe automated irrigation control.
---

# IoT & ESP32 Smart Agriculture Architect

## 1. Tổng quan (Overview)
Trong hệ thống Nông nghiệp Thông minh (**Smart Agriculture App**), dữ liệu từ thế giới vật lý (cảm biến độ ẩm đất, DHT11/DHT22, cảm biến ánh sáng BH1750/LDR) và các cơ cấu chấp hành (máy bơm nước, van điện từ, đèn quang hợp) kết nối qua **ESP32** cần được kiểm soát chặt chẽ để tránh sai số phần cứng hoặc tai nạn tưới tràn ngập úng.

---

## 2. Chống "Ảo giác Cảm biến" (Sensor Noise & Anomaly Filtering)

Cảm biến nông nghiệp giá rẻ thường bị nhiễu điện từ hoặc đứt dây tạm thời (ví dụ: DHT22 trả về `NaN` hoặc `-999`, cảm biến độ ẩm đất trả về `0%` hoặc `100%` đột ngột).

### 2.1. Kiểm tra Ngưỡng Vật lý Hợp lệ (Sanity Bounds Check)
Trước khi hiển thị lên Dashboard hoặc đưa vào thuật toán tưới tự động, App và ESP32 phải lọc bỏ các giá trị phi vật lý:
- **Nhiệt độ môi trường:** Hợp lệ trong khoảng `-10°C` đến `65°C`. (Ngoài khoảng này → Báo trạng thái `"Lỗi cảm biến nhiệt độ"` thay vì vẽ lên biểu đồ làm hỏng tỉ lệ trục Y).
- **Độ ẩm không khí & Độ ẩm đất:** Hợp lệ trong khoảng `0%` đến `100%`.
- **Ánh sáng (Lux):** Hợp lệ `>= 0`.

### 2.2. Phát hiện Thiết bị Mất Kết nối (Heartbeat / Stale Data Detection)
- Dữ liệu trên Firebase Realtime Database phải kèm theo `timestamp` (thời점 cập nhật cuối cùng từ ESP32).
- Nếu `DateTime.now().difference(lastUpdate).inMinutes > 5`, giao diện Flutter phải hiển thị cảnh báo **"Thiết bị ESP32 đang ngoại tuyến (Dữ liệu cũ)"** để người dùng không bị đánh lừa bởi các con số đứng yên.

---

## 3. Cơ chế An toàn khi Điều khiển Máy bơm Tự động (Irrigation Fail-Safe)

1. **Giới hạn Thời gian Bơm Tối đa (Max Pump Duration Watchdog):**
   - Khi người dùng bấm bật máy bơm từ App Flutter, ESP32 phải có bộ đếm thời gian tự ngắt (ví dụ: tự động tắt sau tối đa 10–15 phút) phòng trường hợp điện thoại mất mạng hoặc rớt Wi-Fi không gửi được lệnh tắt.
2. **Xác nhận Trạng thái 2 Chiều (State Acknowledgment):**
   - Nút gạt bật/tắt bơm trên App không nên chỉ đổi trạng thái cục bộ trên UI, mà phải phản ánh đúng trạng thái thực tế phản hồi từ ESP32 qua Firebase.
