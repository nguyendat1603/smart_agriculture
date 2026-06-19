import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIAnalysisResult {
  final String diseaseName;
  final String severity; // "Nghiêm trọng", "Trung bình", "Nhẹ"
  final double matchPercentage;
  final String aiInsight;
  final String expertAdvice;
  final List<String> actionPlan;

  AIAnalysisResult({
    required this.diseaseName,
    required this.severity,
    required this.matchPercentage,
    required this.aiInsight,
    required this.expertAdvice,
    required this.actionPlan,
  });
}

class AIAnalysisService {
  /// Hàm gửi ảnh cho AI (Gemini) và nhận lại kết quả phân tích.
  Future<AIAnalysisResult> analyzeImage(File image) async {
    // 1. Lấy API key từ file .env
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      // Nếu chưa có API key thì dùng dữ liệu mẫu (Mock)
      return _getMockResult();
    }

    try {
      // Khởi tạo model Gemini (gemini-1.5-flash tốt và nhanh cho nhận diện ảnh)
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      // Đọc file ảnh dưới dạng bytes
      final imageBytes = await image.readAsBytes();
      
      // Khai báo prompt yêu cầu AI trả về chuẩn cấu trúc JSON
      final prompt = TextPart('''
Bạn là một chuyên gia nông nghiệp AI. Hãy phân tích hình ảnh cây trồng này để chẩn đoán bệnh.
Hãy trả về ĐÚNG định dạng JSON như sau, không kèm bất kỳ format markdown (```json) nào khác:
{
  "diseaseName": "Tên bệnh (ví dụ: Bệnh Khảm Lá (Mosaic Virus))",
  "severity": "Mức độ nghiêm trọng (ví dụ: Nghiêm trọng, Trung bình, Nhẹ)",
  "matchPercentage": 96.4,
  "aiInsight": "Một đoạn văn mô tả chi tiết những gì AI nhìn thấy trên lá và ảnh hưởng của nó đến cây trồng. (Tối đa 200 chữ)",
  "expertAdvice": "Lời khuyên từ chuyên gia nông nghiệp về nguyên nhân và cách xử lý tổng quan. (Tối đa 200 chữ)",
  "actionPlan": [
    "Hành động 1|Mô tả chi tiết hành động 1",
    "Hành động 2|Mô tả chi tiết hành động 2"
  ]
}
''');

      // Tạo DataPart chứa ảnh
      final imagePart = DataPart('image/jpeg', imageBytes);

      // Gọi API Gemini
      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      if (response.text != null) {
        String jsonText = response.text!.trim();
        // Xóa block quote markdown nếu Gemini trả về
        if (jsonText.startsWith('```json')) {
          jsonText = jsonText.substring(7);
        }
        if (jsonText.endsWith('```')) {
          jsonText = jsonText.substring(0, jsonText.length - 3);
        }
        jsonText = jsonText.trim();

        // Parse JSON
        final Map<String, dynamic> data = jsonDecode(jsonText);

        // Áp dụng giới hạn độ dài hiển thị trên màn hình
        return AIAnalysisResult(
          diseaseName: data['diseaseName'] ?? 'Không rõ',
          severity: data['severity'] ?? 'Không rõ',
          matchPercentage: (data['matchPercentage'] as num?)?.toDouble() ?? 0.0,
          aiInsight: _truncateText(data['aiInsight'] ?? '', 5000),
          expertAdvice: _truncateText(data['expertAdvice'] ?? '', 5000),
          actionPlan: List<String>.from(data['actionPlan'] ?? []),
        );
      } else {
        throw Exception("AI không trả về kết quả.");
      }
    } catch (e) {
      print('AI Error: \$e');
      throw Exception("Lỗi khi kết nối với AI: \$e");
    }
  }

  // Dữ liệu mô phỏng trong trường hợp chưa có API Key
  AIAnalysisResult _getMockResult() {
    String insightText =
        "Hệ thống thị giác máy tính đã phát hiện các mảng màu vàng không đều và biến dạng hình thái trên bề mặt lá. Sự đổi màu này làm suy giảm đáng kể lượng diệp lục, dẫn đến ức chế khả năng quang hợp và có nguy cơ làm giảm năng suất cây trồng diện rộng.";
    
    String adviceText =
        "Virus khảm không có thuốc đặc trị. Biện pháp tốt nhất là phòng ngừa. Khử trùng nghiêm ngặt toàn bộ nông cụ cắt tỉa bằng dung dịch natri hypochlorite 10% để cắt đứt nguồn lây lan cơ học. (LƯU Ý: Đây là dữ liệu mẫu vì bạn chưa cài GEMINI_API_KEY).";

    return AIAnalysisResult(
      diseaseName: "Bệnh Khảm Lá (Mosaic Virus)",
      severity: "Nghiêm trọng",
      matchPercentage: 96.4,
      aiInsight: _truncateText(insightText, 5000),
      expertAdvice: _truncateText(adviceText, 5000),
      actionPlan: [
        "Cách ly cây bệnh tức thì|Nhổ bỏ và tiêu hủy an toàn các cá thể nhiễm bệnh để ngăn virus lây lan sang các luống cây khỏe mạnh kế cận.",
        "Sử dụng thuốc diệt côn trùng|Áp dụng chế phẩm sinh học diệt rệp sáp và bọ phấn trắng (vector chính truyền bệnh) trên toàn bộ khu vực bị ảnh hưởng.",
        "Điều chỉnh chế độ dinh dưỡng|Tăng cường phân bón vi lượng (Kẽm, Magie) qua hệ thống tưới nhỏ giọt để tăng sức đề kháng tự nhiên cho cây."
      ],
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length > maxLength) {
      return "\${text.substring(0, maxLength - 3)}...";
    }
    return text;
  }
}
