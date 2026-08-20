import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/sar_ketab_data.dart';

class SarKetabScreen extends StatefulWidget {
  const SarKetabScreen({super.key});

  @override
  State<SarKetabScreen> createState() => _SarKetabScreenState();
}

enum _SarKetabStage { niyyat, result }

class _SarKetabScreenState extends State<SarKetabScreen> {
  _SarKetabStage _stage = _SarKetabStage.niyyat;
  SarKetabResult? _result;
  final Random _random = Random();

  void _openBook() {
    setState(() {
      _result = sarKetabResults[_random.nextInt(sarKetabResults.length)];
      _stage = _SarKetabStage.result;
    });
  }

  void _reset() {
    setState(() {
      _stage = _SarKetabStage.niyyat;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سرکتاب')),
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
                  if (_stage == _SarKetabStage.niyyat) _buildNiyyat() else _buildResult(_result!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNiyyat() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.menu_book_outlined, color: AppColors.gold, size: 60),
        const SizedBox(height: 20),
        Text('سرکتاب باز می‌کنیم', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(
          'طبق رسم قدیم، پیش از باز کردن قرآن، با نام خدا شروع کن و نیتت را در دل مرور کن.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGold),
          ),
          child: Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gold, fontSize: 22, height: 2),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'حالا با نیت خودت، آرام قرآن را باز کن.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 28),
        ElevatedButton(onPressed: _openBook, child: const Text('باز کردن قرآن')),
      ],
    );
  }

  Widget _buildResult(SarKetabResult result) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_stories, color: AppColors.gold, size: 32),
          const SizedBox(height: 10),
          Text('قرآن بر این آیه گشوده شد', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  result.verse,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gold, height: 2, fontSize: 20),
                ),
                const SizedBox(height: 20),
                const Divider(color: AppColors.glassBorder),
                const SizedBox(height: 15),
                Text(result.translation, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('دلالت سرکتاب', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Text(
              result.guidance,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: _reset, child: const Text('دوباره سرکتاب باز کن')),
        ],
      ),
    );
  }
}
