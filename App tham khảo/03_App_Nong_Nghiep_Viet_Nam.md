# 🇻🇳 Nhóm 3: Các Ứng dụng Nông nghiệp Thông minh Tiêu biểu tại Việt Nam

Việc tham khảo các ứng dụng được phát triển trực tiếp cho **nông dân và người trồng cây tại Việt Nam** giúp dự án **Smart Agriculture App** có ngôn ngữ giao diện, danh mục sâu bệnh và kịch bản IoT sát với thực tế địa phương nhất.

---

## 1. Enfarm — Nông nghiệp Chính xác bằng IoT & AI (Startup AgTech Việt Nam)
* **Giới thiệu:** Một trong những ứng dụng AgTech nổi bật nhất Việt Nam hiện nay, kết hợp bộ cảm biến cắm đất đo thời gian thực với ứng dụng di động tích hợp AI.
* **Tính năng cốt lõi:**
  1. **Đo đạc chỉ số đất theo thời gian thực:** Theo dõi độ ẩm đất, nhiệt độ đất, độ dẫn điện (EC) và hàm lượng dinh dưỡng đa lượng (N - P - K) ngay trên điện thoại.
  2. **Khuyến nghị Tưới & Bón phân Chính xác:** Thay vì để nông dân bón phân theo cảm tính, app tính toán lượng nước và lượng phân cần bổ sung dựa trên dữ liệu cảm biến thực tế, giúp tiết kiệm 30–50% chi phí phân bón và nước tưới.
  3. **Trợ lý AI Nông nghiệp Tiếng Việt:** Tích hợp AI nhận diện bệnh cây và trả lời câu hỏi kỹ thuật canh tác bằng tiếng Việt tự nhiên cho các cây trồng chủ lực (Cà phê, Sầu riêng, Hồ tiêu, Cây ăn trái, Rau màu).

---

## 2. MobiAgri — Nền tảng Nông nghiệp Số Toàn diện
* **Giới thiệu:** Ứng dụng nông nghiệp thông minh hợp tác phát triển bởi MobiFone và WeatherPlus.
* **Tính năng cốt lõi:**
  1. **AI Chẩn đoán Sâu bệnh Cây trồng Việt Nam:** Chụp/tải ảnh lá cây để nhận diện bệnh và gợi ý hoạt chất thuốc bảo vệ thực vật được phép lưu hành tại Việt Nam.
  2. **Kho Dữ liệu Kỹ thuật Canh tác Chuẩn:** Cung cấp quy trình trồng và chăm sóc từ lúc gieo hạt đến khi thu hoạch của hơn 50 loại cây trồng phổ biến tại Việt Nam (dữ liệu đã được chuyên gia nông học kiểm duyệt — rất tốt để làm nguồn dữ liệu RAG chống Hallucination).
  3. **Dự báo Thời tiết Nông vụ & Cảnh báo Sâu bệnh theo Mùa:** Cảnh báo sớm các đợt rét đậm, nắng nóng, hoặc mùa bùng phát rầy nâu, đạo ôn, bọ phấn trắng.

---

## 3. NextFarm — Hệ thống Điều khiển Nông nghiệp Thông minh (NextX)
* **Giới thiệu:** Hệ sinh thái phần cứng IoT và phần mềm quản lý trang trại thông minh được triển khai rộng rãi tại Đà Lạt, Sơn La, Đồng bằng Sông Cửu Long.
* **Tính năng cốt lõi:**
  1. **Điều khiển Tưới & Châm phân Tự động (Fertigation):** Điều khiển đóng/mở van điện từ, máy bơm theo3 chế độ:
     - *Chế độ Thủ công (Manual):* Bật/tắt trực tiếp trên App điện thoại.
     - *Chế độ Định giờ (Schedule):* Hẹn giờ tưới cố định trong ngày.
     - *Chế độ Tự động theo Cảm biến (Sensor-based Auto):* Tự động bật tưới khi độ ẩm đất xuống dưới ngưỡng `Min` và tự ngắt khi đạt ngưỡng `Max`.
  2. **Nhật ký Đồng ruộng & Truy xuất Nguồn gốc (QR Code):** Ghi chép lịch sử chăm sóc, phun thuốc để xuất mã QR truy xuất nguồn gốc nông sản sạch (VietGAP / GlobalGAP).

---

## 4. Bác Sĩ Cây Trồng / Nông Nghiệp Xanh (Các App Khuyến nông Địa phương)
* **Điểm mạnh:**
  - Phân loại bệnh theo bộ phận cây rất trực quan: **Bệnh trên Lá**, **Bệnh trên Thân/Cành**, **Bệnh ở Rễ**, **Bệnh trên Hoa/Quả**.
  - Ngôn từ bình dị, dễ hiểu, có hình ảnh minh họa rõ ràng từng giai đoạn phát triển của sâu bệnh.

---

## 🎯 Định vị Độc đáo cho `Smart Agriculture App` của Bạn

Qua việc phân tích các ứng dụng trên, **Smart Agriculture App** của bạn đang sở hữu một cấu trúc lai (Hybrid Architecture) rất mạnh mẽ vì kết hợp được cả 2 thế giới trong cùng một ứng dụng Flutter gọn nhẹ:
1. **Thế giới IoT Phần cứng (như Xiaomi Flower Care / NextFarm):** Thu thập dữ liệu cảm biến từ mạch **ESP32** theo thời gian thực qua **Firebase Realtime Database** và vẽ biểu đồ trực quan với `fl_chart`.
2. **Thế giới AI Thị giác Máy tính (như Plantix / PictureThis):** Giao diện quét ảnh lá cây từ thư viện điện thoại theo phong cách Bento hiện đại (`design5.txt`), phân tích mức độ bệnh, nhận định AI và đưa ra kế hoạch hành động (`Action Plan`) được bảo vệ bởi cơ chế giới hạn 5000 ký tự và các chốt chặn chống ảo giác (**Agent Skills**).
