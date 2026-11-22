# 🛡️ Agent Skills Catalog — Smart Agriculture App
> **Nguồn tham khảo & Tuyển chọn từ:** [sickn33/agentic-awesome-skills](https://github.com/sickn33/agentic-awesome-skills) *(Antigravity Awesome Skills)*

Thư mục này chứa bộ **Playbook Kỹ năng (`SKILL.md`)** được tuyển chọn và tinh chỉnh chuyên biệt cho dự án **Smart Agriculture App** (Flutter 3.12+, Firebase Realtime Database, Supabase, ESP32 IoT, và AI Chẩn đoán bệnh cây trồng Gemini / TFLite).

Đặc biệt, bộ kỹ năng này đặt **trọng tâm cao nhất vào việc Chống Ảo giác AI (Anti-Hallucination)** ở cả 2 tầng:
1. **Chống Hallucination cho Coding Agent (Claude, Cursor, Antigravity, Gemini CLI):** Ngăn AI tự bịa đặt API cũ, đoán mò nguyên nhân lỗi, hoặc báo cáo "đã hoàn thành" khi chưa chạy kiểm thử thực tế.
2. **Chống Hallucination cho AI Chẩn đoán Bệnh Cây bên trong App:** Ngăn mô hình Vision/LLM (Gemini hoặc TFLite) phán bừa tên bệnh khi ảnh mờ, không phải lá cây, hoặc đưa ra liều lượng thuốc bảo vệ thực vật sai lệch gây hại cho mùa màng.

---

## 📂 Cấu trúc Danh mục Skills trong thư mục này

### 🔴 Nhóm 1: Chống Hallucination & Kiểm chứng Sự thật (Anti-Hallucination & Verification Core)
| Thư mục Skill | Tên Skill (từ `agentic-awesome-skills`) | Mục đích cốt lõi |
| :--- | :--- | :--- |
| [`anti-hallucination-guardrails`](./anti-hallucination-guardrails/SKILL.md) | `clarity-gate` + `hallucination-mitigation` | **Chốt chặn chống ảo giác kép:** Kiểm soát độ tin cậy (Confidence Threshold), cấm bịa đặt thông tin, bắt buộc gắn nhãn `[UNVERIFIED]` khi thiếu bằng chứng (áp dụng cho cả Code và AI Bác sĩ cây trồng). |
| [`source-driven-development`](./source-driven-development/SKILL.md) | `source-driven-development` | **Lập trình dựa trên tài liệu gốc:** Bắt buộc kiểm tra phiên bản trong `pubspec.yaml` và đối chiếu tài liệu chính thức (Flutter/Firebase/Supabase) trước khi viết code; cấm code theo trí nhớ cũ của LLM. |
| [`verification-before-completion`](./verification-before-completion/SKILL.md) | `verification-before-completion` | **Kiểm chứng trước khi hoàn tất:** Quy tắc sắt *"Không được tuyên bố hoàn thành nếu chưa có bằng chứng chạy lệnh thực tế"* (`flutter analyze`, `flutter test`, build check). |
| [`doubt-driven-development`](./doubt-driven-development/SKILL.md) | `doubt-driven-development` | **Phản biện độc lập (Adversarial Review):** Đưa mọi quyết định kiến trúc phức tạp qua một vòng tự phản biện độc lập để tìm lỗ hổng logic trước khi áp dụng. |
| [`rag-engineer`](./rag-engineer/SKILL.md) | `rag-engineer` | **Kiến trúc RAG chống ảo giác nông nghiệp:** Hướng dẫn neo dữ liệu (Grounding) cho AI Chatbot/Chẩn đoán bệnh cây vào cơ sở dữ liệu nông nghiệp chuẩn thay vì để LLM tự suy diễn. |
| [`human-skill-main`](./human-skill-main/human/SKILL.md) | `human` (StoryScope) | **Viết báo cáo và nội dung tự nhiên như người thật:** Dựng lại khung bài viết theo 9 nguyên tắc cấu trúc từ nghiên cứu StoryScope và dọn sạch dấu vết văn phong AI. |

---

### 🟢 Nhóm 2: Phát triển App, IoT & Thị giác Máy tính (App Architecture & Domain Skills)
| Thư mục Skill | Tên Skill (từ `agentic-awesome-skills`) | Mục đích cốt lõi |
| :--- | :--- | :--- |
| [`flutter-expert`](./flutter-expert/SKILL.md) | `flutter-expert` | Chuẩn mực kiến trúc **Flutter 3.12+ & Dart 3**, quản lý state với `Provider` (MVVM), kiểm tra `mounted` sau `async`, tối ưu hiệu năng biểu đồ `fl_chart` và xử lý giới hạn 5000 ký tự UI. |
| [`computer-vision-plant-ai`](./computer-vision-plant-ai/SKILL.md) | `computer-vision-expert` | Quy trình xử lý ảnh lá cây từ thư viện (`image_picker`), tiền xử lý ảnh cho **TFLite (MobileNetV2/EfficientNet)** và **Gemini Vision API**, kết hợp ngưỡng từ chối ảnh không hợp lệ. |
| [`firebase-supabase-backend`](./firebase-supabase-backend/SKILL.md) | `firebase` + `supabase` | Phối hợp **Firebase Realtime Database** (luồng dữ liệu cảm biến thời gian thực) và **Supabase** (Auth & PostgreSQL RLS), chống rò rỉ bộ nhớ (`StreamSubscription`) và sai lệch dữ liệu. |
| [`iot-esp32-agriculture`](./iot-esp32-agriculture/SKILL.md) | `iot-architect` | Chuẩn hóa giao tiếp phần cứng **ESP32**, lọc nhiễu cảm biến (nhiệt độ, độ ẩm đất, ánh sáng), cơ chế an toàn (Watchdog/Fail-safe) khi điều khiển máy bơm tưới cây từ xa. |
| [`systematic-debugging`](./systematic-debugging/SKILL.md) | `systematic-debugging` | Phương pháp gỡ lỗi có hệ thống: Khoanh vùng nguyên nhân gốc rễ (Root Cause Analysis) trước khi sửa code, cấm sửa mò làm hỏng luồng đang chạy. |

---

## 🚀 Cách sử dụng bộ Skills này

1. **Dành cho AI Agent trong IDE (Antigravity / Cursor / Claude Code / Windsurf):**
   - Khi yêu cầu AI thực hiện tính năng mới, bạn có thể chỉ định trực tiếp:  
     *"Hãy đọc các skill trong thư mục `Agent Skills` (đặc biệt là `anti-hallucination-guardrails` và `flutter-expert`) trước khi viết code."*
2. **Cài đặt mở rộng từ CLI chính thức của `sickn33/agentic-awesome-skills`:**
   ```bash
   npx agentic-awesome-skills --antigravity
   # Hoặc cài từng skill cụ thể:
   npx -y skills add sickn33/agentic-awesome-skills --skill flutter-expert
   npx -y skills add sickn33/agentic-awesome-skills --skill verification-before-completion
   npx -y skills add sickn33/agentic-awesome-skills --skill rag-engineer
   ```
