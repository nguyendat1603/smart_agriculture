---
name: computer-vision-plant-ai
description: Edge AI (TensorFlow Lite / MobileNetV2 / EfficientNet / YOLO) and Cloud Vision playbook adapted from sickn33/agentic-awesome-skills (computer-vision-expert) for plant leaf disease classification and image processing in Flutter.
---

# Computer Vision & Plant Disease AI Expert

## 1. Tổng quan (Overview)
Skill này chuẩn hóa toàn bộ quy trình **Thị giác máy tính (Computer Vision)** cho tính năng quét ảnh lá cây chẩn đoán bệnh trong **Smart Agriculture App**, hỗ trợ linh hoạt cả 2 chế độ:
1. **On-Device Edge AI (Offline):** Sử dụng mô hình `.tflite` (MobileNetV2, EfficientNet-Lite0, hoặc YOLOv8-nano) chạy trực tiếp trên điện thoại Android.
2. **Cloud Vision AI (Online Fallback):** Sử dụng API Vision (hoặc kết hợp cả hai theo mô hình Hybrid).

---

## 2. Quy trình Tiền xử lý Ảnh Chuẩn từ Thư viện (`image_picker`)

Khi lấy ảnh từ thư viện máy điện thoại (`ImageSource.gallery`), ảnh gốc từ camera hiện đại thường có độ phân giải rất lớn (4000x3000px, dung lượng 5–15MB). Để tránh tràn bộ nhớ và tăng tốc độ suy luận (inference):

### 2.1. Nén & Giới hạn Kích thước Ngay khi Chọn Ảnh
```dart
final XFile? pickedFile = await ImagePicker().pickImage(
  source: ImageSource.gallery,
  maxWidth: 1024,      // Giảm kích thước vừa đủ để giữ chi tiết vết bệnh trên lá
  maxHeight: 1024,
  imageQuality: 85,    // Giảm dung lượng file xuống ~200KB - 400KB
);
```

### 2.2. Chuẩn hóa Tensor Đầu vào cho Mô hình TFLite
Nếu sử dụng `tflite_flutter` với mô hình tự train (ví dụ `MobileNetV2`):
- **Kích thước chuẩn (Input Shape):** Thường là `[1, 224, 224, 3]` (Batch = 1, Height = 224, Width = 224, Channels = RGB).
- **Chuẩn hóa giá trị điểm ảnh (Normalization):**
  - Nếu model là **Float32**: Đưa giá trị RGB từ `[0, 255]` về `[0.0, 1.0]` (chia cho `255.0`) hoặc `[-1.0, 1.0]` (`(pixel - 127.5) / 127.5`) đúng theo cấu hình lúc train trên Colab.
  - Nếu model đã **Quantized (Int8 / UInt8)**: Giữ nguyên giá trị nguyên `[0, 255]`.
  - *Cảnh báo chống Hallucination:* Sai chuẩn hóa (ví dụ model cần `[0, 1]` nhưng truyền `[0, 255]`) sẽ khiến model dự đoán sai 100% sang một nhãn cố định!

---

## 3. Quy chuẩn Thiết kế Tập Nhãn (`labels.txt`) để Chống Nhận diện Sai

Khi tự train model nhận diện bệnh cây trồng, tập dữ liệu **bắt buộc** phải có tối thiểu 2 lớp bảo vệ ngoài các lớp bệnh:
1. `0_Healthy_Leaf` (Lá khỏe mạnh bình thường).
2. `1_Background_Not_Plant` (Ảnh nền, đồ vật, con người, không phải lá cây — giúp model biết từ chối ảnh rác).
3. Các lớp bệnh cụ thể (`2_Mosaic_Virus`, `3_Leaf_Spot`, `4_Powdery_Mildew`, v.v.).

### Quy tắc Hậu xử lý Kết quả (Post-Processing):
- Lấy nhãn có điểm xác suất cao nhất (`topConfidence`).
- Nếu nhãn là `1_Background_Not_Plant` **HOẶC** `topConfidence < 0.60` (60%):
  - Báo cho người dùng: *"Không nhận diện rõ lá cây hoặc triệu chứng bệnh (Độ tin cậy thấp). Vui lòng chọn ảnh chụp cận cảnh, rõ nét bề mặt lá dưới ánh sáng tự nhiên."*
- Luôn cắt ngắn văn bản tư vấn trả về ở mức tối đa **5000 ký tự** trước khi hiển thị lên UI.
