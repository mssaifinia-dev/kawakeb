import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/gypsy_data.dart';

class GypsyFortuneScreen extends StatefulWidget {
  const GypsyFortuneScreen({super.key});

  @override
  State<GypsyFortuneScreen> createState() => _GypsyFortuneScreenState();
}

class _GypsyFortuneScreenState extends State<GypsyFortuneScreen> {
  GypsyCard? _result;
  final Random _random = Random();

  void _getFortune() {
    setState(() {
      _result = gypsyCards[_random.nextInt(gypsyCards.length)];
    });
  }

  void _reset() {
    setState(() => _result = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فال کولی')),
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
                  if (_result == null) _buildIntro() else _buildResult(_result!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.style_outlined, color: AppColors.gold, size: 64),
        const SizedBox(height: 20),
        Text('یک کارت از دسته‌ی کولی بکش', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text('نیتت را در دل مرور کن و سپس دکمه را لمس کن.', textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: _getFortune, child: const Text('کشیدن کارت')),
      ],
    );
  }

  Widget _buildResult(GypsyCard card) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold),
            ),
            child: Icon(card.icon, color: AppColors.gold, size: 40),
          ),
          const SizedBox(height: 16),
          Text('کارت «${card.name}»', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.gold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Text(card.interpretation, textAlign: TextAlign.center, style: AppTextStyles.bodyLarge.copyWith(height: 1.9)),
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: _reset, child: const Text('کارت دیگر')),
        ],
      ),
    );
  }
}
