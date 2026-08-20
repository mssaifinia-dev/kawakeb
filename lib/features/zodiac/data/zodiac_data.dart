class ZodiacSign {
  final String name;
  final String symbol;
  final String element;
  final String dateRangeLabel;
  final int startMonth;
  final int startDay;
  final int endMonth;
  final int endDay;
  final String traits;

  const ZodiacSign({
    required this.name,
    required this.symbol,
    required this.element,
    required this.dateRangeLabel,
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
    required this.traits,
  });
}

const List<ZodiacSign> zodiacSigns = [
  ZodiacSign(
    name: 'حمل',
    symbol: '♈',
    element: 'آتش',
    dateRangeLabel: '۲۱ فروردین تا ۲۰ اردیبهشت',
    startMonth: 3, startDay: 21, endMonth: 4, endDay: 19,
    traits:
        'حمل نماد شروع، شجاعت و انرژی خام است. متولدینش پرشور، مستقیم و رقابتی‌اند و از چالش‌های تازه استقبال می‌کنند. نقطه‌ضعف اصلی‌شان، کم‌طاقتی در برابر کندی و صبر است.',
  ),
  ZodiacSign(
    name: 'ثور',
    symbol: '♉',
    element: 'خاک',
    dateRangeLabel: '۲۱ اردیبهشت تا ۳۱ خرداد',
    startMonth: 4, startDay: 20, endMonth: 5, endDay: 20,
    traits:
        'ثور نماد ثبات، آرامش و لذت از زندگی مادی است. متولدینش صبور، وفادار و عملگرا هستند اما گاهی در برابر تغییر مقاومت نشان می‌دهند.',
  ),
  ZodiacSign(
    name: 'جوزا',
    symbol: '♊',
    element: 'هوا',
    dateRangeLabel: '۱ تا ۳۱ تیر',
    startMonth: 5, startDay: 21, endMonth: 6, endDay: 20,
    traits:
        'جوزا نماد ارتباط، کنجکاوی و ذهن سریع است. متولدینش اجتماعی، باهوش و چندبعدی‌اند اما گاهی در تصمیم‌گیری‌های بلندمدت دچار تردید می‌شوند.',
  ),
  ZodiacSign(
    name: 'سرطان',
    symbol: '♋',
    element: 'آب',
    dateRangeLabel: '۱ تا ۳۱ مرداد',
    startMonth: 6, startDay: 21, endMonth: 7, endDay: 22,
    traits:
        'سرطان نماد احساسات عمیق، خانواده و مراقبت است. متولدینش وفادار و شهودی‌اند، اما گاهی بیش از حد نگران گذشته یا حساس نسبت به انتقاد می‌شوند.',
  ),
  ZodiacSign(
    name: 'اسد',
    symbol: '♌',
    element: 'آتش',
    dateRangeLabel: '۱ تا ۳۱ شهریور',
    startMonth: 7, startDay: 23, endMonth: 8, endDay: 22,
    traits:
        'اسد نماد اعتماد به‌نفس، سخاوت و روحیه‌ی رهبری است. متولدینش دوست دارند بدرخشند و مورد توجه باشند، اما باید مراقب غرور بیش از حد باشند.',
  ),
  ZodiacSign(
    name: 'سنبله',
    symbol: '♍',
    element: 'خاک',
    dateRangeLabel: '۱ تا ۳۰ مهر',
    startMonth: 8, startDay: 23, endMonth: 9, endDay: 22,
    traits:
        'سنبله نماد دقت، تحلیل و کمال‌گرایی است. متولدینش منظم و قابل‌اعتمادند، اما گاهی بیش از حد سختگیر نسبت به خود و دیگران می‌شوند.',
  ),
  ZodiacSign(
    name: 'میزان',
    symbol: '♎',
    element: 'هوا',
    dateRangeLabel: '۱ تا ۳۰ آبان',
    startMonth: 9, startDay: 23, endMonth: 10, endDay: 22,
    traits:
        'میزان نماد تعادل، زیبایی و عدالت است. متولدینش دیپلمات و اجتماعی‌اند، اما گاهی در تصمیم‌گیری بین دو گزینه دچار تردید طولانی می‌شوند.',
  ),
  ZodiacSign(
    name: 'عقرب',
    symbol: '♏',
    element: 'آب',
    dateRangeLabel: '۱ تا ۲۹ آذر',
    startMonth: 10, startDay: 23, endMonth: 11, endDay: 21,
    traits:
        'عقرب نماد شدت، عمق احساسی و قدرت اراده است. متولدینش راز‌دار و پرشور هستند، اما گاهی در برابر اعتماد کردن به دیگران مقاومت نشان می‌دهند.',
  ),
  ZodiacSign(
    name: 'قوس',
    symbol: '♐',
    element: 'آتش',
    dateRangeLabel: '۳۰ آذر تا ۲۹ دی',
    startMonth: 11, startDay: 22, endMonth: 12, endDay: 21,
    traits:
        'قوس نماد آزادی، ماجراجویی و خوش‌بینی است. متولدینش صادق و فلسفی‌اند، اما گاهی صراحتشان باعث رنجش دیگران می‌شود.',
  ),
  ZodiacSign(
    name: 'جدی',
    symbol: '♑',
    element: 'خاک',
    dateRangeLabel: '۳۰ دی تا ۲۸ بهمن',
    startMonth: 12, startDay: 22, endMonth: 1, endDay: 19,
    traits:
        'جدی نماد پشتکار، مسئولیت‌پذیری و جاه‌طلبی است. متولدینش منظم و هدفمندند، اما گاهی بیش از حد روی کار تمرکز می‌کنند و از لذت لحظه غافل می‌شوند.',
  ),
  ZodiacSign(
    name: 'دلو',
    symbol: '♒',
    element: 'هوا',
    dateRangeLabel: '۲۹ بهمن تا ۲۹ اسفند',
    startMonth: 1, startDay: 20, endMonth: 2, endDay: 18,
    traits:
        'دلو نماد نوآوری، استقلال فکری و آرمان‌گرایی اجتماعی است. متولدینش خلاق و متفاوت فکر می‌کنند، اما گاهی از نظر احساسی فاصله می‌گیرند.',
  ),
  ZodiacSign(
    name: 'حوت',
    symbol: '♓',
    element: 'آب',
    dateRangeLabel: '۱ تا ۲۰ فروردین',
    startMonth: 2, startDay: 19, endMonth: 3, endDay: 20,
    traits:
        'حوت نماد خیال‌پردازی، همدلی و عمق معنوی است. متولدینش هنرمند و مهربانند، اما گاهی در دنیای خیال خود گم می‌شوند و از واقعیت فاصله می‌گیرند.',
  ),
];

ZodiacSign getZodiacSign(int month, int day) {
  for (final sign in zodiacSigns) {
    if (sign.startMonth <= sign.endMonth) {
      if ((month == sign.startMonth && day >= sign.startDay) ||
          (month == sign.endMonth && day <= sign.endDay) ||
          (month > sign.startMonth && month < sign.endMonth)) {
        return sign;
      }
    } else {
      // wraps around year end (جدی)
      if ((month == sign.startMonth && day >= sign.startDay) ||
          (month == sign.endMonth && day <= sign.endDay) ||
          month > sign.startMonth ||
          month < sign.endMonth) {
        return sign;
      }
    }
  }
  return zodiacSigns.last;
}
