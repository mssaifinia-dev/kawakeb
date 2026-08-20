import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/angel_data.dart';

class AngelFortuneScreen extends StatefulWidget {
  const AngelFortuneScreen({super.key});

  @override
  State<AngelFortuneScreen> createState() => _AngelFortuneScreenState();
}

class _AngelFortuneScreenState extends State<AngelFortuneScreen> {
  AngelNumber? _result;
  final Random _random = Random();

  void _getFortune() {
    setState(() {
      _result = angelNumbers[_random.nextInt(angelNumbers.length)];
    });
  }

  void _reset() {
    setState(() => _result = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فال فرشتگان')),
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
        const Icon(Icons.auto_awesome_outlined, color: AppColors.gold, size: 64),
        const SizedBox(height: 20),
        Text('سوالت را در دل بپرس', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text('فرشتگان از طریق اعداد با تو صحبت می‌کنند. دکمه را لمس کن.', textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: _getFortune, child: const Text('دریافت پیام فرشتگان')),
      ],
    );
  }

  Widget _buildResult(AngelNumber angel) {
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
              border: Border.all(color: AppColors.gold, width: 2),
            ),
            child: Center(
              child: Text(angel.number, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.gold)),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Text(angel.meaning, textAlign: TextAlign.center, style: AppTextStyles.bodyLarge.copyWith(height: 1.9)),
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: _reset, child: const Text('پیام دیگر')),
        ],
      ),
    );
  }
}
