# Hướng Dẫn Tích Hợp AI TensorFlow Lite Nhận Diện Lá Cây Vào Ứng Dụng Flutter

Tài liệu này hướng dẫn chi tiết 3 bước để huấn luyện một mô hình AI nhận diện hình ảnh (phát hiện bệnh trên lá cây) và nhúng nó vào ứng dụng Smart Agriculture App.

## Giai Đoạn 1: Chuẩn Bị Dữ Liệu (Dataset)
1. **Thu thập ảnh:** Bạn cần thu thập hình ảnh của các loại lá cây/bệnh bạn muốn nhận diện. Bạn có thể sử dụng bộ dữ liệu **PlantVillage Dataset** có sẵn trên mạng.
2. **Phân loại ảnh:** Tạo các thư mục con, mỗi thư mục tương ứng với 1 loại bệnh (Ví dụ: `la_khoe_manh`, `la_bi_dom_den`). Mỗi thư mục nên có khoảng 100-200 bức ảnh rõ nét.

## Giai Đoạn 2: Huấn Luyện Mô Hình (Train Model)
Sử dụng công cụ không cần lập trình của Google là **Teachable Machine**.

1. Truy cập [Teachable Machine](https://teachablemachine.withgoogle.com/).
2. Chọn **Image Project** > **Standard image model**.
3. Tại giao diện chính, tải các thư mục ảnh lá cây lên và đặt tên tương ứng cho từng "Class" (Nhãn).
4. Bấm nút **Train Model** (Chờ khoảng 2-5 phút).
5. Bấm **Export Model** > Chuyển sang tab **TensorFlow Lite** > Chọn **Floating point** (hoặc Quantized) > Bấm **Download my model**.
6. Giải nén file vừa tải về, bạn sẽ nhận được 2 file: `model.tflite` (mô hình AI) và `labels.txt` (danh sách tên bệnh).

## Giai Đoạn 3: Nhúng Vào Ứng Dụng Flutter

### 1. Thêm file vào cấu trúc dự án
1. Tạo thư mục `assets/models/` ở thư mục gốc của dự án Flutter.
2. Chép 2 file `model.tflite` và `labels.txt` vào thư mục vừa tạo.
3. Mở file `pubspec.yaml`, thêm đường dẫn vào phần `assets`:
```yaml
flutter:
  assets:
    - assets/models/model.tflite
    - assets/models/labels.txt
```

### 2. Cài đặt thư viện cần thiết
Mở Terminal và chạy các lệnh sau để tải thư viện xử lý ảnh và TFLite:
```bash
flutter pub add image_picker
flutter pub add tflite_flutter
```

### 3. Logic Hoạt Động Của Code
Khi bạn đã chuẩn bị xong các bước trên, code Flutter sẽ hoạt động theo luồng sau:
1. Dùng `image_picker` mở Camera để người dùng chụp 1 bức ảnh chiếc lá.
2. Đọc bức ảnh đó và scale (thu nhỏ) kích thước về chuẩn của mô hình (thường là 224x224 pixel).
3. Đẩy mảng pixel của ảnh vào hàm dự đoán của `tflite_flutter`.
4. Nhận về một dải danh sách các xác suất phần trăm (Ví dụ: Đốm đen 90%, Khỏe mạnh 5%, Vàng lá 5%).
5. Đọc file `labels.txt` để lấy tên căn bệnh có xác suất cao nhất và hiển thị lên UI cho người dùng xem.

*Ghi chú: Nếu bạn đã chuẩn bị xong file `model.tflite`, hãy gửi hoặc báo cho tôi để tôi viết trực tiếp mã nguồn code phân tích hình ảnh vào App cho bạn nhé!*
