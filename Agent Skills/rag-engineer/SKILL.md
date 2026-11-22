---
name: rag-engineer
description: Retrieval-Augmented Generation (RAG) architecture and grounding playbook from sickn33/agentic-awesome-skills. Essential for grounding the Smart Agriculture App's AI Plant Doctor and Chatbot in verified agronomic knowledge to eliminate medical/agricultural hallucinations.
---

# RAG Engineer — Neo Dữ liệu Tri thức Nông nghiệp Chống Ảo giác

## 1. Tổng quan (Overview)
Các mô hình ngôn ngữ lớn (LLM) hoặc mô hình phân loại ảnh (TFLite) khi hoạt động độc lập thường mắc chứng **ảo giác tri thức nông nghiệp** (ví dụ: nhận diện đúng tên bệnh "Bệnh Khảm Lá" nhưng lại khuyên dùng thuốc kháng sinh vốn chỉ trị vi khuẩn chứ không trị được virus).

Skill `rag-engineer` từ `sickn33/agentic-awesome-skills` giải quyết triệt để vấn đề này theo nguyên lý:
> **"Chất lượng truy xuất quyết định chất lượng câu trả lời — Không bao giờ để AI tự bịa phác đồ điều trị từ trí nhớ tham số."**

---

## 2. Kiến trúc Hybrid AI + RAG cho Smart Agriculture App

Khi bạn tự train mô hình **TFLite (MobileNetV2 / EfficientNet)** để chạy offline hoặc kết hợp với **Supabase / Cloud LLM**, hãy áp dụng mô hình **2 giai đoạn (2-Stage Grounded Diagnosis)**:

```text
[Ảnh lá cây từ Thư viện]
        │
        ▼
[Giai đoạn 1: Vision Model (TFLite / Gemini Vision)]
  → Chỉ trả về: Mã bệnh (disease_id) + Độ tự tin (confidence_score)
        │
        ▼
[Giai đoạn 2: Knowledge Retrieval (Tra cứu Cơ sở Dữ liệu Chuẩn)]
  → Truy xuất phác đồ điều trị đã được kiểm duyệt từ JSON local / Supabase
        │
        ▼
[Hiển thị lên UI (< 5000 ký tự, chính xác 100%, 0% Hallucination)]
```

---

## 3. Chiến lược Triển khai RAG Nông nghiệp (Implementation Blueprint)

### 3.1. Xây dựng Kho Tri thức Chuẩn (Verified Agronomy Knowledge Base)
Thay vì để AI tự sinh văn bản tự do hoàn toàn, hãy lưu trữ một từ điển tri thức chuẩn (trong `assets/data/plant_diseases_kb.json` hoặc bảng `disease_knowledge_base` trên **Supabase**) lấy nguồn từ:
- Viện Bảo vệ Thực vật / Bộ Nông nghiệp & PTNT.
- Tài liệu khuyến nông chính thống (FAO, PlantVillage).

Mỗi bản ghi bệnh bao gồm:
```json
{
  "label_id": "mosaic_virus",
  "diseaseName": "Bệnh Khảm Lá (Mosaic Virus)",
  "severity": "Nghiêm trọng",
  "verified_symptoms": "Lá xuất hiện các mảng màu vàng xanh xen kẽ, phiến lá xoăn và biến dạng, cây còi cọc.",
  "verified_advice": "Virus không có thuốc đặc trị hóa học. Cần tiêu hủy cây bệnh và diệt côn trùng môi giới (bọ phấn trắng, rệp).",
  "verified_action_plan": [
    "Cách ly & Tiêu hủy|Nhổ bỏ cây nhiễm bệnh nặng đem tiêu hủy xa khu vực canh tác.",
    "Kiểm soát Vector truyền bệnh|Phun chế phẩm sinh học hoặc dầu khoáng kiểm soát bọ phấn trắng và rệp sáp.",
    "Khử trùng Nông cụ|Ngâm kéo cắt tỉa trong dung dịch khử trùng (Javen 10% hoặc cồn 70 độ) trước khi chuyển sang cây khác."
  ]
}
```

### 3.2. Quy tắc Neo Ngữ cảnh (Context Boundary Rules) khi dùng LLM / Chatbot
Nếu sử dụng Gemini hoặc LLM để tư vấn sâu hơn dựa trên tài liệu truy xuất được:
1. **Strict System Prompt:**  
   *"Chỉ trả lời dựa trên tài liệu kỹ thuật nông nghiệp được cung cấp trong phần `<CONTEXT>`. Nếu tài liệu không đề cập đến liều lượng thuốc cụ thể, hãy trả lời rõ là cần tham khảo nhãn bao bì của nhà sản xuất, TUYỆT ĐỐI KHÔNG tự suy diễn liều lượng."*
2. **Trích dẫn Nguồn (Citation):** Hiển thị nguồn khuyến nông rõ ràng bên dưới lời khuyên chuyên gia.
3. **Kiểm soát Độ dài (Chunk & Output Limit):** Luôn giới hạn tổng văn bản trả về dưới **5000 ký tự** để tương thích hoàn toàn với màn hình `HealthAnalysisView`.
