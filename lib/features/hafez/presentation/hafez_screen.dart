import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/hafez_data.dart';

class HafezScreen extends StatefulWidget {
  const HafezScreen({super.key});

  @override
  State<HafezScreen> createState() => _HafezScreenState();
}

class _HafezScreenState extends State<HafezScreen> {
  HafezGhazal? _result;
  final _random = Random();

  void _getFal() {
    setState(() {
      _result = hafezDivan[_random.nextInt(hafezDivan.length)];
    });
  }

  void _reset() {
    setState(() => _result = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فال حافظ')),
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
        const Icon(Icons.menu_book_outlined, color: AppColors.gold, size: 64),
        const SizedBox(height: 20),
        Text('با نیت خود، دیوان حافظ را بگشا', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(
          'چند لحظه چشمانت را ببند، آرزویت را در دل مرور کن و سپس دکمه را لمس کن.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: _getFal, child: const Text('گرفتن فال')),
      ],
    );
  }

  Widget _buildResult(HafezGhazal ghazal) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.format_quote, color: AppColors.gold, size: 32),
          const SizedBox(height: 12),
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
              children: ghazal.verses.map((verse) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    verse,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(height: 1.9),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Text('تفسیر فال', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
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
              ghazal.interpretation,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: _reset, child: const Text('فال دیگر')),
        ],
      ),
    );
  }
}
