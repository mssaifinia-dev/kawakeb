import 'numerology_data.dart';

class CompatibilityReport {
  final String harmonyLevel;
  final int harmonyPercent;
  final List<String> differences;
  final String sharedLesson;
  final String sharedEnergy;
  final List<String> sensitivePoints;
  final String advice;

  const CompatibilityReport({
    required this.harmonyLevel,
    required this.harmonyPercent,
    required this.differences,
    required this.sharedLesson,
    required this.sharedEnergy,
    required this.sensitivePoints,
    required this.advice,
  });
}

// گروه‌بندی سنتی اعداد بر اساس عنصر مشترک، برای تخمین سطح هماهنگی
// ۱،۵،۹: مستقل و پرانرژی — ۲،۴،۸: عملگرا و باثبات — ۳،۶،۷: احساسی و درون‌نگر
const Map<int, int> _numberGroup = {
  1: 1, 5: 1, 9: 1,
  2: 2, 4: 2, 8: 2,
  3: 3, 6: 3, 7: 3,
  11: 3, 22: 2, 33: 3,
};

CompatibilityReport buildCompatibilityReport({
  required LifePathNumber person1,
  required LifePathNumber person2,
}) {
  final sameNumber = person1.number == person2.number;
  final sameGroup = _numberGroup[person1.number] == _numberGroup[person2.number];

  String harmonyLevel;
  int harmonyPercent;
  if (sameNumber) {
    harmonyLevel = 'هماهنگی بسیار بالا';
    harmonyPercent = 92;
  } else if (sameGroup) {
    harmonyLevel = 'هماهنگی خوب';
    harmonyPercent = 76;
  } else {
    harmonyLevel = 'هماهنگی نیازمند تلاش دوطرفه';
    harmonyPercent = 55;
  }

  final differences = <String>[
    '${person1.title}: ${person1.negativeTraits.first}',
    '${person2.title}: ${person2.negativeTraits.first}',
  ];

  final sharedLesson = sameNumber
      ? person1.soulMission
      : 'یاد گرفتن ترکیب ${person1.dominantEnergy.toLowerCase()} با ${person2.dominantEnergy.toLowerCase()} بدون سرکوب هیچ‌کدام.';

  final sharedEnergy = sameNumber
      ? person1.dominantEnergy
      : '${person1.dominantEnergy} در کنار ${person2.dominantEnergy}';

  final sensitivePoints = <String>[
    'تفاوت در ${person1.negativeTraits.length > 1 ? person1.negativeTraits[1] : person1.negativeTraits.first} در برابر ${person2.negativeTraits.length > 1 ? person2.negativeTraits[1] : person2.negativeTraits.first}',
    if (!sameGroup) 'سرعت و سبک تصمیم‌گیری این دو نفر می‌تواند متفاوت باشد',
  ];

  final advice = sameNumber
      ? 'چون هر دو انرژی مشابهی دارید، مراقب باشید در تکرار یک اشتباه مشترک (${person1.negativeTraits.first}) با هم گیر نکنید؛ تفاوت‌های کوچک را عمداً وارد رابطه کنید.'
      : 'به‌جای تلاش برای شبیه کردن یکدیگر، تفاوت ${person1.dominantEnergy.toLowerCase()} و ${person2.dominantEnergy.toLowerCase()} را به‌عنوان مکمل هم ببینید، نه تهدید.';

  return CompatibilityReport(
    harmonyLevel: harmonyLevel,
    harmonyPercent: harmonyPercent,
    differences: differences,
    sharedLesson: sharedLesson,
    sharedEnergy: sharedEnergy,
    sensitivePoints: sensitivePoints,
    advice: advice,
  );
}
