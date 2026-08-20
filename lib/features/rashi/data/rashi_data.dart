class RashiSign {
  final String name;
  final String sanskritName;
  final String dateRangeLabel;
  final int startMonth;
  final int startDay;
  final int endMonth;
  final int endDay;
  final String traits;

  const RashiSign({
    required this.name,
    required this.sanskritName,
    required this.dateRangeLabel,
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
    required this.traits,
  });
}

// نسخه‌ی ساده‌شده بر اساس تاریخ تولد (نه ساعت/محل دقیق تولد).
// بازه‌های تاریخ تقریبی سیستم سایدریال هندی هستند (حدود ۲۳ روز عقب‌تر از زودیاک غربی).
const List<RashiSign> rashiSigns = [
  RashiSign(
    name: 'میش',
    sanskritName: 'Mesha',
    dateRangeLabel: '۱۴ فروردین تا ۱۳ اردیبهشت',
    startMonth: 4, startDay: 14, endMonth: 5, endDay: 14,
    traits: 'میش (Mesha) نماد شروع، انرژی و اراده‌ی قوی است. متولدینش پرانرژی و مستقل‌اند و در مواجهه با چالش‌ها سریع دست به کار می‌شوند.',
  ),
  RashiSign(
    name: 'گاو',
    sanskritName: 'Vrishabha',
    dateRangeLabel: '۱۴ اردیبهشت تا ۱۳ خرداد',
    startMonth: 5, startDay: 15, endMonth: 6, endDay: 14,
    traits: 'گاو (Vrishabha) نماد ثبات، صبر و ارتباط با زیبایی‌های زندگی است. متولدینش قابل‌اعتماد و پایدارند، اما در برابر تغییر مقاومت نشان می‌دهند.',
  ),
  RashiSign(
    name: 'دوپیکر',
    sanskritName: 'Mithuna',
    dateRangeLabel: '۱۴ خرداد تا ۱۴ تیر',
    startMonth: 6, startDay: 15, endMonth: 7, endDay: 15,
    traits: 'دوپیکر (Mithuna) نماد ارتباط، کنجکاوی ذهنی و انطباق‌پذیری است. متولدینش باهوش و اجتماعی‌اند اما گاهی در تصمیم‌گیری‌های بلندمدت دودل می‌مانند.',
  ),
  RashiSign(
    name: 'خرچنگ',
    sanskritName: 'Karka',
    dateRangeLabel: '۱۵ تیر تا ۱۵ مرداد',
    startMonth: 7, startDay: 16, endMonth: 8, endDay: 16,
    traits: 'خرچنگ (Karka) نماد احساسات عمیق، خانواده و شهود قوی است. متولدینش مراقب و وفادارند، اما گاهی خیلی حساس نسبت به نقد می‌شوند.',
  ),
  RashiSign(
    name: 'شیر',
    sanskritName: 'Simha',
    dateRangeLabel: '۱۶ مرداد تا ۱۵ شهریور',
    startMonth: 8, startDay: 17, endMonth: 9, endDay: 16,
    traits: 'شیر (Simha) نماد اعتماد به‌نفس، سخاوت و روحیه‌ی رهبری است. متولدینش دوست دارند دیده شوند و طبیعتاً جلب توجه می‌کنند.',
  ),
  RashiSign(
    name: 'خوشه',
    sanskritName: 'Kanya',
    dateRangeLabel: '۱۶ شهریور تا ۱۶ مهر',
    startMonth: 9, startDay: 17, endMonth: 10, endDay: 17,
    traits: 'خوشه (Kanya) نماد دقت، تحلیل و خدمت‌گزاری است. متولدینش منظم و وظیفه‌شناسند اما گاهی بیش از حد کمال‌گرا می‌شوند.',
  ),
  RashiSign(
    name: 'ترازو',
    sanskritName: 'Tula',
    dateRangeLabel: '۱۷ مهر تا ۱۵ آبان',
    startMonth: 10, startDay: 18, endMonth: 11, endDay: 16,
    traits: 'ترازو (Tula) نماد تعادل، هماهنگی و عدالت‌طلبی است. متولدینش دیپلمات و اجتماعی‌اند اما گاهی در تصمیم‌گیری طولانی معطل می‌مانند.',
  ),
  RashiSign(
    name: 'کژدم',
    sanskritName: 'Vrishchika',
    dateRangeLabel: '۱۶ آبان تا ۱۵ آذر',
    startMonth: 11, startDay: 17, endMonth: 12, endDay: 15,
    traits: 'کژدم (Vrishchika) نماد شدت احساسی، اراده‌ی آهنین و عمق روانی است. متولدینش پرشور و رازدارند و به‌سختی اعتماد می‌کنند.',
  ),
  RashiSign(
    name: 'کمان',
    sanskritName: 'Dhanu',
    dateRangeLabel: '۱۶ آذر تا ۱۴ دی',
    startMonth: 12, startDay: 16, endMonth: 1, endDay: 14,
    traits: 'کمان (Dhanu) نماد آزادی، جست‌وجوی حقیقت و خوش‌بینی است. متولدینش فلسفی و صادق‌اند اما گاهی صراحتشان دیگران را می‌رنجاند.',
  ),
  RashiSign(
    name: 'بز ماهی',
    sanskritName: 'Makara',
    dateRangeLabel: '۱۵ دی تا ۱۲ بهمن',
    startMonth: 1, startDay: 15, endMonth: 2, endDay: 12,
    traits: 'بز ماهی (Makara) نماد پشتکار، انضباط و جاه‌طلبی بلندمدت است. متولدینش هدفمند و مسئولیت‌پذیرند اما گاهی روی کار بیش از لذت زندگی تمرکز می‌کنند.',
  ),
  RashiSign(
    name: 'دلو',
    sanskritName: 'Kumbha',
    dateRangeLabel: '۱۳ بهمن تا ۱۱ اسفند',
    startMonth: 2, startDay: 13, endMonth: 3, endDay: 13,
    traits: 'دلو (Kumbha) نماد نوآوری، استقلال فکری و آرمان‌گرایی است. متولدینش خلاق و متفاوت‌اند اما گاهی از نظر احساسی فاصله می‌گیرند.',
  ),
  RashiSign(
    name: 'ماهی',
    sanskritName: 'Meena',
    dateRangeLabel: '۱۲ اسفند تا ۱۳ فروردین',
    startMonth: 3, startDay: 14, endMonth: 4, endDay: 13,
    traits: 'ماهی (Meena) نماد خیال‌پردازی، همدلی و عمق معنوی است. متولدینش هنرمند و مهربان‌اند اما گاهی در دنیای درونی خود گم می‌شوند.',
  ),
];

RashiSign getRashiSign(int month, int day) {
  for (final sign in rashiSigns) {
    if (sign.startMonth <= sign.endMonth) {
      if ((month == sign.startMonth && day >= sign.startDay) ||
          (month == sign.endMonth && day <= sign.endDay) ||
          (month > sign.startMonth && month < sign.endMonth)) {
        return sign;
      }
    } else {
      if ((month == sign.startMonth && day >= sign.startDay) ||
          (month == sign.endMonth && day <= sign.endDay) ||
          month > sign.startMonth ||
          month < sign.endMonth) {
        return sign;
      }
    }
  }
  return rashiSigns.last;
}
