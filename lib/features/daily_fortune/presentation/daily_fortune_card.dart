import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/birthdate_service.dart';
import '../../../core/utils/persian_date_converter.dart';
import '../../zodiac/data/zodiac_data.dart';
import '../data/daily_messages_data.dart';

class DailyFortuneCard extends StatefulWidget {
  const DailyFortuneCard({super.key});

  @override
  State<DailyFortuneCard> createState() => _DailyFortuneCardState();
}

class _DailyFortuneCardState extends State<DailyFortuneCard> {
  bool _loading = true;
  (int, int, int)? _birthdate; // stored as Gregorian (day, month, year)

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await BirthdateService.getBirthdate();
    if (!mounted) return;
    setState(() {
      _birthdate = saved;
      _loading = false;
    });
  }

  Future<void> _openBirthdateForm() async {
    final result = await showModalBottomSheet<(int, int, int)>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _BirthdateBottomSheet(),
    );

    if (result != null) {
      // result اینجا از قبل به میلادی تبدیل شده
      await BirthdateService.saveBirthdate(
        day: result.$1,
        month: result.$2,
        year: result.$3,
      );
      if (!mounted) return;
      setState(() => _birthdate = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(height: 80);
    }

    if (_birthdate == null) {
      return _buildPrompt();
    }

    final sign = getZodiacSign(_birthdate!.$2, _birthdate!.$1);
    final message = getDailyMessage(sign.name, DateTime.now());

    return _buildDailyMessage(sign, message);
  }

  Widget _buildPrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.gold, size: 22),
          const SizedBox(height: 10),
          Text('فال روز شخصی', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
          const SizedBox(height: 8),
          Text(
            'تاریخ تولدت را وارد کن تا هر روز فال شخصی‌ات را ببینی',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _openBirthdateForm,
              child: const Text('تنظیم تاریخ تولد'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMessage(ZodiacSign sign, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(sign.symbol, style: const TextStyle(fontSize: 18, color: AppColors.gold)),
              const SizedBox(width: 6),
              Text('فال روز ${sign.name}', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
              const Spacer(),
              InkWell(
                onTap: _openBirthdateForm,
                child: Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary.withOpacity(0.7)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(height: 1.8),
          ),
        ],
      ),
    );
  }
}

class _BirthdateBottomSheet extends StatefulWidget {
  const _BirthdateBottomSheet();

  @override
  State<_BirthdateBottomSheet> createState() => _BirthdateBottomSheetState();
}

class _BirthdateBottomSheetState extends State<_BirthdateBottomSheet> {
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  String? _error;

  void _submit() {
    final day = int.tryParse(_dayController.text.trim());
    final month = int.tryParse(_monthController.text.trim());
    final year = int.tryParse(_yearController.text.trim());

    if (!isValidJalaliDate(year, month, day)) {
      setState(() => _error = 'لطفاً تاریخ تولد شمسی را کامل و درست وارد کن.');
      return;
    }

    final gregorian = jalaliToGregorian(year!, month!, day!);
    Navigator.of(context).pop((gregorian.day, gregorian.month, gregorian.year));
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
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('تاریخ تولدت رو وارد کن', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 6),
          Text('به تقویم شمسی، برای محاسبه‌ی برج فلکی', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 20),
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
            const SizedBox(height: 10),
            Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFFE05A5A))),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _submit, child: const Text('ثبت و نمایش فال روز')),
          ),
        ],
      ),
    );
  }
}
