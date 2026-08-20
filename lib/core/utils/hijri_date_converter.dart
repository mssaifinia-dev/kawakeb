import 'persian_date_converter.dart';

/// تبدیل تاریخ قمری (هجری) به میلادی با الگوریتم استاندارد تقویم قمری جدولی
/// (تقویم مدنی/Civil، نه رصدی) — رایج در بیشتر کتابخانه‌های محاسباتی.
/// ممکن است با رؤیت هلال واقعی در برخی کشورها یک روز اختلاف داشته باشد.

const int _islamicEpoch = 1948440;

int _islamicToJulianDayNumber(int hy, int hm, int hd) {
  return hd +
      ((29.5 * (hm - 1)).ceil()) +
      (hy - 1) * 354 +
      ((3 + 11 * hy) ~/ 30) +
      _islamicEpoch -
      1;
}

GregorianDate _julianDayToGregorian(int jd) {
  int l = jd + 68569;
  final n = (4 * l) ~/ 146097;
  l = l - (146097 * n + 3) ~/ 4;
  final i = (4000 * (l + 1)) ~/ 1461001;
  l = l - (1461 * i) ~/ 4 + 31;
  final j = (80 * l) ~/ 2447;
  final day = l - (2447 * j) ~/ 80;
  l = j ~/ 11;
  final month = j + 2 - 12 * l;
  final year = 100 * (n - 49) + i + l;
  return GregorianDate(year: year, month: month, day: day);
}

GregorianDate hijriToGregorian(int hy, int hm, int hd) {
  final jd = _islamicToJulianDayNumber(hy, hm, hd);
  return _julianDayToGregorian(jd);
}

bool isValidHijriDate(int? year, int? month, int? day) {
  if (year == null || month == null || day == null) return false;
  if (month < 1 || month > 12) return false;
  if (day < 1 || day > 30) return false;
  if (year < 1) return false;
  return true;
}
