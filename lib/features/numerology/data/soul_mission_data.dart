import 'numerology_data.dart';
import 'name_number_data.dart';
import 'birth_day_number_data.dart';

class SoulMissionReport {
  final String lifeGoal;
  final List<String> soulLessons;
  final List<String> soulChallenges;
  final String possibleKarma;
  final List<String> hiddenTalents;
  final List<String> spiritualAbilities;
  final List<String> pointsToImprove;

  const SoulMissionReport({
    required this.lifeGoal,
    required this.soulLessons,
    required this.soulChallenges,
    required this.possibleKarma,
    required this.hiddenTalents,
    required this.spiritualAbilities,
    required this.pointsToImprove,
  });
}

/// گزارش «ماموریت روح» با ترکیب پویای سه عدد: مسیر زندگی، اسم، و روز تولد.
/// به‌جای جدول ثابت (که برای هزاران ترکیب ممکن غیرقابل‌نگهداری است)، از
/// محتوای از‌پیش‌تعریف‌شده‌ی هر عدد به‌صورت هدفمند در قالب یک گزارش می‌چیند.
SoulMissionReport buildSoulMissionReport({
  required LifePathNumber lifePath,
  required NameNumber nameNumber,
  required BirthDayNumberInfo birthDay,
}) {
  return SoulMissionReport(
    lifeGoal:
        '${lifePath.soulMission} در مسیر رسیدن به این هدف، ${birthDay.keyword.toLowerCase()} به‌عنوان یک ابزار طبیعی در اختیار داری.',
    soulLessons: [
      lifePath.negativeTraits.first == lifePath.negativeTraits.last
          ? 'یاد گرفتن غلبه بر ${lifePath.negativeTraits.first}'
          : 'یاد گرفتن غلبه بر ${lifePath.negativeTraits.first} و ${lifePath.negativeTraits.last}',
      'تمرین ${nameNumber.weaknesses.first} را به یک نقطه‌ی قوت تبدیل کردن',
      'هماهنگ کردن ${lifePath.dominantEnergy} با ${nameNumber.dominantEnergy} در زندگی روزمره',
    ],
    soulChallenges: [
      lifePath.negativeTraits.length > 1 ? lifePath.negativeTraits[1] : lifePath.negativeTraits.first,
      nameNumber.weaknesses.length > 1 ? nameNumber.weaknesses[1] : nameNumber.weaknesses.first,
    ],
    possibleKarma:
        'الگویی که در این زندگی برای عبور از آن آمده‌ای، احتمالاً حول محور «${lifePath.negativeTraits.first}» در کنار «${nameNumber.weaknesses.first}» شکل گرفته — یعنی موقعیت‌هایی تکرار می‌شوند تا این دو را آگاهانه تبدیل کنی.',
    hiddenTalents: [
      nameNumber.innateAbilities.first,
      birthDay.keyword,
    ],
    spiritualAbilities: [
      lifePath.number == 11 || lifePath.number == 22 || lifePath.number == 33
          ? 'ارتباط قوی و طبیعی با دنیای شهودی و معنوی'
          : 'ظرفیت رشد معنوی از طریق ${lifePath.dominantEnergy}',
      nameNumber.number == 11 || nameNumber.number == 22 || nameNumber.number == 33
          ? 'حساسیت بالا نسبت به انرژی‌های اطراف'
          : 'یادگیری معنویت از طریق تجربه‌ی روزمره',
    ],
    pointsToImprove: [
      lifePath.negativeTraits.last,
      nameNumber.weaknesses.last,
    ],
  );
}
