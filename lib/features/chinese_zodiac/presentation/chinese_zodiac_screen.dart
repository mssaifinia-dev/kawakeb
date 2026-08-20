import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../../../core/utils/persian_date_converter.dart';
import '../../../core/services/birthdate_service.dart';
import '../data/chinese_zodiac_data.dart';

class ChineseZodiacScreen extends StatefulWidget {
  const ChineseZodiacScreen({super.key});

  @override
  State<ChineseZodiacScreen> createState() => _ChineseZodiacScreenState();
}

class _ChineseZodiacScreenState extends State<ChineseZodiacScreen> {
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  bool _loading = true;
  bool _showForm = false;
  ChineseZodiacSign? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final saved = await BirthdateService.getBirthdate();
    if (!mounted) return;
    if (saved != null) {
      setState(() {
        _result = getChineseZodiac(saved.$3); // year
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        _showForm = true;
      });
    }
  }

  Future<void> _calculate() async {
    final day = int.tryParse(_dayController.text.trim());
    final month = int.tryParse(_monthController.text.trim());
    final year = int.tryParse(_yearController.text.trim());

    if (!isValidJalaliDate(year, month, day)) {
      setState(() {
        _error = 'لطفاً تاریخ تولد شمسی را درست وارد کن.';
        _result = null;
      });
      return;
    }

    final gregorian = jalaliToGregorian(year!, month!, day!);
    await BirthdateService.saveBirthdate(day: gregorian.day, month: gregorian.month, year: gregorian.year);

    setState(() {
      _error = null;
      _showForm = false;
      _result = getChineseZodiac(gregorian.year);
    });
  }

  void _changeBirthdate() {
    setState(() {
      _showForm = true;
      _result = null;
    });
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طالع‌بینی چینی')),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        if (_showForm || _result == null) _buildInputForm() else _buildResult(_result!),
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
        const Icon(Icons.pets_outlined, color: AppColors.gold, size: 64),
        const SizedBox(height: 20),
        Text('حیوان سال تولدت رو پیدا کن', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text('تاریخ تولدت را به تقویم شمسی وارد کن', textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _dayController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: 'روز'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _monthController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: 'ماه'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: 'سال (مثلاً ۱۳۷۵)'),
              ),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: () => _calculate(), child: const Text('نمایش حیوان سالم')),
        ),
      ],
    );
  }

  Widget _buildResult(ChineseZodiacSign sign) {
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
            child: Center(child: Text(sign.emoji, style: const TextStyle(fontSize: 40))),
          ),
          const SizedBox(height: 16),
          Text('سال ${sign.name}', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.gold)),
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
              sign.traits,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.9),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(onPressed: _changeBirthdate, child: const Text('تغییر تاریخ تولد')),
        ],
      ),
    );
  }
}
