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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: _result == null
                  ? _buildInputForm()
                  : _buildResult(_result!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Icon(
          Icons.auto_fix_high_outlined,
          color: AppColors.gold,
          size: 68,
        ),
        const SizedBox(height: 18),
        Text(
          'علم جفر',
          style: AppTextStyles.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'در این خوانش، نام شخص و نام مادر به‌صورت نمادین در یک محاسبه عددی ترکیب می‌شوند تا یک خوانش چندبخشی از ویژگی‌ها، روابط، کار، امور مالی و مسیر پیش‌رو ارائه شود.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 26),
        _inputField(
          controller: _nameController,
          hint: 'نام خودت',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 14),
        _inputField(
          controller: _motherNameController,
          hint: 'نام مادرت',
          icon: Icons.favorite_border,
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
        const SizedBox(height: 26),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('شروع خوانش جفر'),
          ),
        ),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.gold),
      ),
    );
  }

  Widget _buildResult(JafrReading result) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Icon(
          Icons.auto_fix_high,
          color: AppColors.gold,
          size: 42,
        ),
        const SizedBox(height: 12),
        Text(
          result.title,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.gold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),

        _numberCard(result),

        const SizedBox(height: 16),

        _readingSection(
          icon: Icons.bolt_outlined,
          title: 'انرژی غالب',
          text: result.dominantEnergy,
        ),

        _readingSection(
          icon: Icons.person_outline,
          title: 'خوانش شخصیت',
          text: result.personality,
        ),

        _readingSection(
          icon: Icons.favorite_outline,
          title: 'عشق و روابط',
          text: result.love,
        ),

        _readingSection(
          icon: Icons.account_balance_wallet_outlined,
          title: 'مال و روزی',
          text: result.finance,
        ),

        _readingSection(
          icon: Icons.work_outline,
          title: 'کار و مسیر شغلی',
          text: result.career,
        ),

        _readingSection(
          icon: Icons.warning_amber_outlined,
          title: 'موانع و هشدار',
          text: result.obstacles,
        ),

        _readingSection(
          icon: Icons.auto_awesome_outlined,
          title: 'فرصت‌های پیش‌رو',
          text: result.opportunities,
        ),

        _readingSection(
          icon: Icons.nightlight_outlined,
          title: 'پیام معنوی',
          text: result.spiritual,
        ),

        _readingSection(
          icon: Icons.schedule_outlined,
          title: 'زمان و روند پیش‌رو',
          text: result.timing,
        ),

        const SizedBox(height: 6),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gold.withOpacity(0.16),
                AppColors.glassFill,
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.gold.withOpacity(0.45),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppColors.gold,
                size: 26,
              ),
              const SizedBox(height: 10),
              Text(
                'پیام نهایی جفر',
                style: AppTextStyles.cardLabel.copyWith(
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                result.finalMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  height: 1.9,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: const Text('خوانش دوباره'),
          ),
        ),
      ],
    );
  }

  Widget _numberCard(JafrReading result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderGold,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _numberItem(
              'ابجد نام',
              '${result.nameValue}',
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _numberItem(
              'ابجد مادر',
              '${result.motherValue}',
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _numberItem(
              'عدد جفر',
              '${result.combinedValue}',
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _numberItem(
              'عدد پایه',
              '${result.rootNumber}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 42,
      color: AppColors.glassBorder,
    );
  }

  Widget _readingSection({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.glassBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.gold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.cardLabel.copyWith(
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.9,
            ),
          ),
        ],
      ),
    );
  }
}