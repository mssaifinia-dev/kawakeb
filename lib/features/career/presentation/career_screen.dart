import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/career_data.dart';

class CareerFortuneScreen extends StatefulWidget {
  const CareerFortuneScreen({super.key});

  @override
  State<CareerFortuneScreen> createState() => _CareerFortuneScreenState();
}

class _CareerFortuneScreenState extends State<CareerFortuneScreen> {
  CareerFortune? _result;
  final Random _random = Random();

  void _getFortune() {
    setState(() {
      _result = careerFortunes[_random.nextInt(careerFortunes.length)];
    });
  }

  void _reset() {
    setState(() => _result = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فال شغلی')),
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
        const Icon(Icons.work_outline, color: Color(0xFF3E6FE0), size: 64),
        const SizedBox(height: 20),
        Text('به مسیر شغلی‌ات فکر کن', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text('چند لحظه آرام باش و سپس دکمه را لمس کن.', textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: _getFortune, child: const Text('گرفتن فال شغلی')),
      ],
    );
  }

  Widget _buildResult(CareerFortune fortune) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.work, color: Color(0xFF3E6FE0), size: 32),
          const SizedBox(height: 16),
          Text(fortune.title, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.gold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Text(fortune.message, textAlign: TextAlign.center, style: AppTextStyles.bodyLarge.copyWith(height: 1.9)),
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: _reset, child: const Text('فال دیگر')),
        ],
      ),
    );
  }
}
