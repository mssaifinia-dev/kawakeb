import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../../../core/utils/persian_date_converter.dart';
import '../../../core/services/birthdate_service.dart';
import '../../../core/services/family_members_service.dart';
import '../data/numerology_data.dart';
import '../data/compatibility_data.dart';
import '../data/family_report_data.dart';

LifePathNumber? _computeLifePath(int day, int month, int year) {
  final sum = '$day$month$year'.split('').map(int.parse).reduce((a, b) => a + b);
  return lifePathNumbers[reduceWithMasterNumbers(sum)];
}

const List<String> _relationOptions = ['همسر', 'فرزند', 'دوست', 'همکار'];

class FamilyRelationshipsScreen extends StatefulWidget {
  const FamilyRelationshipsScreen({super.key});

  @override
  State<FamilyRelationshipsScreen> createState() => _FamilyRelationshipsScreenState();
}

class _FamilyRelationshipsScreenState extends State<FamilyRelationshipsScreen> {
  bool _loading = true;
  LifePathNumber? _selfLifePath;
  List<FamilyMember> _members = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final selfBirth = await BirthdateService.getBirthdate();
    final members = await FamilyMembersService.getMembers();
    if (!mounted) return;
    setState(() {
      if (selfBirth != null) {
        _selfLifePath = _computeLifePath(selfBirth.$1, selfBirth.$2, selfBirth.$3);
      }
      _members = members;
      _loading = false;
    });
  }

  Future<void> _openAddMemberForm() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => const _AddMemberSheet(),
    );
    if (added == true) {
      _load();
    }
  }

  Future<void> _removeMember(String id) async {
    await FamilyMembersService.removeMember(id);
    _load();
  }

  void _openCompatibility(FamilyMember member) {
    if (_selfLifePath == null) return;
    final memberLifePath = _computeLifePath(member.day, member.month, member.year);
    if (memberLifePath == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CompatibilityScreen(
          selfLifePath: _selfLifePath!,
          member: member,
          memberLifePath: memberLifePath,
        ),
      ),
    );
  }

  IconData _iconForRelation(String relation) {
    switch (relation) {
      case 'همسر':
        return Icons.favorite_outline;
      case 'فرزند':
        return Icons.child_care_outlined;
      case 'همکار':
        return Icons.work_outline;
      default:
        return Icons.people_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تحلیل روابط و خانواده')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.textOnGold,
        onPressed: _openAddMemberForm,
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : _selfLifePath == null
                    ? _buildNeedsBirthdate()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_members.isEmpty) _buildEmptyState() else _buildMembersList(),
                            if (_members.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              const Divider(color: AppColors.glassBorder),
                              const SizedBox(height: 20),
                              _buildFamilyReport(),
                            ],
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedsBirthdate() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'برای تحلیل روابط، اول باید تاریخ تولد خودت را (مثلاً از بخش کتاب سرنوشت) ثبت کنی.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, color: AppColors.gold, size: 56),
          const SizedBox(height: 16),
          Text('هنوز کسی رو اضافه نکردی', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'با دکمه‌ی + همسر، فرزند، دوست یا همکارت رو اضافه کن تا تحلیل هماهنگی‌تون رو ببینی',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _members.map((m) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openCompatibility(m),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.purple.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(_iconForRelation(m.relation), color: AppColors.purple, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: AppTextStyles.cardLabel),
                        Text(m.relation, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeMember(m.id),
                    icon: Icon(Icons.delete_outline, color: AppColors.textSecondary.withOpacity(0.6), size: 20),
                  ),
                  const Icon(Icons.chevron_left, color: AppColors.gold),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFamilyReport() {
    final lifePaths = <LifePathNumber>[
      if (_selfLifePath != null) _selfLifePath!,
      for (final m in _members)
        if (_computeLifePath(m.day, m.month, m.year) != null) _computeLifePath(m.day, m.month, m.year)!,
    ];
    final report = buildFamilyReport(lifePaths);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.groups_outlined, color: AppColors.gold, size: 20),
            const SizedBox(width: 8),
            Text('گزارش خانواده', style: AppTextStyles.headlineSmall),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Text(report.collectiveMission, textAlign: TextAlign.center, style: AppTextStyles.bodyLarge.copyWith(height: 1.9)),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('نقاط قوت خانواده', style: AppTextStyles.cardLabel.copyWith(color: const Color(0xFF3E9C6E))),
              const SizedBox(height: 6),
              Text(report.familyStrengths.join('، '), style: AppTextStyles.bodyMedium),
              const SizedBox(height: 14),
              Text('چالش‌های خانواده', style: AppTextStyles.cardLabel.copyWith(color: AppColors.error)),
              const SizedBox(height: 6),
              Text(report.familyChallenges.join('، '), style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------- فرم افزودن عضو ----------------

class _AddMemberSheet extends StatefulWidget {
  const _AddMemberSheet();

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _nameController = TextEditingController();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  String _relation = _relationOptions.first;
  String? _error;

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final day = int.tryParse(_dayController.text.trim());
    final month = int.tryParse(_monthController.text.trim());
    final year = int.tryParse(_yearController.text.trim());

    if (name.isEmpty || !isValidJalaliDate(year, month, day)) {
      setState(() => _error = 'نام و تاریخ تولد شمسی را کامل و درست وارد کن.');
      return;
    }

    final gregorian = jalaliToGregorian(year!, month!, day!);

    await FamilyMembersService.addMember(FamilyMember(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      relation: _relation,
      name: name,
      day: gregorian.day,
      month: gregorian.month,
      year: gregorian.year,
    ));

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('افزودن فرد جدید', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: _relationOptions.map((r) {
              final selected = r == _relation;
              return ChoiceChip(
                label: Text(r),
                selected: selected,
                onSelected: (_) => setState(() => _relation = r),
                selectedColor: AppColors.gold.withOpacity(0.25),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: 'نام'),
          ),
          const SizedBox(height: 12),
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
                  decoration: const InputDecoration(hintText: 'سال شمسی'),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
          ],
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _submit, child: const Text('افزودن'))),
        ],
      ),
    );
  }
}

// ---------------- صفحه‌ی نتیجه‌ی هماهنگی ----------------

class _CompatibilityScreen extends StatelessWidget {
  final LifePathNumber selfLifePath;
  final FamilyMember member;
  final LifePathNumber memberLifePath;

  const _CompatibilityScreen({
    required this.selfLifePath,
    required this.member,
    required this.memberLifePath,
  });

  @override
  Widget build(BuildContext context) {
    final report = buildCompatibilityReport(person1: selfLifePath, person2: memberLifePath);

    return Scaffold(
      appBar: AppBar(title: Text('هماهنگی با ${member.name}')),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _personBadge('تو', selfLifePath.number),
                      const SizedBox(width: 14),
                      const Icon(Icons.favorite, color: AppColors.gold, size: 20),
                      const SizedBox(width: 14),
                      _personBadge(member.name, memberLifePath.number),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: Text('${report.harmonyLevel} (${report.harmonyPercent}٪)',
                        style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
                  ),
                  const SizedBox(height: 20),
                  _reportCard('انرژی مشترک', Icons.bolt_outlined, AppColors.gold, report.sharedEnergy),
                  const SizedBox(height: 14),
                  _reportCard('درس مشترک', Icons.school_outlined, const Color(0xFF3E6FE0), report.sharedLesson),
                  const SizedBox(height: 14),
                  _reportListCard('تفاوت‌ها', Icons.compare_arrows, AppColors.error, report.differences),
                  const SizedBox(height: 14),
                  _reportListCard('نقاط حساس', Icons.warning_amber_outlined, const Color(0xFF9C3EE0), report.sensitivePoints),
                  const SizedBox(height: 14),
                  _reportCard('راهکار بهتر شدن رابطه', Icons.handshake_outlined, const Color(0xFF3E9C6E), report.advice),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _personBadge(String label, int number) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.glassFill,
            border: Border.all(color: AppColors.gold),
          ),
          child: Center(child: Text('$number', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.gold))),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _reportCard(String title, IconData icon, Color color, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(title, style: AppTextStyles.cardLabel.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Text(text, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium.copyWith(height: 1.8)),
        ),
      ],
    );
  }

  Widget _reportListCard(String title, IconData icon, Color color, List<String> items) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(title, style: AppTextStyles.cardLabel.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items
                .map((t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 6, color: color),
                          const SizedBox(width: 8),
                          Expanded(child: Text(t, style: AppTextStyles.bodyMedium)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
