import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../../../core/utils/persian_date_converter.dart';
import '../data/qamar_aqrab_data.dart';

class QamarAqrabScreen extends StatefulWidget {
  const QamarAqrabScreen({super.key});

  @override
  State<QamarAqrabScreen> createState() => _QamarAqrabScreenState();
}

class _QamarAqrabScreenState extends State<QamarAqrabScreen> {
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  String? _error;
  bool _checked = false;
  String _moonSign = '';
  bool _inScorpio = false;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  void _check() {
    final day = int.tryParse(_dayController.text.trim());
    final month = int.tryParse(_monthController.text.trim());
    final year = int.tryParse(_yearController.text.trim());

    if (!isValidJalaliDate(year, month, day)) {
      setState(() {
        _error = 'لطفاً تاریخ شمسی را درست وارد کن.';
        _checked = false;
      });
      return;
    }

    final g = jalaliToGregorian(year!, month!, day!);
    final date = DateTime(g.year, g.month, g.day);
    final sign = getMoonZodiacSign(date);
    final inScorpio = sign == 'عقرب';
    final range = inScorpio ? findScorpioTransitRange(date) : (null, null);

    setState(() {
      _error = null;
      _checked = true;
      _moonSign = sign;
      _inScorpio = inScorpio;
      _rangeStart = range.$1;
      _rangeEnd = range.$2;
    });
  }

  void _reset() {
    setState(() {
      _checked = false;
      _error = null;
    });
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قمر در عقرب')),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  if (!_checked) _buildInputForm() else _buildResult(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.nightlight_round, color: AppColors.gold, size: 64),
        const SizedBox(height: 20),
        Text('ماه در چه تاریخی کجاست؟', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(
          'تاریخ شمسی مدنظرت رو وارد کن (مثلاً امروز). در سنت‌های نجومی سنتی، دوره‌ی «قمر در عقرب» زمانی نامناسب برای تصمیم‌های مهم، ازدواج و شروع قراردادها دانسته می‌شود.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Text(
            'محاسبه‌ی این صفحه بر پایه‌ی فرمول تقریبی طول میانگین ماه است و ممکن است تا چند ساعت با محاسبات دقیق رصدخانه‌ای اختلاف داشته باشد.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _dayController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: 'روز'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _monthController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: 'ماه'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: 'سال (مثلاً ۱۴۰۳)'),
              ),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFFE05A5A))),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: _check, child: const Text('بررسی وضعیت ماه')),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final color = _inScorpio ? const Color(0xFFE05A5A) : const Color(0xFF3E9C6E);
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: color),
            ),
            child: Text(
              _inScorpio ? 'ماه در عقرب است' : 'ماه در عقرب نیست',
              style: AppTextStyles.cardLabel.copyWith(color: color),
            ),
          ),
          const SizedBox(height: 16),
          Text('برج فعلی ماه: $_moonSign', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.gold)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Text(
              _inScorpio
                  ? 'بر اساس محاسبه‌ی تقریبی، ماه از ${_formatDate(_rangeStart)} تا ${_formatDate(_rangeEnd)} (میلادی) در برج عقرب قرار دارد. سنتاً بهتر است تصمیم‌های مهم را به بعد از این بازه موکول کنی.'
                  : 'ماه در این تاریخ در برج عقرب نیست؛ از نظر این باور سنتی، زمان مناسبی برای تصمیم‌های مهم است.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.9),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: _reset, child: const Text('بررسی تاریخ دیگر')),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}/${date.month}/${date.day}';
  }
}
