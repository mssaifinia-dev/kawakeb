import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/numerology_data.dart';
import '../data/name_number_data.dart';
import '../data/birth_day_number_data.dart';
import '../data/past_life_data.dart';

class PastLifeScreen extends StatelessWidget {
  final LifePathNumber lifePath;
  final NameNumber nameNumber;
  final BirthDayNumberInfo? birthDay;

  const PastLifeScreen({
    super.key,
    required this.lifePath,
    required this.nameNumber,
    required this.birthDay,
  });

  @override
  Widget build(BuildContext context) {
    final report = buildPastLifeReport(lifePath: lifePath, nameNumber: nameNumber, birthDay: birthDay);

    return Scaffold(
      appBar: AppBar(title: const Text('ردپای زندگی گذشته')),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _section('زندگی احتمالی گذشته', report.persona, icon: Icons.auto_stories_outlined),
                  _section('نقش یا شخصیت در زندگی گذشته', report.chosenRole, icon: Icons.theater_comedy_outlined),
                  _section('درس ناتمام روح', report.soulLesson, icon: Icons.spa_outlined),
                  _listSection('الگوهای منتقل‌شده به زندگی فعلی', report.transferredPatterns, icon: Icons.sync_alt_outlined),
                  _section('روابط کارمایی', report.karmicRelationships, icon: Icons.favorite_border),
                  _listSection('استعدادهای به‌جامانده', report.leftoverTalents, icon: Icons.workspace_premium_outlined),
                  _section('گره یا بدهی کارمایی', report.karmicKnot, icon: Icons.link_outlined),
                  _section('پایان زندگی گذشته', report.symbolicEnding, icon: Icons.nightlight_round),
                  _section('ارتباط زندگی گذشته با زندگی فعلی', report.connectionToPresent,
                      icon: Icons.all_inclusive, highlight: true),
                  const SizedBox(height: 10),
                  _buildSoulMessage(report.soulMessage),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.auto_awesome, color: AppColors.purple, size: 48),
        const SizedBox(height: 12),
        Text('🔮 ردپای زندگی گذشته', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          'بر اساس الگوهای عددی کتاب سرنوشت تو...',
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'این یک خوانش نمادین است، نه ادعایی قطعی یا علمی درباره‌ی تناسخ.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _section(String title, String content, {required IconData icon, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: highlight ? AppColors.purple.withOpacity(0.1) : AppColors.glassFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: highlight ? AppColors.purple.withOpacity(0.5) : AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.gold, size: 18),
                const SizedBox(width: 8),
                Text(title, style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
              ],
            ),
            const SizedBox(height: 10),
            Text(content, style: AppTextStyles.bodyLarge.copyWith(height: 1.9)),
          ],
        ),
      ),
    );
  }

  Widget _listSection(String title, List<String> items, {required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.gold, size: 18),
                const SizedBox(width: 8),
                Text(title, style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.circle, size: 6, color: AppColors.gold),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item, style: AppTextStyles.bodyMedium)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSoulMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.gold.withOpacity(0.15), AppColors.purple.withOpacity(0.2)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGold),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('✨ پیام روح', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(height: 1.9, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
