import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/candle_data.dart';

class CandleFortuneScreen extends StatefulWidget {
  const CandleFortuneScreen({super.key});

  @override
  State<CandleFortuneScreen> createState() => _CandleFortuneScreenState();
}

class _CandleFortuneScreenState extends State<CandleFortuneScreen> {
  CandleSign? _result;
  final Random _random = Random();

  void _getFortune() {
    setState(() {
      _result = candleSigns[_random.nextInt(candleSigns.length)];
    });
  }

  void _reset() {
    setState(() => _result = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فال شمع')),
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
        const Icon(Icons.local_fire_department_outlined, color: Color(0xFFE0A63E), size: 64),
        const SizedBox(height: 20),
        Text('شمعی روشن کن و به شعله‌اش نگاه کن', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(
          'با آرامش، نیت خود را مرور کن و سپس دکمه را لمس کن.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: _getFortune, child: const Text('روشن کردن شمع')),
      ],
    );
  }

  Widget _buildResult(CandleSign sign) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Color(0xFFE0A63E), size: 40),
          const SizedBox(height: 16),
          Text(
            sign.title,
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.gold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Text(
              sign.interpretation,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.9),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: _reset, child: const Text('بار دیگر')),
        ],
      ),
    );
  }
}
