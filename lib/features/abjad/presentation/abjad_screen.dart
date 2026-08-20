import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/abjad_data.dart';

class AbjadScreen extends StatefulWidget {
  const AbjadScreen({super.key});

  @override
  State<AbjadScreen> createState() => _AbjadScreenState();
}

class _AbjadScreenState extends State<AbjadScreen> {
  final TextEditingController _nameController = TextEditingController();
  AbjadResult? _result;
  String? _error;

  void _calculate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _error = 'لطفاً نام خودت یا فردی که مدنظرته را وارد کن.';
        _result = null;
      });
      return;
    }
    setState(() {
      _error = null;
      _result = calculateAbjadResult(name);
    });
  }

  void _reset() {
    setState(() {
      _result = null;
      _error = null;
      _nameController.clear();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اذکار و ابجد')),
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
                  if (_result == null) _buildInputForm() else _buildResult(_result!),
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
        const Icon(Icons.auto_stories_outlined, color: AppColors.gold, size: 64),
        const SizedBox(height: 20),
        Text('ذکر اختصاصی‌ات را بر اساس ابجد نامت پیدا کن', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text('نام خودت را به فارسی وارد کن', textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Text(
            'روش محاسبه: عدد ابجد نام با عدد ابجد ۹۹ اسم نیکوی خداوند مقایسه می‌شود و نزدیک‌ترین اسم به‌عنوان ذکر تو انتخاب می‌شود.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(hintText: 'مثلاً: مرتضی'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFFE05A5A))),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: _calculate, child: const Text('محاسبه‌ی ذکر')),
        ),
      ],
    );
  }

  Widget _buildResult(AbjadResult result) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold),
            ),
            child: Text('مجموع ابجد نام: ${result.totalValue}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gold)),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  result.matchedName.arabic,
                  style: AppTextStyles.headlineSmall.copyWith(color: AppColors.gold, fontSize: 26),
                ),
                const SizedBox(height: 8),
                Text('(${result.matchedName.meaning})', style: AppTextStyles.bodyLarge),
                const SizedBox(height: 6),
                Text('عدد ابجد این اسم: ${result.matchedName.abjadValue}', style: AppTextStyles.bodySmall),
                const SizedBox(height: 16),
                const Divider(color: AppColors.glassBorder),
                const SizedBox(height: 16),
                Text('تعداد پیشنهادی: ${result.recommendedCount} بار', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: _reset, child: const Text('محاسبه‌ی دوباره')),
        ],
      ),
    );
  }
}
