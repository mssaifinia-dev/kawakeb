import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../../../core/utils/persian_date_converter.dart';
import '../../../core/services/birthdate_service.dart';
import '../data/historical_persona_data.dart';

class HistoricalPersonaScreen extends StatefulWidget {
  const HistoricalPersonaScreen({super.key});

  @override
  State<HistoricalPersonaScreen> createState() => _HistoricalPersonaScreenState();
}

class _HistoricalPersonaScreenState extends State<HistoricalPersonaScreen> {
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  bool _loading = true;
  bool _showForm = false;
  HistoricalPersona? _result;
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
        _result = getHistoricalPersona(saved.$1, saved.$2, saved.$3);
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
      _result = getHistoricalPersona(gregorian.day, gregorian.month, gregorian.year);
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
      appBar: AppBar(title: const Text('همتای تاریخی')),
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
        const Icon(Icons.hourglass_empty, color: AppColors.gold, size: 64),
        const SizedBox(height: 20),
        Text('همتای تاریخی‌ات را پیدا کن', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(
          'در طول تاریخ، همیشه کسی شبیه به روحیه‌ی تو وجود داشته. با تاریخ تولدت، پیدا کن کدوم شخصیت نمادین بهت نزدیک‌تره.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),
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
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: () => _calculate(), child: const Text('پیدا کردن همتای تاریخی')),
        ),
      ],
    );
  }

  Widget _buildResult(HistoricalPersona persona) {
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
            child: const Icon(Icons.hourglass_bottom, color: AppColors.gold, size: 40),
          ),
          const SizedBox(height: 16),
          Text(persona.title, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.gold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(persona.era, style: AppTextStyles.bodySmall),
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
              persona.description,
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
