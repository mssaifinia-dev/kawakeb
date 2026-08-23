import '../../abjad/data/abjad_data.dart';

class JafrReading {
  final String title;
  final String message;

  final String dominantEnergy;
  final String personality;
  final String love;
  final String finance;
  final String career;
  final String obstacles;
  final String opportunities;
  final String spiritual;
  final String timing;
  final String finalMessage;

  final int nameValue;
  final int motherValue;
  final int combinedValue;
  final int rootNumber;

  const JafrReading({
    required this.title,
    required this.message,
    required this.dominantEnergy,
    required this.personality,
    required this.love,
    required this.finance,
    required this.career,
    required this.obstacles,
    required this.opportunities,
    required this.spiritual,
    required this.timing,
    required this.finalMessage,
    required this.nameValue,
    required this.motherValue,
    required this.combinedValue,
    required this.rootNumber,
  });
}

const List<String> _energies = [
  'آغاز و حرکت',
  'صبر و پایداری',
  'گشایش و ارتباط',
  'ثبات و ساختن',
  'تغییر و تحول',
  'تعادل و همکاری',
  'درون‌نگری و کشف',
  'قدرت و نتیجه‌گیری',
  'پایان یک چرخه و آغاز مرحله‌ای تازه',
];

const List<String> _personalities = [
  'در این دوره روحیه‌ای جست‌وجوگر و تصمیم‌ساز داری. بهتر است میان هیجان لحظه‌ای و تصمیم نهایی فاصله بگذاری.',
  'قدرت اصلی تو در این دوره صبر و توان ادامه دادن است. نتیجه بیشتر از سرعت، به استمرار تو وابسته است.',
  'ذهن و زبان تو نقش پررنگی پیدا می‌کنند. گفت‌وگویی درست می‌تواند مسیری را باز کند که مدت‌ها بسته بوده.',
  'این دوره بیشتر برای ساختن پایه‌های محکم مناسب است. کارهای آرام و پیوسته نتیجه‌ای ماندگارتر خواهند داشت.',
  'نشانه‌های تغییر در اطرافت بیشتر شده‌اند. مقاومت بی‌دلیل در برابر تغییر می‌تواند انرژی تو را هدر دهد.',
  'همکاری با یک فرد مناسب می‌تواند نتیجه را بهتر کند. لازم نیست همه چیز را به‌تنهایی پیش ببری.',
  'این دوره بیشتر تو را به شناخت عمیق‌تر خودت دعوت می‌کند. پاسخ بعضی پرسش‌ها بیرون از تو نیست.',
  'قدرت تصمیم‌گیری و مدیریت شرایط در تو پررنگ‌تر می‌شود. از این قدرت برای کنترل، نه فشار آوردن، استفاده کن.',
  'یک چرخه در حال بسته شدن است. پایان یک مرحله الزاماً شکست نیست و می‌تواند مقدمه شروعی مناسب‌تر باشد.',
];

const List<String> _loveReadings = [
  'در روابط، گفت‌وگوی صادقانه می‌تواند سوءتفاهمی قدیمی را کم‌رنگ کند.',
  'احساسات در این دوره نیازمند زمان هستند. تصمیم عجولانه درباره یک رابطه توصیه نمی‌شود.',
  'نشانه‌ای از نزدیک‌تر شدن یک رابطه مهم دیده می‌شود؛ اما کیفیت رفتار دو طرف تعیین‌کننده است.',
  'ممکن است موضوعی از گذشته دوباره در ذهن یا زندگی عاطفی‌ات ظاهر شود.',
  'اگر در رابطه هستی، زمان مناسبی برای روشن کردن انتظارات و مرزهاست.',
  'اگر مجردی، آشنایی تازه ممکن است ابتدا ساده به‌نظر برسد اما ارزش شناخت بیشتر را دارد.',
  'این دوره بیشتر درباره شناخت ارزش خودت در رابطه است تا پیدا کردن پاسخ از طرف مقابل.',
  'یک رابطه می‌تواند وارد مرحله‌ای جدی‌تر شود، به شرط آنکه اعتماد به‌صورت دوطرفه ساخته شود.',
  'بهتر است میان دلبستگی و تصمیم منطقی تعادل ایجاد کنی؛ احساس به‌تنهایی کافی نیست.',
];

const List<String> _financeReadings = [
  'در امور مالی، گشایش بیشتر از مسیر یک فرصت کوچک اما قابل‌توسعه دیده می‌شود.',
  'این دوره برای مدیریت هزینه‌ها و جلوگیری از تصمیم‌های هیجانی مناسب‌تر است.',
  'ممکن است پیشنهادی مالی دریافت کنی که نیازمند بررسی دقیق جزئیات باشد.',
  'نتیجه مالی بیشتر به استمرار تلاش فعلی وابسته است تا شانس ناگهانی.',
  'یک تغییر در روش درآمد یا مدیریت سرمایه می‌تواند در آینده اثرگذار باشد.',
  'بهتر است قبل از هر تعهد مالی، شرایط و پیامدهای آن را دوباره بررسی کنی.',
  'نشانه‌های ثبات مالی بیشتر از سود سریع دیده می‌شوند.',
  'فرصت مالی ممکن است از مسیر فردی دیگر، همکاری یا ارتباط تازه ایجاد شود.',
  'از خرج کردن برای جبران فشار روحی پرهیز کن؛ حفظ تعادل مالی در این دوره مهم است.',
];

const List<String> _careerReadings = [
  'در مسیر کاری، زمان مناسبی برای شروع کاری است که مدت‌ها به تعویق افتاده.',
  'تلاش فعلی ممکن است هنوز نتیجه کامل خود را نشان نداده باشد؛ ادامه دادن اهمیت دارد.',
  'یک ارتباط کاری تازه می‌تواند در آینده نقش مهمی پیدا کند.',
  'بازنگری در روش انجام کار می‌تواند بیشتر از افزایش ساعت کار نتیجه بدهد.',
  'تغییر شغلی یا مسئولیت تازه ممکن است مطرح شود؛ قبل از تصمیم، ثبات آن را بررسی کن.',
  'توانایی تو در مدیریت و تصمیم‌گیری می‌تواند بیشتر دیده شود.',
  'یک فرصت آموزشی یا یادگیری مهارت تازه ممکن است ارزش بیشتری از یک سود کوتاه‌مدت داشته باشد.',
  'بهتر است در محیط کار از ورود به حاشیه و اختلاف‌های غیرضروری دور بمانی.',
  'دوره‌ای برای تثبیت موقعیت و برداشت نتیجه تلاش‌های قبلی دیده می‌شود.',
];

const List<String> _obstacles = [
  'مهم‌ترین مانع، عجله برای رسیدن به نتیجه است.',
  'نگرانی بیش از اندازه ممکن است تصمیم‌گیری را دشوار کند.',
  'وابستگی به نظر دیگران می‌تواند مسیر اصلی را برایت مبهم کند.',
  'موضوعی قدیمی هنوز بخشی از انرژی ذهنی تو را مصرف می‌کند.',
  'اعتماد زودهنگام به یک وعده می‌تواند دردسرساز شود.',
  'پراکنده‌کاری مانع استفاده کامل از توانایی‌هایت می‌شود.',
  'گاهی لازم است قبل از حرکت، اطلاعات بیشتری جمع کنی.',
  'ترس از تغییر ممکن است تو را در موقعیتی نگه دارد که دیگر مناسب تو نیست.',
  'فشار برای کنترل همه چیز می‌تواند باعث خستگی و تصمیم اشتباه شود.',
];

const List<String> _opportunities = [
  'فرصت اصلی از یک ارتباط یا گفت‌وگوی مهم می‌تواند شکل بگیرد.',
  'کاری که کوچک به‌نظر می‌رسد قابلیت تبدیل شدن به مسیر بزرگ‌تری را دارد.',
  'یک تصمیم قدیمی را می‌توان با شرایط امروز دوباره بررسی کرد.',
  'یادگیری مهارتی تازه می‌تواند ارزش بیشتری از یک فرصت فوری داشته باشد.',
  'ممکن است فردی باتجربه در زمان مناسب راهنمایی مهمی ارائه کند.',
  'یک تغییر کوچک در برنامه روزانه می‌تواند اثر بزرگی در ادامه مسیر داشته باشد.',
  'فرصتی برای جبران یا اصلاح یک موضوع قدیمی وجود دارد.',
  'راه‌حل مسئله‌ای که بن‌بست به‌نظر می‌رسید ممکن است از مسیر غیرمنتظره‌ای پیدا شود.',
  'زمان مناسبی برای تبدیل یک ایده قدیمی به اقدام عملی است.',
];

const List<String> _spiritualReadings = [
  'این دوره بیشتر از پیش تو را به آرامش، سکوت و شناخت درونی دعوت می‌کند.',
  'نشانه اصلی این مرحله، یافتن تعادل میان خواسته‌های بیرونی و آرامش درونی است.',
  'به ندای درونت توجه کن، اما تصمیم‌های مهم را با عقل و بررسی همراه کن.',
  'رها کردن یک دلخوری قدیمی می‌تواند انرژی زیادی برایت آزاد کند.',
  'این دوره برای بازنگری در ارزش‌ها و اولویت‌های شخصی مناسب است.',
  'گاهی پاسخ یک پرسش مهم با فاصله گرفتن از هیاهوی روزمره روشن‌تر می‌شود.',
  'قدردانی از داشته‌های فعلی می‌تواند نگاهت به مسیر آینده را تغییر دهد.',
  'این مرحله بیشتر دوره شناخت است تا پیش‌بینی قطعی آینده.',
  'آرامش درونی می‌تواند بهترین راهنمای تو برای انتخاب‌های پیش‌رو باشد.',
];

const List<String> _timings = [
  'نشانه‌ها بیشتر به یک بازه نزدیک اشاره دارند؛ اما نتیجه به اقدام خودت وابسته است.',
  'موضوع اصلی این خوانش احتمالاً به‌صورت تدریجی و نه ناگهانی آشکار می‌شود.',
  'در هفته‌های پیش‌رو نشانه‌های اولیه تغییر می‌توانند ظاهر شوند.',
  'برای نتیجه نهایی، کمی صبر و پیگیری لازم است.',
  'یک تصمیم یا خبر ممکن است زودتر از چیزی که انتظار داری مطرح شود.',
  'این دوره بیشتر زمان آماده‌سازی است و نتیجه کامل می‌تواند دیرتر ظاهر شود.',
  'نشانه‌های تغییر در چند مرحله آشکار می‌شوند، نه در یک اتفاق واحد.',
  'زمان دقیق از محاسبه قابل تعیین قطعی نیست؛ اما دوره فعلی برای حرکت و تصمیم‌گیری مناسب است.',
  'پایان یک مرحله نزدیک‌تر از چیزی است که تصور می‌کنی.',
];

/// محاسبه خوانش جفر بر اساس نام شخص و نام مادر.
/// این بخش یک مدل تفسیری/نمادین است و نباید به‌عنوان پیش‌بینی قطعی آینده در نظر گرفته شود.
JafrReading calculateJafrReading(String name, String motherName) {
  final nameValue = calculateAbjadValue(name);
  final motherValue = calculateAbjadValue(motherName);

  // ترکیب سنتیِ تفسیری نام و نام مادر.
  final combinedValue = nameValue + (motherValue * 2);

  // کاهش عدد به عدد ریشه‌ای ۱ تا ۹.
  int rootNumber = combinedValue.abs();

  while (rootNumber > 9) {
    rootNumber = rootNumber
        .toString()
        .split('')
        .map(int.parse)
        .fold(0, (sum, digit) => sum + digit);
  }

  if (rootNumber == 0) {
    rootNumber = 9;
  }

  final energyIndex = (rootNumber - 1) % _energies.length;

  final personalityIndex =
      (combinedValue.abs() + nameValue) % _personalities.length;

  final loveIndex =
      (combinedValue.abs() + motherValue) % _loveReadings.length;

  final financeIndex =
      (nameValue + rootNumber * 3) % _financeReadings.length;

  final careerIndex =
      (motherValue + rootNumber * 5) % _careerReadings.length;

  final obstacleIndex =
      (combinedValue.abs() + rootNumber * 7) % _obstacles.length;

  final opportunityIndex =
      (nameValue + motherValue + rootNumber) % _opportunities.length;

  final spiritualIndex =
      (combinedValue.abs() + rootNumber * 11) % _spiritualReadings.length;

  final timingIndex =
      (combinedValue.abs() + rootNumber * 13) % _timings.length;

  final title = _buildTitle(rootNumber);

  final message = _buildMainMessage(
    name,
    rootNumber,
    _energies[energyIndex],
  );

  final finalMessage = _buildFinalMessage(
    rootNumber,
    _opportunities[opportunityIndex],
  );

  return JafrReading(
    title: title,
    message: message,

    dominantEnergy: _energies[energyIndex],
    personality: _personalities[personalityIndex],
    love: _loveReadings[loveIndex],
    finance: _financeReadings[financeIndex],
    career: _careerReadings[careerIndex],
    obstacles: _obstacles[obstacleIndex],
    opportunities: _opportunities[opportunityIndex],
    spiritual: _spiritualReadings[spiritualIndex],
    timing: _timings[timingIndex],
    finalMessage: finalMessage,

    nameValue: nameValue,
    motherValue: motherValue,
    combinedValue: combinedValue,
    rootNumber: rootNumber,
  );
}

String _buildTitle(int rootNumber) {
  const titles = [
    'آغاز یک چرخه تازه',
    'دوره‌ی صبر و تثبیت',
    'گشایش از مسیر ارتباط',
    'دوره‌ی ساختن و استحکام',
    'زمان تغییر و تحول',
    'دوره‌ی تعادل و پیوند',
    'زمان کشف و درون‌نگری',
    'دوره‌ی قدرت و نتیجه',
    'پایان یک چرخه و آغاز تازه',
  ];

  return titles[rootNumber - 1];
}

String _buildMainMessage(
  String name,
  int rootNumber,
  String energy,
) {
  return 'برای $name، عدد ریشه‌ای این خوانش $rootNumber است. '
      'انرژی غالب این دوره «$energy» دیده می‌شود. '
      'این خوانش نمادین نشان می‌دهد که در مرحله‌ای قرار داری که شناخت شرایط، '
      'انتخاب درست و نحوه‌ی واکنش خودت نقش مهمی در نتیجه خواهد داشت.';
}

String _buildFinalMessage(
  int rootNumber,
  String opportunity,
) {
  return 'جمع‌بندی خوانش جفر با عدد ریشه‌ای $rootNumber: '
      '$opportunity '
      'این نتیجه یک تفسیر نمادین بر پایه محاسبات حروف است و نه پیش‌بینی قطعی آینده. '
      'ارزش اصلی آن در استفاده برای تأمل و شناخت بهتر شرایط فعلی است.';
}