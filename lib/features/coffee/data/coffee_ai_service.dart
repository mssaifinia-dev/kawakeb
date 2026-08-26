import '../../../core/services/supabase_config.dart';

class CoffeeAiResult {
  final String? symbolName;
  final String interpretation;

  const CoffeeAiResult({required this.symbolName, required this.interpretation});

  factory CoffeeAiResult.fromJson(Map<String, dynamic> json) {
    return CoffeeAiResult(
      symbolName: json['symbolName'] as String?,
      interpretation: (json['interpretation'] as String?) ?? '',
    );
  }
}

class CoffeeAiService {
  /// عکس فنجان رو (به‌صورت base64) می‌فرسته و تحلیل هوش مصنوعی رو برمی‌گردونه.
  static Future<CoffeeAiResult> analyzeImage(String imageBase64) async {
    final res = await supabase.functions.invoke(
      'coffee-analyze',
      body: {'imageBase64': imageBase64},
    );

    final data = res.data as Map<String, dynamic>?;
    if (res.status != 200 || data == null) {
      throw Exception((data?['error'] as String?) ?? 'خطا در تحلیل تصویر');
    }
    if (data['error'] != null) {
      throw Exception(data['error'] as String);
    }
    return CoffeeAiResult.fromJson(data);
  }
}
