# 🌱 Danh sách Ứng dụng Tham khảo về Chăm sóc Cây trồng & Nông nghiệp Thông minh

Thư mục này tổng hợp và phân tích chi tiết các **Ứng dụng Chăm sóc Cây trồng, Chẩn đoán Bệnh cây bằng AI, và Quản lý IoT Nông nghiệp** nổi bật nhất trên thế giới và tại Việt Nam. Đây là nguồn tư liệu tham khảo trực tiếp để hoàn thiện giao diện (UI/UX), luồng AI, và hệ thống cảm biến ESP32 của dự án **Smart Agriculture App**.

---

## 📊 Bảng Tổng hợp & So sánh Nhanh 12 Ứng dụng Tiêu biểu

| STT | Tên Ứng dụng | Nhóm thế mạnh chính | Tính năng nổi bật nhất | Điểm cần học hỏi cho Smart Agriculture App |
| :-: | :--- | :--- | :--- | :--- |
| **1** | **Plantix** | 🔬 AI Bác sĩ Nông nghiệp | Nhận diện >700 sâu bệnh trên 30+ loại cây nông nghiệp; diễn đàn nông dân lớn nhất thế giới. | Cách chia phác đồ điều trị thành: *Triệu chứng → Nguyên nhân → Biện pháp Sinh học → Biện pháp Hóa học*. |
| **2** | **PictureThis** | 📸 AI Nhận diện & Chẩn đoán | Tốc độ nhận diện <2 giây, độ chính xác 98%, giao diện quét ảnh cực đẹp. | Hiệu ứng tia quét (Scan line) và thẻ chẩn đoán sức khỏe cây trực quan. |
| **3** | **Plant Parent** | 🩺 Chẩn đoán & Lịch chăm sóc | Chẩn đoán bệnh qua lá, đo ánh sáng bằng cảm biến điện thoại, tính lượng nước tưới. | Bố cục thẻ Bento hiển thị mức độ nghiêm trọng của bệnh và các bước xử lý từng bước (Action Plan). |
| **4** | **Agrio** | 🛰️ AI Bảo vệ Thực vật & Vệ tinh | AI phân tích bệnh cây chuyên sâu kết hợp cảnh báo dịch bệnh theo vị trí GPS và ảnh vệ tinh. | Hệ thống cảnh báo sớm dịch bệnh và thời tiết cực đoan theo vùng địa lý. |
| **5** | **Planta** | 📅 Quản lý Lịch tưới Thông minh | Thuật toán tự động điều chỉnh lịch tưới dựa trên thời tiết thực tế, mùa, kích thước chậu và loại đất. | Không dùng lịch tưới cố định cứng nhắc mà kết hợp cảm biến độ ẩm đất + thời tiết. |
| **6** | **Blossom** | 🌿 Cẩm nang Chăm sóc & Thủy canh | Kho dữ liệu hướng dẫn trồng cây, thay chậu, pha dinh dưỡng thủy canh và đo ánh sáng (Light Meter). | Tích hợp từ điển thông số chuẩn (Nhiệt độ, Độ ẩm, Ánh sáng lý tưởng) cho từng loại cây. |
| **7** | **Xiaomi Flower Care (VegTrug)** | 📡 Cảm biến IoT Cây trồng | Kết nối cảm biến cắm đất 4-trong-1 (Độ ẩm đất, Nhiệt độ, Ánh sáng, Độ màu mỡ EC) lên App. | **Giống nhất với bài toán ESP32 của dự án:** So sánh chỉ số cảm biến thực tế với ngưỡng chuẩn của cây. |
| **8** | **Blynk IoT** | ⚙️ Dashboard IoT & Điều khiển | Nền tảng biểu đồ thời gian thực, nút gạt điều khiển máy bơm/rơ-le từ xa cho ESP32/Arduino. | Cách thiết kế biểu đồ lịch sử cảm biến (1H, 1D, 1W, 1M) và cơ chế phản hồi trạng thái nút bật/tắt bơm. |
| **9** | **CropX** | 🚜 IoT Nông trại Quy mô lớn | Cảm biến đất đa tầng kết hợp dữ liệu thủy văn và tự động hóa hệ thống tưới tiêu. | Giao diện báo cáo tiết kiệm nước và phân tích xu hướng độ ẩm đất. |
| **10** | **Enfarm (Việt Nam)** | 🇻🇳 IoT Cảm biến Đất + AI Việt | Startup AgTech Việt Nam: Cảm biến đo NPK/độ ẩm đất chính xác kết hợp Chatbot AI khuyến nông tiếng Việt. | Cách bản địa hóa thuật ngữ nông nghiệp và tư vấn phân bón/thuốc BVTV phù hợp thổ nhưỡng Việt Nam. |
| **11** | **MobiAgri (Việt Nam)** | 🇻🇳 AI Nhận diện & Chuyên gia | Ứng dụng của MobiFone: AI nhận diện sâu bệnh cây trồng Việt Nam, kho kỹ thuật canh tác và kết nối chuyên gia. | Xây dựng kho dữ liệu chuẩn (RAG) cho các loại cây phổ biến tại Việt Nam (Lúa, Cà phê, Sầu riêng, Rau màu). |
| **12** | **NextFarm (Việt Nam)** | 🇻🇳 Tự động hóa Tưới & Châm phân | Hệ thống điều khiển tưới và châm phân tự động thông minh phổ biến nhất tại các nông trại công nghệ cao VN. | Quy trình điều khiển tự động theo kịch bản (ví dụ: Độ ẩm đất < 40% tự bật bơm 5 phút). |

---

## 📁 Chi tiết từng nhóm trong thư mục này

1. 📄 **[01_App_AI_Chan_Doan_Benh_Cay.md](./01_App_AI_Chan_Doan_Benh_Cay.md)**  
   *Phân tích sâu các App dùng AI/Computer Vision quét lá cây (Plantix, PictureThis, Plant Parent, Agrio) và cách họ chống AI Hallucination.*
2. 📄 **[02_App_Cham_Soc_Cay_Va_IoT_Cam_Bien.md](./02_App_Cham_Soc_Cay_Va_IoT_Cam_Bien.md)**  
   *Phân tích sâu các App kết nối phần cứng IoT cảm biến đất/môi trường và quản lý lịch chăm sóc (Xiaomi Flower Care, Planta, Blossom, Blynk IoT).*
3. 📄 **[03_App_Nong_Nghiep_Viet_Nam.md](./03_App_Nong_Nghiep_Viet_Nam.md)**  
   *Phân tích các ứng dụng Nông nghiệp Thông minh thành công tại thị trường Việt Nam (Enfarm, MobiAgri, NextFarm).*
