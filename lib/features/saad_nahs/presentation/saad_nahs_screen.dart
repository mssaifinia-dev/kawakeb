import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/saad_nahs_data.dart';

class SaadNahsScreen extends StatefulWidget {
  const SaadNahsScreen({super.key});

  @override
  State<SaadNahsScreen> createState() => _SaadNahsScreenState();
}

class _SaadNahsScreenState extends State<SaadNahsScreen> {
  final TextEditingController _dayController = TextEditingController();
  DayQualityInfo? _result;
  String? _error;

  void _check() {
    final day = int.tryParse(_dayController.text.trim());
    if (day == null || day < 1 || day > 30) {
      setState(() {
        _error = 'روز ماه شمسی را بین ۱ تا ۳۰ وارد کن.';
        _result = null;
      });
      return;
    }
    setState(() {
      _error = null;
      _result = saadNahsTable.firstWhere((e) => e.day == day);
    });
  }

  void _reset() {
    setState(() {
      _result = null;
      _error = null;
      _dayController.clear();
    });
  }

  Color _colorFor(DayQuality quality) {
    switch (quality) {
      case DayQuality.saad:
        return const Color(0xFF3E9C6E);
      case DayQuality.nahs:
        return const Color(0xFFE05A5A);
      case DayQuality.moderate:
        return AppColors.gold;
    }
  }

  @override
  void dispose() {
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سعد و نحس ایام')),
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
        const Icon(Icons.calendar_month_outlined, color: AppColors.gold, size: 64),
        const SizedBox(height: 20),
        Text('امروز چه روزی از ماه شمسیه؟', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text('عدد روز ماه (بین ۱ تا ۳۰) را وارد کن', textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 24),
        TextField(
          controller: _dayController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(hintText: 'مثلاً ۱۵'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFFE05A5A))),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: _check, child: const Text('بررسی وضعیت روز')),
        ),
      ],
    );
  }

  Widget _buildResult(DayQualityInfo info) {
    final color = _colorFor(info.quality);
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
            child: Text(info.quality.label, style: AppTextStyles.cardLabel.copyWith(color: color)),
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
            child: Text(info.note, textAlign: TextAlign.center, style: AppTextStyles.bodyLarge.copyWith(height: 1.9)),
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: _reset, child: const Text('بررسی روز دیگر')),
        ],
      ),
    );
  }
}
