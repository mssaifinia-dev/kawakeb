import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/love_data.dart';

class LoveFortuneScreen extends StatefulWidget {
  const LoveFortuneScreen({super.key});

  @override
  State<LoveFortuneScreen> createState() => _LoveFortuneScreenState();
}

class _LoveFortuneScreenState extends State<LoveFortuneScreen> {
  LoveFortune? _result;
  final Random _random = Random();

  void _getFortune() {
    setState(() {
      _result = loveFortunes[_random.nextInt(loveFortunes.length)];
    });
  }

  void _reset() {
    setState(() => _result = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فال عشق')),
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
        const Icon(Icons.favorite_outline, color: Color(0xFFE0507A), size: 64),
        const SizedBox(height: 20),
        Text('نام کسی که به او فکر می‌کنی را در دل بیاور', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(
          'چند لحظه آرام باش و سپس دکمه را لمس کن.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: _getFortune, child: const Text('گرفتن فال عشق')),
      ],
    );
  }

  Widget _buildResult(LoveFortune fortune) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, color: Color(0xFFE0507A), size: 32),
          const SizedBox(height: 16),
          Text(
            fortune.title,
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
              fortune.message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.9),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: _reset, child: const Text('فال دیگر')),
        ],
      ),
    );
  }
}
