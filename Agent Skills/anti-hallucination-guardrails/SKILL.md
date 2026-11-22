---
name: anti-hallucination-guardrails
description: Strict epistemic guardrails combining clarity-gate and factual grounding from sickn33/agentic-awesome-skills. Prevents hallucinations in both AI code generation (fake APIs, unverified packages, assumed file paths) and in-app Agricultural AI disease diagnosis (misidentifying non-plant images, fabricating pesticide dosages, or outputting unchecked text).
---

# Anti-Hallucination Guardrails & Clarity Gate

## 1. Mục tiêu cốt lõi (Overview)
Ảo giác (Hallucination) là rủi ro nguy hiểm nhất trong cả **quá trình lập trình bằng AI** lẫn **tính năng AI chẩn đoán bệnh cây trồng** trong ứng dụng **Smart Agriculture App**. Skill này thiết lập 2 tầng bảo vệ:
- **Tầng 1 (Coding Agent Guardrails):** Ngăn AI Agent bịa đặt hàm Dart/Flutter không tồn tại, đoán mò cấu trúc bảng Supabase/Firebase, hoặc tự ý thêm thư viện không có trong `pubspec.yaml`.
- **Tầng 2 (In-App Agricultural AI Guardrails):** Ngăn AI nhận diện bệnh cây (Gemini Vision / TFLite) phán đoán bừa bãi khi ảnh đầu vào không phải là cây trồng, ảnh quá mờ, hoặc tự bịa ra tên hóa chất/liều lượng phân bón nguy hiểm.

---

## 2. Quy tắc Chống Hallucination khi Viết Code (Tầng 1 - Coding Agent)

### Quy tắc 1: Kiểm tra thực tế trước khi tham chiếu (Verify Before Referencing)
- **KHÔNG BAO GIỜ** import một file hoặc package mà chưa đọc `pubspec.yaml` hoặc kiểm tra cây thư mục `lib/`.
- **KHÔNG BAO GIỜ** giả định tên trường (field) trên Firebase Realtime Database hoặc bảng Supabase. Phải đọc `models/` và `services/` hiện có trong dự án.
- Nếu một hàm hoặc API không chắc chắn 100%, bắt buộc phải tra cứu hoặc gắn nhãn `[UNVERIFIED - Cần kiểm tra]`.

### Quy tắc 2: Phân tách Giả thuyết và Sự thật (Fact vs. Hypothesis Separation)
Trước khi đưa ra thay đổi lớn, Agent phải phân loại mọi nhận định theo 3 mức:
1. `[VERIFIED]`: Đã đọc trực tiếp từ file mã nguồn, `pubspec.yaml`, hoặc log chạy thực tế.
2. `[INFERRED]`: Suy luận hợp lý từ code hiện tại nhưng cần kiểm chứng.
3. `[UNKNOWN]`: Chưa rõ thông tin — **Bắt buộc hỏi lại User**, tuyệt đối không tự bịa.

### Quy tắc 3: Cấm "Bịa đặt lặng lẽ" (Zero Silent Fabrication)
- Không tự ý thay đổi logic nghiệp vụ hoặc xóa chức năng cũ khi sửa lỗi.
- Không sinh dữ liệu giả (Mock data) đè lên luồng chạy thật mà không có cảnh báo rõ ràng trên UI (ví dụ: phải ghi chú `(LƯU Ý: Đây là dữ liệu mẫu...)`).

---

## 3. Quy tắc Chống Hallucination cho AI Chẩn đoán Bệnh Cây trong App (Tầng 2 - In-App AI)

Khi phát triển hoặc tinh chỉnh `AIAnalysisService` (`lib/services/ai_analysis_service.dart`) và mô hình TFLite/Gemini, bắt buộc tuân thủ **5 Chốt chặn Sinh học (Bio-Safety Gates)**:

### Gate 1: Kiểm tra đối tượng ảnh (Non-Plant Rejection Gate)
- Nếu người dùng chọn ảnh từ thư viện không phải là lá cây/cây trồng (ví dụ: ảnh người, đồ vật, phong cảnh, ảnh tối đen):
  - AI **phải từ chối chẩn đoán bệnh**.
  - Trả về `diseaseName: "Không phát hiện cây trồng hợp lệ"`, `matchPercentage: 0.0`, và hướng dẫn người dùng chụp rõ bề mặt lá cây bị bệnh.

### Gate 2: Ngưỡng độ tự tin tối thiểu (Confidence Threshold Gate)
- Đối với cả **TFLite (`model.tflite`)** và **Vision LLM**:
  - Nếu `matchPercentage < 60%` (hoặc xác suất Softmax cao nhất `< 0.60`): Không được khẳng định chắc chắn tên bệnh.
  - Phải chuyển trạng thái sang `"Chưa đủ độ tin cậy để kết luận"` và khuyên người dùng chụp lại ảnh rõ nét hơn hoặc tham khảo kỹ sư nông nghiệp.

### Gate 3: Ràng buộc định dạng JSON nghiêm ngặt & Fallback an toàn
- Mọi phản hồi từ LLM phải qua bộ lọc JSON Schema:
  - Kiểm tra đầy đủ các khóa: `diseaseName`, `severity`, `matchPercentage`, `aiInsight`, `expertAdvice`, `actionPlan`.
  - Sử dụng `try-catch` khi `jsonDecode`. Nếu AI trả về chuỗi lỗi hoặc sai cấu trúc, ứng dụng không được crash mà phải hiển thị thông báo lỗi thân thiện.

### Gate 4: Kiểm soát độ dài văn bản tối đa (UI Buffer Overflow Protection)
- Màn hình điện thoại giới hạn hiển thị tối đa **5000 ký tự** cho mỗi trường phân tích (`aiInsight`, `expertAdvice`).
- Bắt buộc duy trì hàm cắt chuỗi an toàn `_truncateText(text, 5000)` ở tầng Service trước khi đẩy dữ liệu xuống ViewModel và View.

### Gate 5: An toàn Hóa chất & Thuốc Bảo vệ Thực vật (Agronomy Safety)
- Trong Prompt hoặc cơ sở dữ liệu nhãn (Labels metadata):
  - **Cấm AI tự bịa ra liều lượng pha chế hóa chất độc hại** nếu không nằm trong danh mục khuyến nghị chuẩn.
  - Ưu tiên các biện pháp canh tác an toàn, cách ly cây bệnh, chế phẩm sinh học và khuyến cáo người dùng đọc kỹ hướng dẫn của nhà sản xuất trên bao bì.

---

## 4. Checklist Kiểm tra (Verification Checklist)
- [ ] Đã kiểm tra `pubspec.yaml` trước khi dùng bất kỳ API/package nào chưa?
- [ ] AI trong app đã có bước kiểm tra ảnh không phải lá cây (`isPlant == false` hoặc độ tin cậy thấp) chưa?
- [ ] Dữ liệu text từ AI đã được giới hạn `<= 5000` ký tự bằng `_truncateText` chưa?
- [ ] Mọi thông tin chưa chắc chắn đã được báo cáo minh bạch cho người dùng thay vì tự suy diễn chưa?
