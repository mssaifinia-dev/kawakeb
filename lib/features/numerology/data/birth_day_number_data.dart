import 'numerology_data.dart' show reduceWithMasterNumbers;

class BirthDayNumberInfo {
  final int number;
  final String title;
  final String keyword;

  const BirthDayNumberInfo({
    required this.number,
    required this.title,
    required this.keyword,
  });
}

const Map<int, BirthDayNumberInfo> birthDayNumbers = {
  1: BirthDayNumberInfo(number: 1, title: 'روز آغازگری', keyword: 'استعداد شروع کارهای تازه بدون ترس'),
  2: BirthDayNumberInfo(number: 2, title: 'روز همراهی', keyword: 'مهارت طبیعی در کار تیمی و همدلی'),
  3: BirthDayNumberInfo(number: 3, title: 'روز بیان', keyword: 'استعداد بیان احساسات از طریق کلام یا هنر'),
  4: BirthDayNumberInfo(number: 4, title: 'روز ثبات', keyword: 'توانایی ساختن پایه‌های محکم و قابل‌اعتماد'),
  5: BirthDayNumberInfo(number: 5, title: 'روز تحرک', keyword: 'نیاز درونی به تنوع و تجربه‌های تازه'),
  6: BirthDayNumberInfo(number: 6, title: 'روز مراقبت', keyword: 'حس مسئولیت طبیعی نسبت به نزدیکان'),
  7: BirthDayNumberInfo(number: 7, title: 'روز تعمق', keyword: 'میل درونی به فهمیدن عمیق‌تر هر موضوع'),
  8: BirthDayNumberInfo(number: 8, title: 'روز اقتدار', keyword: 'استعداد طبیعی در مدیریت و سازمان‌دهی'),
  9: BirthDayNumberInfo(number: 9, title: 'روز بخشش', keyword: 'حساسیت طبیعی نسبت به رنج و نیاز دیگران'),
  11: BirthDayNumberInfo(number: 11, title: 'روز شهود (عدد استاد)', keyword: 'حساسیت شهودی فراتر از حد معمول'),
  22: BirthDayNumberInfo(number: 22, title: 'روز ساخت بزرگ (عدد استاد)', keyword: 'ظرفیت نادر برای ساختن چیزی ماندگار'),
};

/// عدد روز تولد: برخلاف عدد مسیر زندگی (که از کل تاریخ به‌دست می‌آید)،
/// این عدد فقط از خودِ روز تولد محاسبه می‌شود.
BirthDayNumberInfo? calculateBirthDayNumber(int day) {
  final reduced = reduceWithMasterNumbers(day);
  return birthDayNumbers[reduced];
}
