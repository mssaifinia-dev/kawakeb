import 'numerology_data.dart';

class FamilyReport {
  final List<String> familyEnergies;
  final List<String> familyStrengths;
  final List<String> familyChallenges;
  final String collectiveMission;

  const FamilyReport({
    required this.familyEnergies,
    required this.familyStrengths,
    required this.familyChallenges,
    required this.collectiveMission,
  });
}

/// گزارش خانواده از ترکیب عدد مسیر زندگی همه‌ی اعضا (شامل خود کاربر) ساخته می‌شود.
FamilyReport buildFamilyReport(List<LifePathNumber> members) {
  if (members.isEmpty) {
    return const FamilyReport(
      familyEnergies: [],
      familyStrengths: [],
      familyChallenges: [],
      collectiveMission: 'برای دیدن گزارش خانواده، حداقل یک عضو دیگر اضافه کن.',
    );
  }

  final energies = members.map((m) => m.dominantEnergy).toSet().toList();

  final strengthsCount = <String, int>{};
  for (final m in members) {
    for (final t in m.positiveTraits) {
      strengthsCount[t] = (strengthsCount[t] ?? 0) + 1;
    }
  }
  final strengths = strengthsCount.keys.toList()
    ..sort((a, b) => strengthsCount[b]!.compareTo(strengthsCount[a]!));

  final challengesCount = <String, int>{};
  for (final m in members) {
    for (final t in m.negativeTraits) {
      challengesCount[t] = (challengesCount[t] ?? 0) + 1;
    }
  }
  final challenges = challengesCount.keys.toList()
    ..sort((a, b) => challengesCount[b]!.compareTo(challengesCount[a]!));

  final missionParts = members.map((m) => m.dominantEnergy).toSet().join('، ');
  final collectiveMission =
      'انرژی جمعی این خانواده ترکیبی از $missionParts است. ماموریت مشترک این جمع، هماهنگ کردن این انرژی‌های متفاوت در کنار هم، بدون کمرنگ شدن هیچ‌کدام، است.';

  return FamilyReport(
    familyEnergies: energies,
    familyStrengths: strengths.take(5).toList(),
    familyChallenges: challenges.take(5).toList(),
    collectiveMission: collectiveMission,
  );
}
