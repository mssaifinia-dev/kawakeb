import 'numerology_data.dart';

class NineYearCycle {
  final int blockIndex;
  final int startAge;
  final int endAge;
  final int cycleNumber;
  final String title;
  final String lifeLesson;
  final List<String> strengths;
  final List<String> challenges;
  final List<String> opportunities;
  final String goodForStartingWork;
  final String goodForChangingJob;
  final String goodForLearning;
  final String goodForRelationships;

  const NineYearCycle({
    required this.blockIndex,
    required this.startAge,
    required this.endAge,
    required this.cycleNumber,
    required this.title,
    required this.lifeLesson,
    required this.strengths,
    required this.challenges,
    required this.opportunities,
    required this.goodForStartingWork,
    required this.goodForChangingJob,
    required this.goodForLearning,
    required this.goodForRelationships,
  });
}

/// راهنمای زمان‌بندی هرکدام از اعداد ۱ تا ۹ برای چهار نوع تصمیم مهم زندگی —
/// این جدول کوچک برای همه‌ی چرخه‌های ۹ساله (که همیشه بین اعداد ۱ تا ۹ در
/// گردش‌اند) استفاده می‌شود.
const Map<int, Map<String, String>> _timingAdvice = {
  1: {
    'startWork': 'بله — بهترین زمان برای شروع کاری مستقل و تازه',
    'changeJob': 'بله — انرژی این دوره از تغییر حمایت می‌کند',
    'learning': 'متوسط — یادگیری در کنار عمل بهتر جواب می‌دهد',
    'relationships': 'زمان کمتر مناسبی؛ تمرکز بیشتر روی خود توست',
  },
  2: {
    'startWork': 'محتاط باش — بهتر است با شراکت شروع کنی، نه تنها',
    'changeJob': 'زمان کمتر مناسبی؛ صبر کن تا شرایط روشن‌تر شود',
    'learning': 'خوب — یادگیری در کنار دیگران نتیجه‌ی بهتری دارد',
    'relationships': 'بله — یکی از بهترین دوره‌ها برای تعمیق روابط',
  },
  3: {
    'startWork': 'خوب — به‌خصوص در حوزه‌های خلاقانه',
    'changeJob': 'خوب — اگر مسیر تازه خلاقانه‌تر باشد',
    'learning': 'بله — یادگیری مهارت‌های بیانی و هنری در اولویت است',
    'relationships': 'خوب — دوره‌ی خوبی برای آشنایی‌های تازه',
  },
  4: {
    'startWork': 'بله — به‌خصوص کاری که نیاز به ساختار دارد',
    'changeJob': 'محتاط باش — تغییر عجولانه توصیه نمی‌شود',
    'learning': 'بله — دوره‌ی خوبی برای یادگیری تخصصی و عمیق',
    'relationships': 'خوب — دوره‌ی خوبی برای تثبیت روابط موجود',
  },
  5: {
    'startWork': 'بله — به‌خصوص کارهایی با آزادی عمل بالا',
    'changeJob': 'بله — یکی از بهترین دوره‌ها برای تغییر مسیر',
    'learning': 'خوب — یادگیری از طریق تجربه‌ی مستقیم',
    'relationships': 'متغیر — این دوره بی‌ثباتی احساسی هم به‌همراه دارد',
  },
  6: {
    'startWork': 'خوب — به‌خصوص در حوزه‌های خدماتی یا خانوادگی',
    'changeJob': 'محتاط باش — مسئولیت‌های فعلی را در نظر بگیر',
    'learning': 'خوب — یادگیری مهارت‌های مرتبط با مراقبت و مدیریت',
    'relationships': 'بله — دوره‌ی بسیار مناسبی برای خانواده و تعهد',
  },
  7: {
    'startWork': 'محتاط باش — ابتدا تحقیق و آماده‌سازی کن',
    'changeJob': 'خوب — اگر مسیر تازه معنادارتر باشد',
    'learning': 'بله — یکی از بهترین دوره‌ها برای یادگیری عمیق',
    'relationships': 'متوسط — نیاز به تنهایی ممکن است بر روابط اثر بگذارد',
  },
  8: {
    'startWork': 'بله — دوره‌ی بسیار مناسبی برای جاه‌طلبی‌های بزرگ',
    'changeJob': 'بله — به‌خصوص برای ارتقای جایگاه',
    'learning': 'خوب — یادگیری مهارت‌های مدیریتی و مالی',
    'relationships': 'محتاط باش — تعادل بین کار و رابطه را حفظ کن',
  },
  9: {
    'startWork': 'محتاط باش — این دوره بیشتر برای جمع‌بندی است تا شروع',
    'changeJob': 'خوب — اگر مسیر تازه خدمت‌محورتر باشد',
    'learning': 'خوب — یادگیری از طریق تدریس یا کمک به دیگران',
    'relationships': 'بله — دوره‌ی خوبی برای بخشش و آشتی در روابط',
  },
};

/// تولید چرخه‌های ۹ساله از تولد تا ۹۰ سالگی (۱۰ بلوک ۹ساله).
/// عدد هر بلوک به‌ترتیب از ۱ تا ۹ می‌چرخد (بلوک یازدهم دوباره از ۱ شروع می‌شود).
List<NineYearCycle> buildNineYearCycles() {
  final cycles = <NineYearCycle>[];

  for (int i = 0; i < 10; i++) {
    final cycleNumber = (i % 9) + 1;
    final data = lifePathNumbers[cycleNumber]!;
    final advice = _timingAdvice[cycleNumber]!;

    cycles.add(NineYearCycle(
      blockIndex: i + 1,
      startAge: i * 9,
      endAge: (i + 1) * 9,
      cycleNumber: cycleNumber,
      title: data.title,
      lifeLesson: data.soulMission,
      strengths: data.positiveTraits,
      challenges: data.negativeTraits,
      opportunities: [data.suitableJobs.first, data.suitableJobs.length > 1 ? data.suitableJobs[1] : data.suitableJobs.first],
      goodForStartingWork: advice['startWork']!,
      goodForChangingJob: advice['changeJob']!,
      goodForLearning: advice['learning']!,
      goodForRelationships: advice['relationships']!,
    ));
  }

  return cycles;
}
