class ChineseZodiacSign {
  final String name;
  final String emoji;
  final String traits;

  const ChineseZodiacSign({
    required this.name,
    required this.emoji,
    required this.traits,
  });
}

// Order matches (year % 12) where 2020 -> رت (Rat) as reference: 2020 % 12 == 8
const List<ChineseZodiacSign> chineseZodiacSigns = [
  ChineseZodiacSign(
    name: 'میمون',
    emoji: '🐒',
    traits: 'باهوش، بازیگوش و مبتکر. متولدین سال میمون در حل مسئله خلاق‌اند و از یکنواختی خسته می‌شوند.',
  ),
  ChineseZodiacSign(
    name: 'خروس',
    emoji: '🐓',
    traits: 'دقیق، پرکار و مغرور به توانایی‌های خود. متولدین سال خروس نظم‌طلب‌اند و دوست دارند دیده شوند.',
  ),
  ChineseZodiacSign(
    name: 'سگ',
    emoji: '🐕',
    traits: 'وفادار، صادق و عدالت‌طلب. متولدین سال سگ دوستانی قابل‌اعتمادند اما گاهی زیاد نگران می‌شوند.',
  ),
  ChineseZodiacSign(
    name: 'خوک',
    emoji: '🐖',
    traits: 'مهربان، سخاوتمند و صلح‌طلب. متولدین سال خوک از زندگی ساده و لذت‌های کوچک خوشحال می‌شوند.',
  ),
  ChineseZodiacSign(
    name: 'موش',
    emoji: '🐀',
    traits: 'زیرک، سازگار و پرانرژی. متولدین سال موش فرصت‌ها را سریع می‌بینند و در بحران خوب عمل می‌کنند.',
  ),
  ChineseZodiacSign(
    name: 'گاو',
    emoji: '🐂',
    traits: 'صبور، قابل‌اعتماد و سخت‌کوش. متولدین سال گاو آرام پیش می‌روند اما در تصمیماتشان محکم‌اند.',
  ),
  ChineseZodiacSign(
    name: 'ببر',
    emoji: '🐅',
    traits: 'شجاع، رقابتی و کاریزماتیک. متولدین سال ببر ریسک‌پذیرند و طبیعتاً جلب توجه می‌کنند.',
  ),
  ChineseZodiacSign(
    name: 'خرگوش',
    emoji: '🐇',
    traits: 'ملایم، دیپلمات و ظریف‌طبع. متولدین سال خرگوش از تنش گریزانند و محیط آرام را ترجیح می‌دهند.',
  ),
  ChineseZodiacSign(
    name: 'اژدها',
    emoji: '🐉',
    traits: 'قدرتمند، بلندپرواز و کاریزماتیک. متولدین سال اژدها طبیعتاً رهبرند و از چالش‌های بزرگ نمی‌ترسند.',
  ),
  ChineseZodiacSign(
    name: 'مار',
    emoji: '🐍',
    traits: 'حکیم، رازدار و شهودی. متولدین سال مار عمیق فکر می‌کنند و کمتر احساسات خود را آشکار می‌کنند.',
  ),
  ChineseZodiacSign(
    name: 'اسب',
    emoji: '🐎',
    traits: 'آزاد، پرانرژی و اجتماعی. متولدین سال اسب عاشق حرکت و ماجراجویی‌اند و از محدودیت گریزانند.',
  ),
  ChineseZodiacSign(
    name: 'بز',
    emoji: '🐐',
    traits: 'هنرمند، مهربان و آرام. متولدین سال بز حساسیت هنری بالایی دارند و محیط‌های هماهنگ را دوست دارند.',
  ),
];

ChineseZodiacSign getChineseZodiac(int year) {
  final index = ((year - 2020) % 12 + 12) % 12;
  return chineseZodiacSigns[index];
}
