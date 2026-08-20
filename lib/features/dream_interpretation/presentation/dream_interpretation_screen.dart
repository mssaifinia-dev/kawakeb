import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/dream_interpretation_service.dart';

class DreamInterpretationScreen extends StatefulWidget {
  const DreamInterpretationScreen({super.key});

  @override
  State<DreamInterpretationScreen> createState() => _DreamInterpretationScreenState();
}

class _DreamInterpretationScreenState extends State<DreamInterpretationScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  DreamInterpretationResult? _result;

  // این لیست از dream_data.dart موجود پروژه می‌آید — همان دیتای قدیمی،
  // فقط اینجا به‌عنوان پیشنهاد سریع برای شروع نوشتن خواب استفاده می‌شود
  // (نه دیگر جستجوی مستقیم کلیدواژه).
  static const List<String> _popularKeywords = [
    'مار', 'آب', 'مرگ', 'پرواز', 'دندان',
    'عروسی', 'پول', 'گم شدن', 'حاملگی', 'آتش',
  ];

  void _insertKeyword(String keyword) {
    final current = _controller.text;
    _controller.text = current.isEmpty ? keyword : '$current $keyword';
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    setState(() {});
  }

  Future<void> _interpret() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await DreamInterpretationService.interpret(text);
      if (!mounted) return;
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'مشکلی پیش اومد، دوباره تلاش کن.';
        _isLoading = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _result = null;
      _errorMessage = null;
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعبیر خواب')),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  const Icon(Icons.nightlight_outlined, color: AppColors.gold, size: 56),
                  const SizedBox(height: 16),
                  if (_result == null) _buildInputStage() else _buildResultStage(_result!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputStage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('خوابت رو برام تعریف کن', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          'هرچقدر با جزئیات بیشتری بنویسی، تعبیر دقیق‌تری می‌گیری.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _controller,
          onChanged: (_) => setState(() {}),
          textAlign: TextAlign.right,
          maxLines: 6,
          minLines: 4,
          decoration: const InputDecoration(
            hintText: 'مثلاً: خواب دیدم در یک باغ بزرگ بودم، آب زلالی جاری بود و یک مار سفید از کنارم رد شد...',
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Text('برای شروع، یکی از این کلمه‌ها رو اضافه کن:', style: AppTextStyles.bodySmall),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _popularKeywords.map((keyword) {
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _insertKeyword(keyword),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(keyword, style: AppTextStyles.bodyMedium),
              ),
            );
          }).toList(),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(_errorMessage!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error), textAlign: TextAlign.center),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_controller.text.trim().isEmpty || _isLoading) ? null : _interpret,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnGold),
                  )
                : const Text('تعبیر کن'),
          ),
        ),
      ],
    );
  }

  Widget _buildResultStage(DreamInterpretationResult result) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (result.summary != null && result.summary!.isNotEmpty)
          _sectionCard('🌙 خلاصه‌ی خواب شما', result.summary!, highlight: true),
        if (result.symbols.isNotEmpty) _buildSymbolsSection(result.symbols),
        if (result.fullInterpretation.isNotEmpty)
          _sectionCard('🔮 تعبیر کامل', result.fullInterpretation),
        if (result.overallMessage != null && result.overallMessage!.isNotEmpty)
          _sectionCard('💫 پیام کلی خواب', result.overallMessage!),
        if (result.emotional != null && result.emotional!.isNotEmpty)
          _sectionCard('❤️ جنبه‌ی عاطفی', result.emotional!),
        if (result.financial != null && result.financial!.isNotEmpty)
          _sectionCard('💰 جنبه‌ی مالی', result.financial!),
        if (result.career != null && result.career!.isNotEmpty)
          _sectionCard('💼 جنبه‌ی کاری', result.career!),
        if (result.family != null && result.family!.isNotEmpty)
          _sectionCard('👨\u200d👩\u200d👧 جنبه‌ی خانوادگی', result.family!),
        if (result.warning != null && result.warning!.isNotEmpty)
          _sectionCard('⚠️ نکته‌ی احتمالی', result.warning!),
        const SizedBox(height: 10),
        OutlinedButton(onPressed: _reset, child: const Text('تعبیر خواب دیگر')),
      ],
    );
  }

  Widget _buildSymbolsSection(List<String> symbols) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('✨ نمادهای اصلی خواب', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: symbols.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderGold),
                  ),
                  child: Text(s, style: AppTextStyles.bodyMedium),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(String title, String content, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: highlight ? AppColors.gold.withOpacity(0.08) : AppColors.glassFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: highlight ? AppColors.borderGold : AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              content,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
