import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:developer' as developer;

class MultiLangString {
  final String vi;
  final String ja;

  MultiLangString({required this.vi, required this.ja});

  factory MultiLangString.fromJson(dynamic json) {
    if (json == null) return MultiLangString(vi: '', ja: '');
    if (json is String) return MultiLangString(vi: json, ja: json);
    if (json is Map<String, dynamic>) {
      return MultiLangString(vi: json['vi'] ?? '', ja: json['ja'] ?? '');
    }
    return MultiLangString(vi: '', ja: '');
  }

  String get(String lang) => lang == 'ja' ? ja : vi;
}

class MultiLangList {
  final List<String> vi;
  final List<String> ja;

  MultiLangList({required this.vi, required this.ja});

  factory MultiLangList.fromJson(dynamic json) {
    if (json == null) return MultiLangList(vi: [], ja: []);
    if (json is List) {
      final list = json.map((e) => e.toString()).toList();
      return MultiLangList(vi: list, ja: list);
    }
    if (json is Map<String, dynamic>) {
      return MultiLangList(
        vi: List<String>.from(json['vi'] ?? []),
        ja: List<String>.from(json['ja'] ?? []),
      );
    }
    return MultiLangList(vi: [], ja: []);
  }

  List<String> get(String lang) => lang == 'ja' ? ja : vi;
}

class AIAnalysisResult {
  final MultiLangString diseaseName;
  final MultiLangString severity;
  final double matchPercentage;
  final MultiLangString aiInsight;
  final MultiLangString expertAdvice;
  final MultiLangList actionPlan;

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
    final apiKey = dotenv.env['GEMINI_API_KEY']?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      // Nếu chưa có API key thì dùng dữ liệu mẫu (Mock)
      return _getMockResult();
    }

    try {
      // Khởi tạo model Gemini (khuyến nghị dùng gemini-1.5-flash cho nhận diện ảnh)
      final model = GenerativeModel(model: 'gemini-3.5-flash', apiKey: apiKey);

      // Đọc file ảnh dưới dạng bytes
      final imageBytes = await image.readAsBytes();

      // Khai báo prompt yêu cầu AI trả về chuẩn cấu trúc JSON
      final prompt = TextPart('''
Bạn là một chuyên gia nông nghiệp AI. Hãy phân tích hình ảnh cây trồng này để chẩn đoán bệnh.
Hãy trả về ĐÚNG định dạng JSON như sau, không kèm bất kỳ format markdown (```json) nào khác. Kết quả phải có hai ngôn ngữ vi (Tiếng Việt) và ja (Tiếng Nhật):
{
  "diseaseName": {"vi": "Tên bệnh (ví dụ: Bệnh Khảm Lá (Mosaic Virus))", "ja": "モザイク病"},
  "severity": {"vi": "Nghiêm trọng / Trung bình / Nhẹ", "ja": "重度 / 中度 / 軽度"},
  "matchPercentage": 96.4,
  "aiInsight": {"vi": "Mô tả chi tiết...", "ja": "詳細な説明..."},
  "expertAdvice": {"vi": "Lời khuyên...", "ja": "専門家のアドバイス..."},
  "actionPlan": {
    "vi": ["Hành động 1|Mô tả chi tiết hành động 1", "Hành động 2|Mô tả chi tiết hành động 2"],
    "ja": ["アクション1|アクション1の詳細", "アクション2|アクション2の詳細"]
  }
}
''');

      // Tạo DataPart chứa ảnh
      final imagePart = DataPart('image/jpeg', imageBytes);

      // Gọi API Gemini
      final response = await model.generateContent([
        Content.multi([prompt, imagePart]),
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
          diseaseName: MultiLangString.fromJson(data['diseaseName']),
          severity: MultiLangString.fromJson(data['severity']),
          matchPercentage: (data['matchPercentage'] as num?)?.toDouble() ?? 0.0,
          aiInsight: MultiLangString.fromJson(data['aiInsight']),
          expertAdvice: MultiLangString.fromJson(data['expertAdvice']),
          actionPlan: MultiLangList.fromJson(data['actionPlan']),
        );
      } else {
        throw Exception("AI không trả về kết quả.");
      }
    } catch (e) {
      developer.log('AI Error: $e');
      throw Exception("Lỗi khi kết nối với AI: $e");
    }
  }

  // Dữ liệu mô phỏng trong trường hợp chưa có API Key
  AIAnalysisResult _getMockResult() {
    String insightText =
        "Hệ thống thị giác máy tính đã phát hiện các mảng màu vàng không đều và biến dạng hình thái trên bề mặt lá. Sự đổi màu này làm suy giảm đáng kể lượng diệp lục, dẫn đến ức chế khả năng quang hợp và có nguy cơ làm giảm năng suất cây trồng diện rộng.";

    String adviceText =
        "Virus khảm không có thuốc đặc trị. Biện pháp tốt nhất là phòng ngừa. Khử trùng nghiêm ngặt toàn bộ nông cụ cắt tỉa bằng dung dịch natri hypochlorite 10% để cắt đứt nguồn lây lan cơ học. (LƯU Ý: Đây là dữ liệu mẫu vì bạn chưa cài GEMINI_API_KEY).";

    return AIAnalysisResult(
      diseaseName: MultiLangString(vi: "Bệnh Khảm Lá (Mosaic Virus)", ja: "モザイク病"),
      severity: MultiLangString(vi: "Nghiêm trọng", ja: "重度"),
      matchPercentage: 96.4,
      aiInsight: MultiLangString(vi: insightText, ja: "コンピュータビジョンシステムは、葉の表面に不規則な黄色い斑点と形態学的変形を検出しました。"),
      expertAdvice: MultiLangString(vi: adviceText, ja: "モザイクウイルスには特効薬がありません。予防が最善の策です。"),
      actionPlan: MultiLangList(
        vi: [
          "Cách ly cây bệnh tức thì|Nhổ bỏ và tiêu hủy an toàn các cá thể nhiễm bệnh để ngăn virus lây lan sang các luống cây khỏe mạnh kế cận.",
          "Sử dụng thuốc diệt côn trùng|Áp dụng chế phẩm sinh học diệt rệp sáp và bọ phấn trắng (vector chính truyền bệnh) trên toàn bộ khu vực bị ảnh hưởng."
        ],
        ja: [
          "直ちに隔離する|健康な植物への感染を防ぐため、感染した個体を安全に処分してください。",
          "殺虫剤を使用する|感染した領域全体にコナジラミ（主要な媒介昆虫）を殺すための生物学的製剤を適用してください。"
        ]
      ),
    );
  }

}
