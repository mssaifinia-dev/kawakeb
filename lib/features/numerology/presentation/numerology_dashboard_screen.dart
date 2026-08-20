import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../../../core/services/birthdate_service.dart';
import '../../../core/services/name_service.dart';
import '../../../core/services/family_members_service.dart';
import '../data/numerology_data.dart';
import '../data/name_number_data.dart';
import '../data/daily_sentences_data.dart';
import '../data/nine_year_cycles_data.dart';
import '../data/birth_day_number_data.dart';
import 'numerology_screen.dart';
import 'family_relationships_screen.dart';
import 'past_life_screen.dart';

class NumerologyDashboardScreen extends StatefulWidget {
  const NumerologyDashboardScreen({super.key});

  @override
  State<NumerologyDashboardScreen> createState() => _NumerologyDashboardScreenState();
}

class _NumerologyDashboardScreenState extends State<NumerologyDashboardScreen> {
  bool _loading = true;
  LifePathNumber? _lifePath;
  NameNumber? _nameNumber;
  BirthDayNumberInfo? _birthDayNumber;
  NineYearCycle? _currentCycle;
  String? _todaySentence;
  int _relationshipsCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final birth = await BirthdateService.getBirthdate();
    final name = await NameService.getFullName();
    final members = await FamilyMembersService.getMembers();

    LifePathNumber? lifePath;
    NineYearCycle? currentCycle;
    String? sentence;
    BirthDayNumberInfo? birthDayNumber;

    if (birth != null) {
      final sum = '${birth.$1}${birth.$2}${birth.$3}'.split('').map(int.parse).reduce((a, b) => a + b);
      lifePath = lifePathNumbers[reduceWithMasterNumbers(sum)];
      birthDayNumber = calculateBirthDayNumber(birth.$1);

      final age = DateTime.now().year - birth.$3;
      final cycles = buildNineYearCycles();
      for (final c in cycles) {
        if (age >= c.startAge && age < c.endAge) {
          currentCycle = c;
          break;
        }
      }

      if (lifePath != null) {
        final sentences = getDailySentences(lifePath.number, DateTime.now(), count: 1);
        sentence = sentences.isNotEmpty ? sentences.first : null;
      }
    }

    NameNumber? nameNumber;
    if (name != null && name.trim().isNotEmpty) {
      // نیاز به ابجد است؛ برای جلوگیری از وابستگی چرخه‌ای، مستقیم محاسبه می‌کنیم
      nameNumber = nameNumbers[calculateNameNumber(name)];
    }

    if (!mounted) return;
    setState(() {
      _lifePath = lifePath;
      _nameNumber = nameNumber;
      _birthDayNumber = birthDayNumber;
      _currentCycle = currentCycle;
      _todaySentence = sentence;
      _relationshipsCount = members.length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('داشبورد کتاب سرنوشت')),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : _lifePath == null
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildNumbersRow(),
                            const SizedBox(height: 16),
                            _buildTodayCard(),
                            const SizedBox(height: 16),
                            _buildCycleCard(),
                            const SizedBox(height: 16),
                            _buildRelationshipsCard(),
                            if (_nameNumber != null) ...[
                              const SizedBox(height: 16),
                              _buildPastLifeCard(),
                            ],
                            const SizedBox(height: 16),
                            _buildFullReportButton(),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_stories_outlined, color: AppColors.gold, size: 56),
            const SizedBox(height: 16),
            Text('هنوز کتاب سرنوشتت باز نشده', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NumerologyScreen()));
              },
              child: const Text('باز کردن کتاب سرنوشت'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumbersRow() {
    return Row(
      children: [
        Expanded(child: _numberCard('عدد مسیر زندگی', _lifePath!.number, _lifePath!.title)),
        if (_nameNumber != null) ...[
          const SizedBox(width: 12),
          Expanded(child: _numberCard('عدد اسم', _nameNumber!.number, _nameNumber!.title)),
        ],
      ],
    );
  }

  Widget _numberCard(String label, int number, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('$number', style: AppTextStyles.displayMedium.copyWith(color: AppColors.gold)),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.bodySmall, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTodayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.gold.withOpacity(0.12), AppColors.purple.withOpacity(0.12)]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGold),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.gold, size: 16),
              const SizedBox(width: 6),
              Text('جمله‌ی امروز تو', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _todaySentence ?? '—',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(height: 1.8),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleCard() {
    if (_currentCycle == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.repeat_outlined, color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('چرخه‌ی فعلی: ${_currentCycle!.startAge} تا ${_currentCycle!.endAge} سالگی', style: AppTextStyles.cardLabel),
                Text(_currentCycle!.title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipsCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FamilyRelationshipsScreen()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: AppColors.purple.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.groups_outlined, color: AppColors.purple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('روابط ثبت‌شده', style: AppTextStyles.cardLabel),
                  Text(
                    _relationshipsCount == 0 ? 'هنوز کسی اضافه نکردی' : '$_relationshipsCount نفر اضافه شده',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.gold),
          ],
        ),
      ),
    );
  }

  Widget _buildPastLifeCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PastLifeScreen(
              lifePath: _lifePath!,
              nameNumber: _nameNumber!,
              birthDay: _birthDayNumber,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.purple.withOpacity(0.18), AppColors.gold.withOpacity(0.08)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.purple.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: AppColors.purple.withOpacity(0.25), shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, color: AppColors.purple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🔮 ردپای زندگی گذشته', style: AppTextStyles.cardLabel),
                  Text('یک خوانش نمادین بر اساس اعدادت', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.gold),
          ],
        ),
      ),
    );
  }

  Widget _buildFullReportButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NumerologyScreen()));
        },
        child: const Text('مشاهده‌ی گزارش کامل'),
      ),
    );
  }
}
