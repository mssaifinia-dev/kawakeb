/// تبدیل تاریخ شمسی (جلالی) به میلادی — پیاده‌سازی الگوریتم استاندارد و رایج
/// (مشابه کتابخانه‌ی معروف jalaali-js)، بدون نیاز به پکیج خارجی.
class GregorianDate {
  final int year;
  final int month;
  final int day;

  const GregorianDate({required this.year, required this.month, required this.day});
}

GregorianDate jalaliToGregorian(int jy, int jm, int jd) {
  int gy = jy <= 979 ? 621 : 1600;
  jy -= jy <= 979 ? 0 : 979;

  double days = 365 * jy +
      (jy ~/ 33) * 8 +
      ((jy % 33 + 3) ~/ 4) +
      78 +
      jd +
      (jm < 7 ? (jm - 1) * 31 : (jm - 7) * 30 + 186);

  gy += 400 * (days ~/ 146097).toInt();
  days %= 146097;

  if (days > 36524) {
    gy += 100 * ((days - 1) ~/ 36524).toInt();
    days -= ((days - 1) ~/ 36524).toInt() * 36524;
    if (days >= 365) days += 1;
  }

  gy += 4 * (days ~/ 1461).toInt();
  days %= 1461;

  if (days > 365) {
    gy += ((days - 1) ~/ 365).toInt();
    days = (days - 1) % 365;
  }

  int gd = days.toInt() + 1;

  final bool isLeap = (gy % 4 == 0 && gy % 100 != 0) || (gy % 400 == 0);
  final List<int> monthDays = [0, 31, isLeap ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  int gm = 1;
  while (gm < 13 && gd > monthDays[gm]) {
    gd -= monthDays[gm];
    gm++;
  }

  return GregorianDate(year: gy, month: gm, day: gd);
}

class JalaliDate {
  final int year;
  final int month;
  final int day;

  const JalaliDate({required this.year, required this.month, required this.day});
}

/// تبدیل تاریخ میلادی به شمسی — عکس تابع بالا، برای نمایش تاریخ ذخیره‌شده
/// (که همیشه به میلادی نگه‌داری می‌شود) به کاربر به شکلی که خودش می‌شناسد.
JalaliDate gregorianToJalali(int gy, int gm, int gd) {
  const List<int> gDaysInMonth = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];

  int jy = gy <= 1600 ? 0 : 979;
  int gy2 = gy <= 1600 ? gy - 621 : gy - 1600;
  final gy3 = gm > 2 ? gy2 + 1 : gy2;

  int days = (365 * gy2) +
      ((gy3 + 3) ~/ 4) -
      ((gy3 + 99) ~/ 100) +
      ((gy3 + 399) ~/ 400) -
      80 +
      gd +
      gDaysInMonth[gm - 1];

  jy += 33 * (days ~/ 12053);
  days %= 12053;
  jy += 4 * (days ~/ 1461);
  days %= 1461;

  if (days > 365) {
    jy += (days - 1) ~/ 365;
    days = (days - 1) % 365;
  }

  int jm;
  int jd;
  if (days < 186) {
    jm = 1 + (days ~/ 31);
    jd = 1 + (days % 31);
  } else {
    jm = 7 + ((days - 186) ~/ 30);
    jd = 1 + ((days - 186) % 30);
  }

  return JalaliDate(year: jy, month: jm, day: jd);
}

/// یک بررسی ساده‌ی صحت برای ورودی تاریخ شمسی
bool isValidJalaliDate(int? year, int? month, int? day) {
  if (year == null || month == null || day == null) return false;
  if (month < 1 || month > 12) return false;
  if (day < 1 || day > 31) return false;
  if (month > 6 && day > 30) return false;
  return true;
}
