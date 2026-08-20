import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../../../core/utils/persian_date_converter.dart';
import '../../../core/services/birthdate_service.dart';
import '../../../core/services/name_service.dart';
import '../data/numerology_data.dart';
import '../data/name_number_data.dart';
import '../data/birth_day_number_data.dart';
import '../data/soul_mission_data.dart';
import '../data/daily_sentences_data.dart';
import '../data/life_cycles_data.dart';
import '../data/nine_year_cycles_data.dart';

class NumerologyScreen extends StatefulWidget {
  const NumerologyScreen({super.key});

  @override
  State<NumerologyScreen> createState() => _NumerologyScreenState();
}

class _NumerologyScreenState extends State<NumerologyScreen> {
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _loading = true;
  bool _showBirthForm = false;
  bool _showNameForm = false;

  LifePathNumber? _lifePathResult;
  NameNumber? _nameResult;
  BirthDayNumberInfo? _birthDayResult;
  int? _birthRawDay;
  int? _birthRawMonth;
  int? _birthRawYear;
  String? _birthError;
  String? _nameError;

  LifePathNumber? _computeLifePathFromGregorian(int day, int month, int year) {
    final allDigitsSum = '$day$month$year'.split('').map(int.parse).reduce((a, b) => a + b);
    final lifePath = reduceWithMasterNumbers(allDigitsSum);
    return lifePathNumbers[lifePath];
  }

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final savedBirth = await BirthdateService.getBirthdate();
    final savedName = await NameService.getFullName();

    if (!mounted) return;
    setState(() {
      if (savedBirth != null) {
        _lifePathResult = _computeLifePathFromGregorian(savedBirth.$1, savedBirth.$2, savedBirth.$3);
        _birthDayResult = calculateBirthDayNumber(savedBirth.$1);
        _birthRawDay = savedBirth.$1;
        _birthRawMonth = savedBirth.$2;
        _birthRawYear = savedBirth.$3;
      } else {
        _showBirthForm = true;
      }

      if (savedName != null && savedName.trim().isNotEmpty) {
        final nameNum = calculateNameNumber(savedName);
        _nameResult = nameNumbers[nameNum];
        _nameController.text = savedName;
      } else {
        _showNameForm = true;
      }

      _loading = false;
    });
  }

  Future<void> _calculateBirth() async {
    final day = int.tryParse(_dayController.text.trim());
    final month = int.tryParse(_monthController.text.trim());
    final year = int.tryParse(_yearController.text.trim());

    if (!isValidJalaliDate(year, month, day)) {
      setState(() => _birthError = 'لطفاً تاریخ تولد شمسی را کامل و درست وارد کن.');
      return;
    }

    final gregorian = jalaliToGregorian(year!, month!, day!);
    await BirthdateService.saveBirthdate(day: gregorian.day, month: gregorian.month, year: gregorian.year);

    setState(() {
      _birthError = null;
      _showBirthForm = false;
      _lifePathResult = _computeLifePathFromGregorian(gregorian.day, gregorian.month, gregorian.year);
      _birthDayResult = calculateBirthDayNumber(gregorian.day);
      _birthRawDay = gregorian.day;
      _birthRawMonth = gregorian.month;
      _birthRawYear = gregorian.year;
    });
  }

  Future<void> _calculateName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'لطفاً نام و نام‌خانوادگی را وارد کن.');
      return;
    }

    await NameService.saveFullName(name);
    final nameNum = calculateNameNumber(name);

    setState(() {
      _nameError = null;
      _showNameForm = false;
      _nameResult = nameNumbers[nameNum];
    });
  }

  void _changeBirthdate() => setState(() => _showBirthForm = true);
  void _changeName() => setState(() => _showNameForm = true);

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عددشناسی')),
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
                        if (_showBirthForm || _lifePathResult == null)
                          _buildBirthForm()
                        else ...[
                          _buildLifePathResult(_lifePathResult!),
                          const SizedBox(height: 28),
                          const Divider(color: AppColors.glassBorder),
                          const SizedBox(height: 20),
                          if (_showNameForm || _nameResult == null)
                            _buildNameForm()
                          else ...[
                            _buildNameResult(_nameResult!),
                            const SizedBox(height: 28),
                            _buildCombinationSection(_lifePathResult!, _nameResult!),
                            const SizedBox(height: 28),
                            const Divider(color: AppColors.glassBorder),
                            const SizedBox(height: 20),
                            _buildSoulMissionSection(_lifePathResult!, _nameResult!),
                            const SizedBox(height: 28),
                            const Divider(color: AppColors.glassBorder),
                            const SizedBox(height: 20),
                            _buildDailySentencesSection(_lifePathResult!),
                            const SizedBox(height: 28),
                            const Divider(color: AppColors.glassBorder),
                            const SizedBox(height: 20),
                            _buildLifeCyclesSection(),
                            const SizedBox(height: 28),
                            const Divider(color: AppColors.glassBorder),
                            const SizedBox(height: 20),
                            _buildNineYearCyclesSection(),
                          ],
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ---------- بخش تاریخ تولد (عدد مسیر زندگی) ----------

  Widget _buildBirthForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        const Icon(Icons.pin_outlined, color: AppColors.gold, size: 64),
        const SizedBox(height: 20),
        Text('عدد مسیر زندگی‌ات را کشف کن', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
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
        if (_birthError != null) ...[
          const SizedBox(height: 12),
          Text(_birthError!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: () => _calculateBirth(), child: const Text('محاسبه‌ی عدد مسیر زندگی')),
        ),
      ],
    );
  }

  Widget _buildLifePathResult(LifePathNumber result) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sectionTitle('عدد مسیر زندگی', Icons.pin_outlined),
          const SizedBox(height: 12),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 2),
            ),
            child: Center(
              child: Text('${result.number}', style: AppTextStyles.displayMedium.copyWith(color: AppColors.gold)),
            ),
          ),
          const SizedBox(height: 16),
          Text(result.title, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.gold), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          _sectionCard(
            child: Text(result.description, textAlign: TextAlign.center, style: AppTextStyles.bodyLarge.copyWith(height: 1.9)),
          ),
          const SizedBox(height: 14),
          _sectionSubHeader('خصوصیات مثبت', Icons.thumb_up_outlined, const Color(0xFF3E9C6E)),
          _sectionCard(child: _traitsList(result.positiveTraits, const Color(0xFF3E9C6E))),
          const SizedBox(height: 14),
          _sectionSubHeader('خصوصیات منفی', Icons.thumb_down_outlined, AppColors.error),
          _sectionCard(child: _traitsList(result.negativeTraits, AppColors.error)),
          const SizedBox(height: 14),
          _sectionSubHeader('ماموریت روح', Icons.auto_awesome_outlined, AppColors.gold),
          _sectionCard(
            child: Text(result.soulMission, textAlign: TextAlign.center, style: AppTextStyles.bodyLarge.copyWith(height: 1.9)),
          ),
          const SizedBox(height: 14),
          _sectionSubHeader('شغل‌های مناسب', Icons.work_outline, const Color(0xFF3E6FE0)),
          _sectionCard(child: _chipsWrap(result.suitableJobs)),
          const SizedBox(height: 14),
          _sectionSubHeader('ویژگی‌های تکمیلی', Icons.spa_outlined, AppColors.gold),
          _sectionCard(
            child: Column(
              children: [
                _infoRow('رنگ مناسب', result.suitableColor),
                const SizedBox(height: 10),
                _infoRow('سنگ مناسب', result.suitableStone),
                const SizedBox(height: 10),
                _infoRow('انرژی غالب', result.dominantEnergy),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextButton(onPressed: _changeBirthdate, child: const Text('تغییر تاریخ تولد')),
        ],
      ),
    );
  }

  // ---------- بخش نام (عدد اسم) ----------

  Widget _buildNameForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.badge_outlined, color: AppColors.gold, size: 56),
        const SizedBox(height: 16),
        Text('عدد اسم‌ات را هم کشف کن', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text('نام و نام‌خانوادگی‌ات را وارد کن', textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(hintText: 'مثلاً: مرتضی احمدی'),
        ),
        if (_nameError != null) ...[
          const SizedBox(height: 12),
          Text(_nameError!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: () => _calculateName(), child: const Text('محاسبه‌ی عدد اسم')),
        ),
      ],
    );
  }

  Widget _buildNameResult(NameNumber result) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sectionTitle('عدد اسم', Icons.badge_outlined),
          const SizedBox(height: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.purple, width: 2),
            ),
            child: Center(
              child: Text('${result.number}', style: AppTextStyles.displayMedium.copyWith(color: AppColors.purple)),
            ),
          ),
          const SizedBox(height: 14),
          Text(result.title, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.gold), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          _sectionCard(
            child: Text(result.description, textAlign: TextAlign.center, style: AppTextStyles.bodyLarge.copyWith(height: 1.9)),
          ),
          const SizedBox(height: 14),
          _sectionSubHeader('استعدادها', Icons.stars_outlined, const Color(0xFF3E9C6E)),
          _sectionCard(child: _traitsList(result.talents, const Color(0xFF3E9C6E))),
          const SizedBox(height: 14),
          _sectionSubHeader('نقاط ضعف', Icons.warning_amber_outlined, AppColors.error),
          _sectionCard(child: _traitsList(result.weaknesses, AppColors.error)),
          const SizedBox(height: 14),
          _sectionSubHeader('توانایی‌های ذاتی', Icons.diamond_outlined, AppColors.gold),
          _sectionCard(child: _traitsList(result.innateAbilities, AppColors.gold)),
          const SizedBox(height: 14),
          TextButton(onPressed: _changeName, child: const Text('تغییر نام')),
        ],
      ),
    );
  }

  // ---------- بخش ترکیب ----------

  Widget _buildCombinationSection(LifePathNumber lp, NameNumber nn) {
    final text = buildCombinationText(
      lifePathNumber: lp.number,
      lifePathEnergy: lp.dominantEnergy,
      lifePathTopTrait: lp.positiveTraits.first,
      lifePathMission: lp.soulMission,
      nameNumberValue: nn.number,
      nameEnergy: nn.dominantEnergy,
      nameTopTalent: nn.talents.first,
      nameTopAbility: nn.innateAbilities.first,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _sectionTitle('ترکیب عدد تولد و عدد اسم', Icons.join_full_outlined),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gold.withOpacity(0.12), AppColors.purple.withOpacity(0.12)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGold),
          ),
          child: Text(text, textAlign: TextAlign.center, style: AppTextStyles.bodyLarge.copyWith(height: 1.9)),
        ),
      ],
    );
  }

  // ---------- بخش ماموریت روح ----------

  Widget _buildSoulMissionSection(LifePathNumber lp, NameNumber nn) {
    if (_birthDayResult == null) return const SizedBox.shrink();

    final report = buildSoulMissionReport(
      lifePath: lp,
      nameNumber: nn,
      birthDay: _birthDayResult!,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _sectionTitle('ماموریت روح', Icons.self_improvement_outlined),
        const SizedBox(height: 4),
        Text('بر پایه‌ی عدد مسیر زندگی، عدد اسم، و عدد روز تولد (${_birthDayResult!.title})',
            style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: 14),
        _sectionSubHeader('هدف زندگی', Icons.flag_outlined, AppColors.gold),
        _sectionCard(child: Text(report.lifeGoal, textAlign: TextAlign.center, style: AppTextStyles.bodyLarge.copyWith(height: 1.9))),
        const SizedBox(height: 14),
        _sectionSubHeader('درس‌های روح', Icons.school_outlined, const Color(0xFF3E6FE0)),
        _sectionCard(child: _traitsList(report.soulLessons, const Color(0xFF3E6FE0))),
        const SizedBox(height: 14),
        _sectionSubHeader('چالش‌های روح', Icons.warning_amber_outlined, AppColors.error),
        _sectionCard(child: _traitsList(report.soulChallenges, AppColors.error)),
        const SizedBox(height: 14),
        _sectionSubHeader('کارمای احتمالی', Icons.loop, const Color(0xFF9C3EE0)),
        _sectionCard(child: Text(report.possibleKarma, textAlign: TextAlign.center, style: AppTextStyles.bodyLarge.copyWith(height: 1.9))),
        const SizedBox(height: 14),
        _sectionSubHeader('استعدادهای پنهان', Icons.diamond_outlined, const Color(0xFF3E9C6E)),
        _sectionCard(child: _traitsList(report.hiddenTalents, const Color(0xFF3E9C6E))),
        const SizedBox(height: 14),
        _sectionSubHeader('توانایی‌های معنوی', Icons.auto_awesome_outlined, AppColors.gold),
        _sectionCard(child: _traitsList(report.spiritualAbilities, AppColors.gold)),
        const SizedBox(height: 14),
        _sectionSubHeader('نقاطی که باید اصلاح شوند', Icons.build_outlined, AppColors.textSecondary),
        _sectionCard(child: _traitsList(report.pointsToImprove, AppColors.textSecondary)),
      ],
    );
  }

  // ---------- بخش جملات روزانه ----------

  Widget _buildDailySentencesSection(LifePathNumber lp) {
    final sentences = getDailySentences(lp.number, DateTime.now(), count: 5);
    if (sentences.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _sectionTitle('جملات امروز تو', Icons.today_outlined),
        const SizedBox(height: 4),
        Text('بر پایه‌ی عدد مسیر زندگی ${lp.number}', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: 14),
        ...sentences.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.gold, size: 14),
                    const SizedBox(width: 10),
                    Expanded(child: Text(s, style: AppTextStyles.bodyMedium)),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // ---------- بخش سه چرخه‌ی زندگی ----------

  Widget _buildLifeCyclesSection() {
    if (_birthRawDay == null || _birthRawMonth == null || _birthRawYear == null) return const SizedBox.shrink();

    final cycles = buildThreeLifeCycles(day: _birthRawDay!, month: _birthRawMonth!, year: _birthRawYear!);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _sectionTitle('چرخه‌های زندگی', Icons.timeline_outlined),
        const SizedBox(height: 14),
        ...cycles.map((c) => Padding(
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
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), shape: BoxShape.circle),
                          child: Center(child: Text('${c.cycleNumber}', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.periodLabel, style: AppTextStyles.bodySmall),
                              Text(c.title, style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(c.description, style: AppTextStyles.bodyMedium.copyWith(height: 1.8)),
                    const SizedBox(height: 12),
                    Text('فرصت‌ها: ${c.opportunities.join('، ')}', style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF3E9C6E))),
                    const SizedBox(height: 6),
                    Text('چالش‌ها: ${c.challenges.join('، ')}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // ---------- بخش چرخه‌های ۹ساله ----------

  Widget _buildNineYearCyclesSection() {
    final cycles = buildNineYearCycles();
    int? currentAge;
    if (_birthRawYear != null) {
      currentAge = DateTime.now().year - _birthRawYear!;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _sectionTitle('چرخه‌های ۹ ساله', Icons.repeat_outlined),
        const SizedBox(height: 4),
        Text('از تولد تا ۹۰ سالگی', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: 14),
        ...cycles.map((cycle) {
          final isCurrent = currentAge != null && currentAge >= cycle.startAge && currentAge < cycle.endAge;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: isCurrent,
                collapsedBackgroundColor: isCurrent ? AppColors.gold.withOpacity(0.08) : AppColors.glassFill,
                backgroundColor: AppColors.gold.withOpacity(0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: isCurrent ? AppColors.gold : AppColors.glassBorder),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: isCurrent ? AppColors.gold : AppColors.glassBorder),
                ),
                title: Row(
                  children: [
                    Text('${cycle.startAge} تا ${cycle.endAge} سالگی', style: AppTextStyles.cardLabel),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(10)),
                        child: Text('الان', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textOnGold, fontSize: 10)),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(cycle.title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Text(cycle.lifeLesson, style: AppTextStyles.bodyMedium.copyWith(height: 1.8)),
                  const SizedBox(height: 10),
                  Text('نقاط قوت: ${cycle.strengths.join('، ')}', style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF3E9C6E))),
                  const SizedBox(height: 6),
                  Text('چالش‌ها: ${cycle.challenges.join('، ')}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
                  const SizedBox(height: 6),
                  Text('فرصت‌ها: ${cycle.opportunities.join('، ')}', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.glassBorder),
                  const SizedBox(height: 8),
                  _timingRow('شروع کار', cycle.goodForStartingWork),
                  _timingRow('تغییر شغل', cycle.goodForChangingJob),
                  _timingRow('یادگیری', cycle.goodForLearning),
                  _timingRow('روابط', cycle.goodForRelationships),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _timingRow(String label, String advice) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$label: ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold)),
            TextSpan(text: advice, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  // ---------- ویجت‌های کمکی مشترک ----------

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.gold, size: 20),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.headlineSmall),
      ],
    );
  }

  Widget _sectionSubHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(title, style: AppTextStyles.cardLabel.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: child,
    );
  }

  Widget _traitsList(List<String> traits, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: traits.map((t) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(Icons.circle, size: 6, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(t, style: AppTextStyles.bodyMedium)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _chipsWrap(List<String> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: items.map((job) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withOpacity(0.3)),
          ),
          child: Text(job, style: AppTextStyles.bodySmall),
        );
      }).toList(),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text(value, style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
      ],
    );
  }
}
