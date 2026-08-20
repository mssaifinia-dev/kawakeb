import 'numerology_data.dart';
import 'name_number_data.dart';
import 'birth_day_number_data.dart';
import 'soul_mission_data.dart';

// ============================================================================
// «ردپای زندگی گذشته» — بخش نمادین کتاب سرنوشت
// ============================================================================
//
// طراحی این فایل کاملاً قاعده‌محور است، نه تصادفی:
// - «زندگی احتمالی گذشته»، «نقش‌ها»، «الگوهای منتقل‌شده» و «پایان نمادین»
//   مستقیماً از روی lifePath.number انتخاب می‌شوند (یک Map ثابت، نه Random).
// - «درس ناتمام روح» و «گره کارمایی» مستقیماً از buildSoulMissionReport
//   موجود (soul_mission_data.dart) گرفته می‌شوند — محاسبه‌ی جدیدی انجام
//   نمی‌شود.
// - «استعدادهای به‌جامانده» مستقیماً از lifePath.suitableJobs و
//   nameNumber.innateAbilities/talents موجود می‌آید.
// - «الگوهای منتقل‌شده»‌ی اضافه، از متن واقعی weaknesses عدد اسم استخراج
//   می‌شود (تطبیق کلیدواژه‌ای، نه انتخاب آزاد).
//
// همه‌ی متن‌ها با عبارت‌های غیرقطعی («در این خوانش نمادین»، «یکی از
// برداشت‌های احتمالی») نوشته شده‌اند و هیچ ادعای علمی یا قطعی درباره‌ی
// تناسخ ندارند.

class _PastLifeArchetype {
  final String persona;
  final List<String> possibleRoles;
  final List<String> transferredPatterns;
  final String symbolicEnding;

  const _PastLifeArchetype({
    required this.persona,
    required this.possibleRoles,
    required this.transferredPatterns,
    required this.symbolicEnding,
  });
}

const Map<int, _PastLifeArchetype> _archetypesByLifePath = {
  1: _PastLifeArchetype(
    persona:
        'در یکی از خوانش‌های نمادین این الگوی عددی، می‌توان زندگی گذشته‌ای را تصور کرد که در آن فردی مستقل و آغازگر بوده‌ای — کسی که مسیرهای تازه را برای اولین‌بار می‌گشود، حتی وقتی هیچ‌کس دیگری جرأت شروع نداشت.',
    possibleRoles: ['رهبر یک گروه یا قبیله‌ی کوچک', 'کاشف مسیرهای ناشناخته', 'کسی که همیشه اولین قدم را برمی‌داشت'],
    transferredPatterns: ['نیاز شدید به استقلال', 'میل به کنترل مسیر خودت', 'دشواری در پیروی از تصمیم دیگران'],
    symbolicEnding:
        'در این خوانش نمادین، این زندگی در اوج یک تصمیم بزرگ و تنها به پایان رسیده — لحظه‌ای که باید به‌تنهایی انتخاب می‌کردی.',
  ),
  2: _PastLifeArchetype(
    persona:
        'یکی از برداشت‌های احتمالی این الگوی عددی، تصویر فردی صلح‌جو و میانجی است — کسی که در پس‌زمینه‌ی رخدادهای بزرگ، نقشش هماهنگ‌کردن آدم‌ها و آرام‌کردن تنش‌ها بوده.',
    possibleRoles: ['میانجی صلح بین دو طرف درگیر', 'همراه نزدیک یک شخصیت مهم‌تر', 'نگهبان هماهنگی در یک جمع'],
    transferredPatterns: ['ترس از تعارض و درگیری', 'وابستگی احساسی به تایید دیگران', 'فراموش‌کردن نیاز خود به‌نفع آرامش جمع'],
    symbolicEnding: 'در این خوانش نمادین، این زندگی با از‌خودگذشتگی برای حفظ آرامش دیگران به پایان رسیده.',
  ),
  3: _PastLifeArchetype(
    persona:
        'در این خوانش نمادین، الگوی عددی تو می‌تواند به هنرمند یا راوی‌ای اشاره کند — کسی که با کلام، آواز یا هنر دستش، احساسات یک جمع را بیان می‌کرد.',
    possibleRoles: ['نوازنده یا راوی دوره‌گرد', 'هنرمندی که برای دربار یا جمع اجرا می‌کرد', 'کسی که با قصه‌هایش امید می‌داد'],
    transferredPatterns: ['نیاز به دیده‌شدن و شنیده‌شدن', 'گریز از جدیت و تعهدهای سنگین', 'پراکندگی انرژی بین چند علاقه'],
    symbolicEnding: 'در این خوانش نمادین، این زندگی در میانه‌ی یک اجرا یا خلق ناتمام به پایان رسیده.',
  ),
  4: _PastLifeArchetype(
    persona:
        'یکی از برداشت‌های احتمالی این الگوی عددی، تصویر صنعتگر یا سازنده‌ای‌ست — کسی که با دست‌های خودش چیزی ماندگار می‌ساخت و به جزئیات کارش وسواس داشت.',
    possibleRoles: ['صنعتگر یا معمار محلی', 'سازنده‌ی ابزار یا بناهای ماندگار', 'کسی که مسئول نظم و ساختار یک جمع بود'],
    transferredPatterns: ['نیاز شدید به ثبات و امنیت', 'سختگیری بیش از حد نسبت به خود', 'مقاومت در برابر تغییرات ناگهانی'],
    symbolicEnding: 'در این خوانش نمادین، این زندگی در حال تکمیل یک ساخته‌ی نیمه‌تمام به پایان رسیده.',
  ),
  5: _PastLifeArchetype(
    persona:
        'در این خوانش نمادین، الگوی عددی تو می‌تواند به مسافر یا بازرگان دوره‌گردی اشاره کند — کسی که هیچ‌وقت در یک‌جا نمی‌ماند و مرزها برایش معنای کمی داشتند.',
    possibleRoles: ['بازرگان یا مسافر کاروان‌ها', 'قاصد بین شهرها یا سرزمین‌ها', 'کسی که دائم در جست‌وجوی تجربه‌ی تازه بود'],
    transferredPatterns: ['نیاز به آزادی و گریز از تعهد', 'بی‌قراری در موقعیت‌های یکنواخت', 'ترس نهفته از گیر افتادن'],
    symbolicEnding: 'در این خوانش نمادین، این زندگی در میانه‌ی یک سفر ناتمام به پایان رسیده.',
  ),
  6: _PastLifeArchetype(
    persona:
        'یکی از برداشت‌های احتمالی این الگوی عددی، تصویر درمانگر یا مراقبی‌ست — کسی که دیگران در سختی به او پناه می‌بردند و مسئولیت سلامت یا آرامش جمع را برعهده داشت.',
    possibleRoles: ['درمانگر یا شفادهنده‌ی محلی', 'مراقب خانواده یا جمع بزرگ‌تر', 'کسی که در بحران‌ها تکیه‌گاه دیگران بود'],
    transferredPatterns: ['فداکاری بیش از حد برای دیگران', 'دشواری در گفتن نه', 'حس مسئولیت سنگین نسبت به سلامت اطرافیان'],
    symbolicEnding: 'در این خوانش نمادین، این زندگی در حال مراقبت از دیگران، بدون فرصتی برای مراقبت از خود، به پایان رسیده.',
  ),
  7: _PastLifeArchetype(
    persona:
        'در این خوانش نمادین، الگوی عددی تو می‌تواند به جست‌وجوگر حقیقت یا اندیشمندی گوشه‌گیر اشاره کند — کسی که دور از هیاهو، دنبال معنای عمیق‌تر هستی بود.',
    possibleRoles: ['اندیشمند یا کاهن گوشه‌نشین', 'کسی که در انزوا به مطالعه و تعمق می‌پرداخت', 'نگهبان دانشی که کمتر کسی می‌فهمید'],
    transferredPatterns: ['گرایش به انزوا و فاصله‌گیری از دیگران', 'دشواری در اعتماد و باز کردن دل', 'نیاز عمیق به تنهایی برای فکر کردن'],
    symbolicEnding: 'در این خوانش نمادین، این زندگی در خلوت و دور از چشم دیگران به پایان رسیده.',
  ),
  8: _PastLifeArchetype(
    persona:
        'یکی از برداشت‌های احتمالی این الگوی عددی، تصویر یک تاجر یا رهبر قدرتمند است — کسی که منابع و افراد زیادی را مدیریت می‌کرد و برای رسیدن به جایگاه بالا تلاش زیادی کرده بود.',
    possibleRoles: ['بازرگان یا صاحب‌منصب بانفوذ', 'رهبری که مسئول منابع یک جمع بزرگ بود', 'کسی که جایگاهش را با تلاش زیاد ساخته بود'],
    transferredPatterns: ['میل به کنترل و قدرت', 'ترس از دست دادن جایگاه یا منابع', 'قضاوت خود بر اساس موفقیت بیرونی'],
    symbolicEnding: 'در این خوانش نمادین، این زندگی در اوج قدرت یا مسئولیت، به‌طور ناگهانی به پایان رسیده.',
  ),
  9: _PastLifeArchetype(
    persona:
        'در این خوانش نمادین، الگوی عددی تو می‌تواند به خدمت‌گزار مردم یا آرمان‌گرایی اشاره کند — کسی که زندگی‌اش را وقف چیزی بزرگ‌تر از خودش کرده بود.',
    possibleRoles: ['خدمت‌گزار یا نگهبان یک جمع بزرگ‌تر', 'کسی که برای آرمانی مشترک تلاش می‌کرد', 'یاری‌رسان به محرومان یا رنج‌دیدگان'],
    transferredPatterns: ['فداکاری تا مرز فرسودگی', 'دلبستگی احساسی به گذشته یا آرمان‌ها', 'دشواری در رها کردن آنچه دیگر کارساز نیست'],
    symbolicEnding: 'در این خوانش نمادین، این زندگی در راه خدمت به دیگران، بدون فرصتی برای خودش، به پایان رسیده.',
  ),
  11: _PastLifeArchetype(
    persona:
        'یکی از برداشت‌های احتمالی این عدد استاد، تصویر یک پیام‌آور یا واسطه‌ی شهودی است — کسی که چیزهایی را حس یا می‌دید که دیگران هنوز نمی‌دیدند.',
    possibleRoles: ['پیام‌آور یا واسطه‌ی معنوی یک جمع', 'کسی که رؤیا یا شهودش راهنمای دیگران بود', 'فردی حساس که انرژی اطراف را عمیق حس می‌کرد'],
    transferredPatterns: ['حساسیت شدید به انرژی و احساسات دیگران', 'اضطراب ناشی از دیدن چیزی که دیگران نمی‌دیدند', 'دشواری در زندگی کاملاً عملی و روزمره'],
    symbolicEnding: 'در این خوانش نمادین، این زندگی در حالی به پایان رسیده که هنوز بخشی از بینشش ناگفته مانده بود.',
  ),
  22: _PastLifeArchetype(
    persona:
        'در این خوانش نمادین، این عدد استاد می‌تواند به سازنده‌ای در مقیاس بزرگ اشاره کند — کسی که رؤیایی بزرگ را به چیزی ملموس و ماندگار برای جمعی بزرگ‌تر تبدیل می‌کرد.',
    possibleRoles: ['معمار یا سازنده‌ی یک بنای بزرگ', 'رهبری که زیرساخت یک جامعه را شکل می‌داد', 'کسی که رؤیای بزرگش را با کار سخت ملموس کرد'],
    transferredPatterns: ['فشار روانی از انتظار بالا از خود', 'کار بیش از حد و غفلت از استراحت', 'ترس از شکست در پروژه‌ای بزرگ'],
    symbolicEnding: 'در این خوانش نمادین، این زندگی درست پیش از تکمیل بزرگ‌ترین ساخته‌اش به پایان رسیده.',
  ),
  33: _PastLifeArchetype(
    persona:
        'یکی از برداشت‌های احتمالی این نادرترین عدد استاد، تصویر معلم یا شفادهنده‌ای عمیقاً عاشق‌پیشه است — کسی که عشق و مراقبتش شامل حال جمع بزرگی از آدم‌ها می‌شد.',
    possibleRoles: ['معلم یا شفادهنده‌ی روحانی یک جمع بزرگ', 'کسی که رنج دیگران را عمیقاً با خود حمل می‌کرد', 'راهنمایی که بدون چشم‌داشت خدمت می‌کرد'],
    transferredPatterns: ['فداکاری تا مرز فرسودگی کامل', 'دشواری شدید در مراقبت از خود', 'حمل بار احساسی دیگران به‌عنوان مسئولیت شخصی'],
    symbolicEnding: 'در این خوانش نمادین، این زندگی در حال دادن، بدون فرصتی برای گرفتن، به پایان رسیده.',
  ),
};

/// از روی متن واقعی weaknesses عدد اسم، الگوهای منتقل‌شده‌ی اضافه را با
/// تطبیق کلیدواژه‌ای (نه انتخاب آزاد) استخراج می‌کند. فقط الگوهایی که واقعاً
/// در متن داده‌ی کاربر مبنا دارند نمایش داده می‌شوند.
List<String> _extraPatternsFromWeaknesses(List<String> weaknesses) {
  final text = weaknesses.join(' ');
  final result = <String>[];
  if (text.contains('اعتماد') || text.contains('باور')) result.add('مشکل اعتماد به دیگران');
  if (text.contains('فداکاری') || text.contains('گذشتگی')) result.add('فداکاری بیش از حد');
  if (text.contains('کنترل')) result.add('میل به قدرت و کنترل بر شرایط');
  if (text.contains('تعهد') || text.contains('بی‌قراری')) result.add('نیاز به آزادی و گریز از تعهد');
  if (text.contains('مسئولیت')) result.add('مسئولیت‌پذیری بیش از‌حد');
  if (text.contains('انزوا') || text.contains('فاصله')) result.add('گرایش به انزوا و فاصله‌گیری');
  if (text.contains('دودل') || text.contains('تصمیم')) result.add('دودلی در تصمیم‌های مهم');
  return result;
}

class PastLifeReport {
  final String persona;
  final String chosenRole;
  final String soulLesson;
  final List<String> transferredPatterns;
  final String karmicRelationships;
  final List<String> leftoverTalents;
  final String karmicKnot;
  final String symbolicEnding;
  final String connectionToPresent;
  final String soulMessage;

  const PastLifeReport({
    required this.persona,
    required this.chosenRole,
    required this.soulLesson,
    required this.transferredPatterns,
    required this.karmicRelationships,
    required this.leftoverTalents,
    required this.karmicKnot,
    required this.symbolicEnding,
    required this.connectionToPresent,
    required this.soulMessage,
  });
}

/// گزارش «ردپای زندگی گذشته» را کاملاً بر اساس داده‌های عددشناسی موجود
/// می‌سازد — بدون Random، بدون فراخوانی هوش مصنوعی. اگر ترکیب lifePath و
/// nameNumber از قبل محاسبه شده باشد (که در داشبورد این‌طور است)، این تابع
/// فقط از همان خروجی‌ها استفاده مجدد می‌کند.
PastLifeReport buildPastLifeReport({
  required LifePathNumber lifePath,
  required NameNumber nameNumber,
  required BirthDayNumberInfo? birthDay,
}) {
  final archetype = _archetypesByLifePath[lifePath.number] ?? _archetypesByLifePath[1]!;

  // انتخاب نقش: نه Random، بلکه بر پایه‌ی عدد اسم (که خودش از نام واقعی
  // کاربر محاسبه شده) از میان نقش‌های محتمل همان کهن‌الگو.
  final roleIndex = nameNumber.number % archetype.possibleRoles.length;
  final chosenRole = archetype.possibleRoles[roleIndex];

  // درس ناتمام روح و گره‌ی کارمایی: به‌جای محاسبه‌ی جدید، مستقیماً از
  // buildSoulMissionReport موجود پروژه استفاده می‌شود.
  final soulReport = buildSoulMissionReport(
    lifePath: lifePath,
    nameNumber: nameNumber,
    birthDay: birthDay ??
        const BirthDayNumberInfo(number: 0, title: 'نامشخص', keyword: 'مسیر شخصی خودت'),
  );

  final combinedPatterns = <String>{
    ...archetype.transferredPatterns,
    ..._extraPatternsFromWeaknesses(nameNumber.weaknesses),
  }.take(5).toList();

  final leftoverTalents = <String>{
    ...lifePath.suitableJobs.take(2),
    ...nameNumber.innateAbilities,
    ...nameNumber.talents.take(1),
  }.take(5).toList();

  final karmicRelationships =
      'برخی از افرادی که این روزها در زندگی‌ات احساس آشنایی عمیق یا کشش غیرمنتظره‌ای نسبت به آن‌ها داری، می‌توانند در این خوانش نمادین، بازتابی از رابطه‌هایی باشند که با انرژی ${lifePath.dominantEnergy} یا ${nameNumber.dominantEnergy} شکل گرفته‌اند. '
      'این برداشتی نمادین است، نه ادعایی درباره‌ی هویت مشخص کسی از زندگی گذشته‌ات.';

  final connectionToPresent =
      'الگوی «${lifePath.negativeTraits.first}» که در این زندگی هم گاهی خودش را نشان می‌دهد، در این خوانش نمادین می‌تواند ریشه در همان زندگی گذشته داشته باشد. '
      'در مقابل، «${lifePath.positiveTraits.first}» و «${nameNumber.talents.first}» از نقاط قوتی هستند که به نظر می‌رسد از همان دوره با خودت آورده‌ای. '
      'چیزی که در این خوانش بهتر است آگاهانه تغییر کند، همان بخشی‌ست که در «${soulReport.pointsToImprove.first}» به آن اشاره شد.';

  final soulMessage =
      'آنچه از گذشته با خود آورده‌ای، الزاماً برای تکرار کردن نیست؛ بخشی از آن برای کامل کردن درسی است که هنوز ادامه دارد. '
      'برای تو، این درس در قالب «${lifePath.soulMission}» جلوه کرده — و ${nameNumber.dominantEnergy} همان ابزاری‌ست که این‌بار همراهت است.';

  return PastLifeReport(
    persona: archetype.persona,
    chosenRole: chosenRole,
    soulLesson: soulReport.lifeGoal,
    transferredPatterns: combinedPatterns,
    karmicRelationships: karmicRelationships,
    leftoverTalents: leftoverTalents,
    karmicKnot: soulReport.possibleKarma,
    symbolicEnding: archetype.symbolicEnding,
    connectionToPresent: connectionToPresent,
    soulMessage: soulMessage,
  );
}
