/// جدول ارزش حروف ابجد (ابجد کبیر، رایج در فرهنگ فارسی/عربی)
const Map<String, int> abjadValues = {
  'ا': 1, 'آ': 1, 'ب': 2, 'پ': 2, 'ج': 3, 'چ': 3, 'د': 4,
  'ه': 5, 'ة': 5, 'و': 6, 'ز': 7, 'ژ': 7, 'ح': 8, 'ط': 9,
  'ی': 10, 'ي': 10, 'ک': 20, 'گ': 20, 'ك': 20, 'ل': 30, 'م': 40,
  'ن': 50, 'س': 60, 'ع': 70, 'ف': 80, 'ص': 90, 'ق': 100,
  'ر': 200, 'ش': 300, 'ت': 400, 'ث': 500, 'خ': 600,
  'ذ': 700, 'ض': 800, 'ظ': 900, 'غ': 1000,
};

int calculateAbjadValue(String name) {
  int total = 0;
  for (final char in name.replaceAll(' ', '').split('')) {
    total += abjadValues[char] ?? 0;
  }
  return total;
}

class AsmaEntry {
  final String arabic;
  final String meaning;
  final int abjadValue;

  const AsmaEntry({
    required this.arabic,
    required this.meaning,
    required this.abjadValue,
  });
}

/// جدول اسماء الحسنی (۹۹ نام نیکوی خداوند) به همراه عدد ابجد هر اسم.
/// دو نام بدون عدد ابجد ثبت‌شده (ذوالجلال‌والاکرام، الصبور) و یک نام با
/// بار معنایی نامناسب برای ذکر («الضار») از این فهرست کنار گذاشته شده‌اند.
const List<AsmaEntry> asmaUlHusna = [
  AsmaEntry(arabic: 'یا رحمن', meaning: 'بخشنده', abjadValue: 298),
  AsmaEntry(arabic: 'یا رحیم', meaning: 'مهربان', abjadValue: 258),
  AsmaEntry(arabic: 'یا ملک', meaning: 'پادشاه هستی', abjadValue: 90),
  AsmaEntry(arabic: 'یا قدوس', meaning: 'پاک و منزه', abjadValue: 70),
  AsmaEntry(arabic: 'یا سلام', meaning: 'پاک و سلامتی‌بخش', abjadValue: 131),
  AsmaEntry(arabic: 'یا مؤمن', meaning: 'اطمینان‌دهنده', abjadValue: 136),
  AsmaEntry(arabic: 'یا مهیمن', meaning: 'نگهدارنده', abjadValue: 145),
  AsmaEntry(arabic: 'یا عزیز', meaning: 'باشکوه و عزتمند', abjadValue: 94),
  AsmaEntry(arabic: 'یا جبار', meaning: 'توانگر و اصلاح‌گر', abjadValue: 206),
  AsmaEntry(arabic: 'یا متکبر', meaning: 'بسیار بزرگ', abjadValue: 662),
  AsmaEntry(arabic: 'یا خالق', meaning: 'آفریننده', abjadValue: 731),
  AsmaEntry(arabic: 'یا بارئ', meaning: 'پدیدآورنده‌ی بی‌نقص', abjadValue: 213),
  AsmaEntry(arabic: 'یا مصور', meaning: 'صورتگر و نگارگر', abjadValue: 336),
  AsmaEntry(arabic: 'یا غفار', meaning: 'همیشه بخشاینده', abjadValue: 1281),
  AsmaEntry(arabic: 'یا قهار', meaning: 'چیره بر همه چیز', abjadValue: 306),
  AsmaEntry(arabic: 'یا وهاب', meaning: 'نیک‌بخشاینده', abjadValue: 14),
  AsmaEntry(arabic: 'یا رزاق', meaning: 'همیشه روزی‌دهنده', abjadValue: 308),
  AsmaEntry(arabic: 'یا فتاح', meaning: 'گشاینده‌ی درها', abjadValue: 489),
  AsmaEntry(arabic: 'یا علیم', meaning: 'داناترین', abjadValue: 150),
  AsmaEntry(arabic: 'یا باسط', meaning: 'گستراننده‌ی روزی', abjadValue: 72),
  AsmaEntry(arabic: 'یا رافع', meaning: 'بالابرنده‌ی مقام‌ها', abjadValue: 351),
  AsmaEntry(arabic: 'یا معز', meaning: 'عزت‌بخش', abjadValue: 117),
  AsmaEntry(arabic: 'یا سمیع', meaning: 'شنواترین', abjadValue: 180),
  AsmaEntry(arabic: 'یا بصیر', meaning: 'بیناترین', abjadValue: 302),
  AsmaEntry(arabic: 'یا حکم', meaning: 'دادگر', abjadValue: 68),
  AsmaEntry(arabic: 'یا عدل', meaning: 'بی‌نهایت عادل', abjadValue: 114),
  AsmaEntry(arabic: 'یا لطیف', meaning: 'لطف‌کننده به بندگان', abjadValue: 129),
  AsmaEntry(arabic: 'یا خبیر', meaning: 'آگاه‌ترین', abjadValue: 812),
  AsmaEntry(arabic: 'یا حلیم', meaning: 'بسیار بردبار', abjadValue: 88),
  AsmaEntry(arabic: 'یا عظیم', meaning: 'بی‌انتها و بزرگ', abjadValue: 1020),
  AsmaEntry(arabic: 'یا غفور', meaning: 'بسیار بخشاینده', abjadValue: 1286),
  AsmaEntry(arabic: 'یا شکور', meaning: 'قدردان کوچک‌ترین کار نیک', abjadValue: 526),
  AsmaEntry(arabic: 'یا عالی', meaning: 'بلندمرتبه', abjadValue: 110),
  AsmaEntry(arabic: 'یا کبیر', meaning: 'بزرگ‌ترین', abjadValue: 232),
  AsmaEntry(arabic: 'یا حفیظ', meaning: 'نگهدارنده و محافظ', abjadValue: 998),
  AsmaEntry(arabic: 'یا مقیت', meaning: 'خوراک‌دهنده', abjadValue: 550),
  AsmaEntry(arabic: 'یا حسیب', meaning: 'حسابگر دقیق', abjadValue: 80),
  AsmaEntry(arabic: 'یا جلیل', meaning: 'بسیار گرانقدر', abjadValue: 73),
  AsmaEntry(arabic: 'یا کریم', meaning: 'بسیار بخشنده', abjadValue: 270),
  AsmaEntry(arabic: 'یا رقیب', meaning: 'نگهبان و آماده', abjadValue: 312),
  AsmaEntry(arabic: 'یا مجیب', meaning: 'پاسخگوی دعا', abjadValue: 55),
  AsmaEntry(arabic: 'یا واسع', meaning: 'گسترده و پهناور', abjadValue: 137),
  AsmaEntry(arabic: 'یا حکیم', meaning: 'فرزانه و خردمند', abjadValue: 78),
  AsmaEntry(arabic: 'یا ودود', meaning: 'دوست و محبت‌بخش', abjadValue: 20),
  AsmaEntry(arabic: 'یا مجید', meaning: 'شایسته‌ی ستایش', abjadValue: 57),
  AsmaEntry(arabic: 'یا باعث', meaning: 'برانگیزاننده', abjadValue: 573),
  AsmaEntry(arabic: 'یا شهید', meaning: 'گواه و بیننده', abjadValue: 319),
  AsmaEntry(arabic: 'یا حق', meaning: 'راست و درست', abjadValue: 108),
  AsmaEntry(arabic: 'یا وکیل', meaning: 'عهده‌دار امور بندگان', abjadValue: 66),
  AsmaEntry(arabic: 'یا قوی', meaning: 'پرزور', abjadValue: 116),
  AsmaEntry(arabic: 'یا متین', meaning: 'استوار و پاینده', abjadValue: 500),
  AsmaEntry(arabic: 'یا ولی', meaning: 'دوست و نگهبان', abjadValue: 46),
  AsmaEntry(arabic: 'یا حمید', meaning: 'ستوده', abjadValue: 62),
  AsmaEntry(arabic: 'یا محصی', meaning: 'شمارنده‌ی دقیق', abjadValue: 148),
  AsmaEntry(arabic: 'یا مبدئ', meaning: 'نخستین آفریننده', abjadValue: 56),
  AsmaEntry(arabic: 'یا معید', meaning: 'بازگرداننده', abjadValue: 124),
  AsmaEntry(arabic: 'یا محیی', meaning: 'زندگی‌بخش', abjadValue: 68),
  AsmaEntry(arabic: 'یا حی', meaning: 'همیشه زنده', abjadValue: 18),
  AsmaEntry(arabic: 'یا قیوم', meaning: 'پاینده و قائم به ذات', abjadValue: 146),
  AsmaEntry(arabic: 'یا واجد', meaning: 'یابنده‌ی هر آنچه بخواهد', abjadValue: 14),
  AsmaEntry(arabic: 'یا ماجد', meaning: 'بزرگوار', abjadValue: 48),
  AsmaEntry(arabic: 'یا واحد', meaning: 'یکتای بی‌همتا', abjadValue: 19),
  AsmaEntry(arabic: 'یا احد', meaning: 'یگانه', abjadValue: 13),
  AsmaEntry(arabic: 'یا صمد', meaning: 'بی‌نیاز', abjadValue: 134),
  AsmaEntry(arabic: 'یا قادر', meaning: 'توانا', abjadValue: 305),
  AsmaEntry(arabic: 'یا مقتدر', meaning: 'دارای قدرت مطلق', abjadValue: 744),
  AsmaEntry(arabic: 'یا مقدم', meaning: 'پیش‌برنده', abjadValue: 184),
  AsmaEntry(arabic: 'یا مؤخر', meaning: 'واپس‌نهنده به‌جای خود', abjadValue: 846),
  AsmaEntry(arabic: 'یا اول', meaning: 'آغاز هستی', abjadValue: 37),
  AsmaEntry(arabic: 'یا آخر', meaning: 'پایان هستی', abjadValue: 801),
  AsmaEntry(arabic: 'یا ظاهر', meaning: 'آشکار و همیشه پیروز', abjadValue: 1106),
  AsmaEntry(arabic: 'یا باطن', meaning: 'پنهان و همه‌دربرگیرنده', abjadValue: 62),
  AsmaEntry(arabic: 'یا والی', meaning: 'یگانه سرپرست', abjadValue: 47),
  AsmaEntry(arabic: 'یا متعالی', meaning: 'برتر از هر وصف', abjadValue: 551),
  AsmaEntry(arabic: 'یا بر', meaning: 'نیکوترین', abjadValue: 202),
  AsmaEntry(arabic: 'یا تواب', meaning: 'همیشه توبه‌پذیر', abjadValue: 409),
  AsmaEntry(arabic: 'یا منتقم', meaning: 'دادگر در برابر ستم', abjadValue: 630),
  AsmaEntry(arabic: 'یا عفو', meaning: 'گذرنده از گناهان', abjadValue: 156),
  AsmaEntry(arabic: 'یا رؤوف', meaning: 'بسیار دلسوز و مهربان', abjadValue: 286),
  AsmaEntry(arabic: 'یا مالک‌الملک', meaning: 'فرمانروای جهان', abjadValue: 212),
  AsmaEntry(arabic: 'یا مقسط', meaning: 'عادل در تقسیم', abjadValue: 209),
  AsmaEntry(arabic: 'یا جامع', meaning: 'گردآورنده', abjadValue: 114),
  AsmaEntry(arabic: 'یا غنی', meaning: 'توانگر و بی‌نیاز', abjadValue: 1060),
  AsmaEntry(arabic: 'یا مغنی', meaning: 'بی‌نیازکننده‌ی دیگران', abjadValue: 1100),
  AsmaEntry(arabic: 'یا مانع', meaning: 'بازدارنده از آسیب', abjadValue: 161),
  AsmaEntry(arabic: 'یا نافع', meaning: 'سودمند', abjadValue: 201),
  AsmaEntry(arabic: 'یا نور', meaning: 'روشنی‌بخش', abjadValue: 256),
  AsmaEntry(arabic: 'یا هادی', meaning: 'راهنمای دل‌ها', abjadValue: 20),
  AsmaEntry(arabic: 'یا بدیع', meaning: 'آفریننده‌ی بی‌مانند', abjadValue: 86),
  AsmaEntry(arabic: 'یا باقی', meaning: 'ماندگار و تغییرناپذیر', abjadValue: 113),
  AsmaEntry(arabic: 'یا وارث', meaning: 'مالک نهایی هر چیز', abjadValue: 707),
  AsmaEntry(arabic: 'یا رشید', meaning: 'راهنما و آموزگار بی‌خطا', abjadValue: 514),
];

class AbjadResult {
  final int totalValue;
  final AsmaEntry matchedName;
  final int recommendedCount;

  const AbjadResult({
    required this.totalValue,
    required this.matchedName,
    required this.recommendedCount,
  });
}

/// طبق روش رایج در منابع سنتی: عدد ابجد نام محاسبه می‌شود و نزدیک‌ترین
/// اسم از اسماء الحسنی (از نظر عدد ابجد) به‌عنوان ذکر مناسب انتخاب می‌شود؛
/// تعداد ذکر هم برابر با عدد ابجد همان اسم است.
AbjadResult calculateAbjadResult(String name) {
  final total = calculateAbjadValue(name);

  AsmaEntry closest = asmaUlHusna.first;
  int minDiff = (asmaUlHusna.first.abjadValue - total).abs();

  for (final entry in asmaUlHusna) {
    final diff = (entry.abjadValue - total).abs();
    if (diff < minDiff) {
      minDiff = diff;
      closest = entry;
    }
  }

  return AbjadResult(
    totalValue: total,
    matchedName: closest,
    recommendedCount: closest.abjadValue,
  );
}
