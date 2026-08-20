import '../../../core/services/supabase_config.dart';

/// نتیجه‌ی تعبیر خواب هوشمند (متن آزاد → تحلیل ساختاریافته).
class DreamInterpretationResult {
  final String? summary;
  final List<String> symbols;
  final String fullInterpretation;
  final String? overallMessage;
  final String? emotional;
  final String? financial;
  final String? career;
  final String? family;
  final String? warning;

  const DreamInterpretationResult({
    required this.summary,
    required this.symbols,
    required this.fullInterpretation,
    required this.overallMessage,
    required this.emotional,
    required this.financial,
    required this.career,
    required this.family,
    required this.warning,
  });

  factory DreamInterpretationResult.fromJson(Map<String, dynamic> json) {
    return DreamInterpretationResult(
      summary: json['summary'] as String?,
      symbols: (json['symbols'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      fullInterpretation: (json['fullInterpretation'] as String?) ?? '',
      overallMessage: json['overallMessage'] as String?,
      emotional: json['emotional'] as String?,
      financial: json['financial'] as String?,
      career: json['career'] as String?,
      family: json['family'] as String?,
      warning: json['warning'] as String?,
    );
  }
}

class DreamInterpretationService {
  /// خواب آزاد کاربر را می‌فرستد و تعبیر ساختاریافته برمی‌گرداند.
  /// [source] فعلاً فقط 'traditional-fa' پشتیبانی می‌شود؛ معماری برای
  /// افزودن منابع دیگر (اسلامی، روان‌شناختی) در آینده آماده است.
  static Future<DreamInterpretationResult> interpret(
    String dreamText, {
    String source = 'traditional-fa',
  }) async {
    final res = await supabase.functions.invoke(
      'dream-interpret',
      body: {'dreamText': dreamText, 'source': source},
    );

    final data = res.data as Map<String, dynamic>?;
    if (res.status != 200 || data == null) {
      throw Exception((data?['error'] as String?) ?? 'خطا در دریافت تعبیر خواب');
    }
    if (data['error'] != null) {
      throw Exception(data['error'] as String);
    }

    return DreamInterpretationResult.fromJson(data);
  }
}
