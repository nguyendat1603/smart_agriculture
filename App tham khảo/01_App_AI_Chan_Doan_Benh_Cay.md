# 🔬 Nhóm 1: Các Ứng dụng AI Nhận diện & Chẩn đoán Bệnh Cây Trồng

Tài liệu này phân tích các ứng dụng hàng đầu thế giới về **Computer Vision (Thị giác máy tính)** trong nông nghiệp, tập trung vào luồng quét ảnh từ thư viện/camera, cách trình bày kết quả chẩn đoán và cách họ kiểm soát sai số (Anti-Hallucination).

---

## 1. Plantix — "Bác sĩ Cây trồng Bỏ túi" (PEAT GmbH - Đức)
* **Đối tượng:** Nông dân, kỹ sư nông nghiệp, người trồng rau màu và cây ăn quả.
* **Quy mô:** Hơn 30 triệu lượt tải, nhận diện hơn 700 loại sâu bệnh, nấm, virus và thiếu hụt dinh dưỡng.
* **Các tính năng cốt lõi:**
  1. **Magic Doctor (Quét ảnh AI):** Người dùng chụp hoặc tải ảnh lá/thân/quả từ thư viện lên. AI trả về tên bệnh kèm phần trăm độ tương đồng (Match Percentage).
  2. **Thư viện ảnh đối chiếu (Visual Verification - Chống Hallucination cực hay):** Khi AI đoán cây bị "Bệnh Khảm Lá", Plantix không chỉ hiện chữ mà hiển thị ngay **3–5 bức ảnh mẫu chuẩn của bệnh đó** để người dùng tự mắt đối chiếu xem lá của mình có giống ảnh mẫu không.
  3. **Phác đồ điều trị 2 hướng:** Luôn tách bạch giữa **Biện pháp Sinh học / Hữu cơ (Biological Control)** và **Biện pháp Hóa học (Chemical Control)** kèm lưu ý phòng ngừa cho vụ sau.
  4. **Cộng đồng Hỏi đáp:** Khi ảnh khó hoặc AI có độ tự tin thấp, người dùng có thể đẩy bài lên cộng đồng chuyên gia trong 1 chạm.

---

## 2. PictureThis — Plant Identifier & Disease Diagnosis
* **Đối tượng:** Người yêu cây cảnh, làm vườn tại nhà (Home Gardening), nông nghiệp đô thị.
* **Các tính năng cốt lõi:**
  1. **Nhận diện định danh & Chẩn đoán bệnh 360°:** Xác định chính xác tên khoa học của cây trước, sau đó mới phân tích vùng lá bị tổn thương (đốm nâu, vàng lá, thối rễ, cháy nắng).
  2. **Giao diện Quét Laser & Bento UI:** Sử dụng hiệu ứng khung ngắm và tia quét mượt mà (tương tự như thiết kế `design5.txt` trong **Smart Agriculture App** của bạn).
  3. **Cảnh báo Độc tính (Toxicity Warning):** Tự động cảnh báo nếu loài cây đó có độc với thú cưng (chó, mèo) hoặc trẻ nhỏ.

---

## 3. Plant Parent — Plant Care Guide & AI Doctor
* **Đối tượng:** Người trồng cây tại nhà, ban công, vườn mini.
* **Các tính năng cốt lõi:**
  1. **Chẩn đoán sức khỏe theo mức độ (Severity Badge):** Phân loại tình trạng cây thành: *Khỏe mạnh (Healthy)*, *Nhẹ (Mild)*, *Trung bình (Moderate)*, *Nghiêm trọng (Critical/Severe)*.
  2. **Kế hoạch hành động từng bước (Step-by-step Action Plan):** Chia nhỏ lời khuyên thành các thẻ hành động ngắn gọn (Ví dụ: *Bước 1: Cắt tỉa lá bệnh → Bước 2: Cách ly → Bước 3: Điều chỉnh tưới nước*), tránh hiển thị một khối văn bản quá dài gây ngợp mắt trên màn hình điện thoại.

---

## 4. Agrio — Precision Plant Protection (Mỹ)
* **Đối tượng:** Trang trại thương mại, hợp tác xã nông nghiệp.
* **Các tính năng cốt lõi:**
  1. **Kết hợp AI Hình ảnh + Ngữ cảnh Môi trường:** Không chỉ nhìn ảnh lá cây, Agrio kết hợp thêm dữ liệu **nhiệt độ, độ ẩm hiện tại** để loại trừ các bệnh không thể phát triển trong điều kiện thời tiết đó (giảm 40% tỷ lệ chẩn đoán sai của AI).
  2. **Giám sát từ Vệ tinh (NDVI):** Theo dõi chỉ số thực vật từ ảnh vệ tinh để phát hiện vùng cây đang bị suy yếu trên cánh đồng.

---

## 💡 Bài học Thiết kế áp dụng trực tiếp vào `Smart Agriculture App`

1. **Kết hợp Cảm biến ESP32 + AI Hình ảnh (Điểm khác biệt độc quyền của App bạn):**
   - Các app như PictureThis chỉ nhìn được bức ảnh. Trong khi đó, **Smart Agriculture App** của bạn có sẵn dữ liệu **Nhiệt độ, Độ ẩm không khí, Độ ẩm đất, Ánh sáng từ ESP32**!
   - *Gợi ý nâng cấp:* Khi gửi ảnh cho AI phân tích, hoặc khi chạy model TFLite xong, có thể đính kèm thông số cảm biến hiện tại (ví dụ: *"Độ ẩm đất đang là 85%, lá bị vàng"* → AI sẽ chẩn đoán chính xác ngay là **Vàng lá do thối rễ/ngập úng** chứ không bị nhầm sang thiếu đạm).
2. **Giới hạn Văn bản & Trình bày:**
   - Giữ vững giới hạn tối đa **5000 ký tự** đã cài đặt trong `AIAnalysisService`, đồng thời tách rõ thành các khối thẻ: `AI Insight`, `Expert Advice`, và `Action Plan` (phân tách tiêu đề và nội dung bằng dấu `|`).
