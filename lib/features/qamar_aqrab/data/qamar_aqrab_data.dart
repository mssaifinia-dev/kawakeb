import 'dart:math';

const List<String> zodiacTropicalNames = [
  'حمل', 'ثور', 'جوزا', 'سرطان', 'اسد', 'سنبله',
  'میزان', 'عقرب', 'قوس', 'جدی', 'دلو', 'حوت',
];

/// محاسبه‌ی روز ژولین (Julian Day) از تاریخ میلادی
double _julianDay(int year, int month, int day) {
  int y = year;
  int m = month;
  if (m <= 2) {
    y -= 1;
    m += 12;
  }
  final a = (y / 100).floor();
  final b = 2 - a + (a / 4).floor();
  return (365.25 * (y + 4716)).floor() +
      (30.6001 * (m + 1)).floor() +
      day +
      b -
      1524.5;
}

/// طول میانگین ماه (Mean Lunar Longitude) به درجه — فرمول ساده‌شده‌ی نجومی (Meeus)
/// این یک تقریب معقول است، نه محاسبه‌ی دقیق افمریسی.
double _meanLunarLongitude(double julianDay) {
  final t = (julianDay - 2451545.0) / 36525.0;
  double l = 218.3164477 +
      481267.88123421 * t -
      0.0015786 * t * t +
      (t * t * t) / 538841.0 -
      (t * t * t * t) / 65194000.0;
  l = l % 360;
  if (l < 0) l += 360;
  return l;
}

/// برج تروپیکال ماه برای یک تاریخ میلادی مشخص
String getMoonZodiacSign(DateTime date) {
  final jd = _julianDay(date.year, date.month, date.day);
  final longitude = _meanLunarLongitude(jd);
  final index = (longitude / 30).floor() % 12;
  return zodiacTropicalNames[index];
}

bool isMoonInScorpio(DateTime date) {
  return getMoonZodiacSign(date) == 'عقرب';
}

/// پیدا کردن بازه‌ی تقریبی ورود و خروج ماه از برج عقرب، با جست‌وجوی روز‌به‌روز
/// اطراف تاریخ داده‌شده (حداکثر ۱۰ روز به عقب و جلو، چون هر گذر معمولاً ۲ تا ۳ روز طول می‌کشد)
(DateTime?, DateTime?) findScorpioTransitRange(DateTime referenceDate) {
  if (!isMoonInScorpio(referenceDate)) return (null, null);

  DateTime start = referenceDate;
  for (int i = 1; i <= 10; i++) {
    final candidate = referenceDate.subtract(Duration(days: i));
    if (isMoonInScorpio(candidate)) {
      start = candidate;
    } else {
      break;
    }
  }

  DateTime end = referenceDate;
  for (int i = 1; i <= 10; i++) {
    final candidate = referenceDate.add(Duration(days: i));
    if (isMoonInScorpio(candidate)) {
      end = candidate;
    } else {
      break;
    }
  }

  return (start, end);
}
