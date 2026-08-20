import 'numerology_data.dart';

class LifeCyclePeriod {
  final int cycleNumber;
  final String periodLabel;
  final String title;
  final String description;
  final List<String> challenges;
  final List<String> opportunities;
  final String periodMission;

  const LifeCyclePeriod({
    required this.cycleNumber,
    required this.periodLabel,
    required this.title,
    required this.description,
    required this.challenges,
    required this.opportunities,
    required this.periodMission,
  });
}

/// سه چرخه‌ی اصلی زندگی (۰-۳۰، ۳۰-۶۰، ۶۰+) طبق روش رایج عددشناسی:
/// چرخه‌ی اول از عدد ماه تولد، چرخه‌ی دوم از عدد روز تولد، و چرخه‌ی سوم
/// از عدد سال تولد به‌دست می‌آید. محتوای هرکدام از دیتای همان عدد در
/// جدول اصلی عدد مسیر زندگی گرفته می‌شود (بدون نیاز به جدول جداگانه).
List<LifeCyclePeriod> buildThreeLifeCycles({
  required int day,
  required int month,
  required int year,
}) {
  final cycle1Number = reduceWithMasterNumbers(month);
  final cycle2Number = reduceWithMasterNumbers(day);
  final cycle3Number = reduceWithMasterNumbers(_sumYearDigits(year));

  return [
    _buildPeriod(cycle1Number, '۰ تا ۳۰ سالگی — چرخه‌ی شکل‌گیری'),
    _buildPeriod(cycle2Number, '۳۰ تا ۶۰ سالگی — چرخه‌ی اوج فعالیت'),
    _buildPeriod(cycle3Number, '۶۰ سالگی به بعد — چرخه‌ی بلوغ و حکمت'),
  ];
}

int _sumYearDigits(int year) {
  return year.toString().split('').map(int.parse).reduce((a, b) => a + b);
}

LifeCyclePeriod _buildPeriod(int number, String label) {
  final data = lifePathNumbers[number] ?? lifePathNumbers[reduceWithMasterNumbers(_sumYearDigits(number))]!;
  return LifeCyclePeriod(
    cycleNumber: data.number,
    periodLabel: label,
    title: data.title,
    description: 'در این دوره، ${data.dominantEnergy.toLowerCase()} نقش پررنگی در زندگی‌ات دارد. ${data.description}',
    challenges: data.negativeTraits,
    opportunities: data.positiveTraits,
    periodMission: data.soulMission,
  );
}
