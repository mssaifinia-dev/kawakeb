import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/jafr_data.dart';

class JafrScreen extends StatefulWidget {
  const JafrScreen({super.key});

  @override
  State<JafrScreen> createState() => _JafrScreenState();
}

class _JafrScreenState extends State<JafrScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  JafrReading? _result;
  String? _error;

  void _calculate() {
    final name = _nameController.text.trim();
    final motherName = _motherNameController.text.trim();

    if (name.isEmpty || motherName.isEmpty) {
      setState(() {
        _error = 'لطفاً نام خودت و نام مادرت را کامل وارد کن.';
        _result = null;
      });
      return;
    }

    setState(() {
      _error = null;
      _result = calculateJafrReading(name, motherName);
    });
  }

  void _reset() {
    setState(() {
      _result = null;
      _error = null;
      _nameController.clear();
      _motherNameController.clear();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _motherNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جفر')),
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
        const Icon(Icons.auto_fix_high_outlined, color: AppColors.gold, size: 64),
        const SizedBox(height: 20),
        Text('علم جفر', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(
          'یکی از قدیمی‌ترین علوم غریبه که با ترکیب حروف نام شخص و نام مادرش، از رازهای پنهان و آینده‌ی نزدیک خبر می‌دهد.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(hintText: 'نام خودت'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _motherNameController,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(hintText: 'نام مادرت'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: _calculate, child: const Text('محاسبه‌ی جفر')),
        ),
      ],
    );
  }

  Widget _buildResult(JafrReading result) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_fix_high, color: AppColors.gold, size: 40),
          const SizedBox(height: 16),
          Text(result.title, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.gold), textAlign: TextAlign.center),
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
              result.message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.9),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: _reset, child: const Text('محاسبه‌ی دوباره')),
        ],
      ),
    );
  }
}
