import '../../abjad/data/abjad_data.dart';
import 'numerology_data.dart' show reduceWithMasterNumbers;

class NameNumber {
  final int number;
  final String title;
  final String description;
  final List<String> talents;
  final List<String> weaknesses;
  final List<String> innateAbilities;
  final String dominantEnergy;

  const NameNumber({
    required this.number,
    required this.title,
    required this.description,
    required this.talents,
    required this.weaknesses,
    required this.innateAbilities,
    required this.dominantEnergy,
  });
}

const Map<int, NameNumber> nameNumbers = {
  1: NameNumber(
    number: 1,
    title: 'هویت پیشرو',
    description: 'اسمی که با عدد ۱ همراه است، نشانه‌ی هویتی مستقل و پیشتاز است — چیزی در نامت، تو را به سمت آغازگری سوق می‌دهد.',
    talents: ['ابتکار در شروع کارها', 'توان تصمیم‌گیری سریع', 'جذب طبیعی توجه دیگران'],
    weaknesses: ['عجله در قضاوت', 'دشواری در پیروی از دیگران'],
    innateAbilities: ['توانایی ذاتی رهبری', 'شهامت شروع از صفر'],
    dominantEnergy: 'انرژی آغازگری',
  ),
  2: NameNumber(
    number: 2,
    title: 'هویت هماهنگ‌ساز',
    description: 'اسمی که با عدد ۲ همراه است، نشانه‌ی هویتی است که در ارتباط با دیگران معنا پیدا می‌کند.',
    talents: ['مهارت در گفت‌وگوی نرم', 'حس تیمی قوی', 'توانایی درک احساسات دیگران'],
    weaknesses: ['دودلی در تصمیم‌های فردی', 'حساسیت زیاد به قضاوت دیگران'],
    innateAbilities: ['استعداد ذاتی میانجی‌گری', 'گوش شنوای طبیعی'],
    dominantEnergy: 'انرژی همراهی',
  ),
  3: NameNumber(
    number: 3,
    title: 'هویت بیانگر',
    description: 'اسمی که با عدد ۳ همراه است، نشانه‌ی هویتی خلاق و پرانرژی در بیان خود است.',
    talents: ['بیان کلامی یا هنری قوی', 'انرژی اجتماعی بالا', 'خلق ایده‌های تازه'],
    weaknesses: ['پراکندگی تمرکز', 'گریز از جدیت بیش از حد'],
    innateAbilities: ['استعداد ذاتی هنری یا کلامی', 'توانایی شاد کردن فضا'],
    dominantEnergy: 'انرژی بیان و خلق',
  ),
  4: NameNumber(
    number: 4,
    title: 'هویت سازنده',
    description: 'اسمی که با عدد ۴ همراه است، نشانه‌ی هویتی است که به دنبال ثبات و ساختار در زندگی است.',
    talents: ['نظم‌دهی به کارهای پیچیده', 'قابلیت اعتماد بالا', 'صبر در پروژه‌های بلندمدت'],
    weaknesses: ['سختگیری نسبت به خود', 'مقاومت در برابر روش‌های تازه'],
    innateAbilities: ['استعداد ذاتی سازمان‌دهی', 'توانایی ساختن از پایه'],
    dominantEnergy: 'انرژی پایه‌سازی',
  ),
  5: NameNumber(
    number: 5,
    title: 'هویت آزاد',
    description: 'اسمی که با عدد ۵ همراه است، نشانه‌ی هویتی است که آزادی و تنوع را طلب می‌کند.',
    talents: ['تطبیق سریع با موقعیت‌های تازه', 'مهارت اجتماعی گسترده', 'جذابیت طبیعی'],
    weaknesses: ['بی‌قراری در تعهدهای طولانی', 'وسوسه‌ی تغییر مداوم مسیر'],
    innateAbilities: ['استعداد ذاتی سازگاری', 'حس ماجراجویانه'],
    dominantEnergy: 'انرژی تحرک و تنوع',
  ),
  6: NameNumber(
    number: 6,
    title: 'هویت مراقب',
    description: 'اسمی که با عدد ۶ همراه است، نشانه‌ی هویتی است که در نقش حمایت‌گر و مراقب دیگران معنا پیدا می‌کند.',
    talents: ['مراقبت طبیعی از اطرافیان', 'حس مسئولیت خانوادگی', 'ایجاد فضای امن برای دیگران'],
    weaknesses: ['از‌خودگذشتگی افراطی', 'دشواری در گفتن نه'],
    innateAbilities: ['استعداد ذاتی پرورش‌دهندگی', 'توانایی ایجاد آرامش در دیگران'],
    dominantEnergy: 'انرژی مراقبت',
  ),
  7: NameNumber(
    number: 7,
    title: 'هویت جست‌وجوگر',
    description: 'اسمی که با عدد ۷ همراه است، نشانه‌ی هویتی درون‌گرا و در جست‌وجوی حقیقت و معناست.',
    talents: ['تحلیل عمیق موضوعات پیچیده', 'شهود قوی', 'ظرفیت بالا برای یادگیری مستقل'],
    weaknesses: ['فاصله‌گیری از دیگران', 'دشواری در باور به شهود دیگران'],
    innateAbilities: ['استعداد ذاتی تفکر فلسفی', 'حس عمیق کنجکاوی نسبت به حقیقت'],
    dominantEnergy: 'انرژی جست‌وجوی حقیقت',
  ),
  8: NameNumber(
    number: 8,
    title: 'هویت مقتدر',
    description: 'اسمی که با عدد ۸ همراه است، نشانه‌ی هویتی است که با قدرت، نظم و جاه‌طلبی گره خورده.',
    talents: ['مدیریت منابع و افراد', 'نگاه استراتژیک بلندمدت', 'توان تحمل فشار زیاد'],
    weaknesses: ['تمایل به کنترل بیش از حد', 'قضاوت بر اساس موفقیت مادی'],
    innateAbilities: ['استعداد ذاتی رهبری سازمانی', 'توانایی ساختن امپراتوری کوچک'],
    dominantEnergy: 'انرژی قدرت سازمان‌یافته',
  ),
  9: NameNumber(
    number: 9,
    title: 'هویت انسان‌دوست',
    description: 'اسمی که با عدد ۹ همراه است، نشانه‌ی هویتی است که در خدمت به چیزی بزرگ‌تر از خود معنا پیدا می‌کند.',
    talents: ['همدلی عمیق با دیگران', 'دیدگاه جهانی و آرمان‌گرا', 'استعداد الهام‌بخشی'],
    weaknesses: ['فداکاری تا مرز فرسودگی', 'دلبستگی احساسی به گذشته'],
    innateAbilities: ['استعداد ذاتی خدمت به دیگران', 'حس عمیق عدالت‌خواهی'],
    dominantEnergy: 'انرژی خدمت و بخشش',
  ),
  11: NameNumber(
    number: 11,
    title: 'هویت شهودی (عدد استاد)',
    description: 'اسمی که به عدد استاد ۱۱ می‌رسد، نشانه‌ی هویتی با ظرفیت شهودی و معنوی غیرمعمول است.',
    talents: ['حساسیت شدید به انرژی‌های اطراف', 'الهام‌بخشی طبیعی', 'بینش پیش از موعد'],
    weaknesses: ['اضطراب ناشی از حساسیت زیاد', 'دشواری در زندگی کاملاً عملی'],
    innateAbilities: ['استعداد ذاتی شهود بالا', 'ارتباط طبیعی با دنیای معنوی'],
    dominantEnergy: 'انرژی شهودی فشرده',
  ),
  22: NameNumber(
    number: 22,
    title: 'هویت سازنده‌ی بزرگ (عدد استاد)',
    description: 'اسمی که به عدد استاد ۲۲ می‌رسد، نشانه‌ی هویتی است که توان تبدیل رؤیای بزرگ به واقعیت ملموس را دارد.',
    talents: ['ترکیب رؤیاپردازی و عملگرایی', 'مدیریت پروژه‌های بزرگ', 'تعهد عمیق به هدف بلندمدت'],
    weaknesses: ['فشار روانی از انتظار بالا از خود', 'کار بیش از حد'],
    innateAbilities: ['استعداد ذاتی ساخت‌وساز در مقیاس بزرگ', 'رهبری الهام‌بخش'],
    dominantEnergy: 'انرژی ساخت‌وساز فشرده',
  ),
  33: NameNumber(
    number: 33,
    title: 'هویت عاشق‌پیشه (عدد استاد)',
    description: 'اسمی که به عدد استاد ۳۳ می‌رسد، نادرترین و عمیق‌ترین نوع هویت خدمت‌گزارانه را نشان می‌دهد.',
    talents: ['ظرفیت شفابخشی بالا', 'عشق بی‌قید و شرط به دیگران', 'الهام‌بخشی در مقیاس گسترده'],
    weaknesses: ['فداکاری تا مرز فرسودگی کامل', 'دشواری شدید در مراقبت از خود'],
    innateAbilities: ['استعداد ذاتی شفادهی', 'حس عمیق مسئولیت جمعی'],
    dominantEnergy: 'انرژی عشق فراگیر فشرده',
  ),
};

/// محاسبه‌ی عدد اسم از روی حروف ابجد نام کامل (نام + نام‌خانوادگی)
int calculateNameNumber(String fullName) {
  final total = calculateAbjadValue(fullName);
  return reduceWithMasterNumbers(total);
}

/// موتور ترکیب پویا: به‌جای جدول ثابت ۱۴۴تایی (که عملاً غیرقابل نگهداری و
/// پرتکرار می‌شود)، از ویژگی‌های کلیدی هر دو عدد یک تحلیل ترکیبی می‌سازد.
String buildCombinationText({
  required int lifePathNumber,
  required String lifePathEnergy,
  required String lifePathTopTrait,
  required String lifePathMission,
  required int nameNumberValue,
  required String nameEnergy,
  required String nameTopTalent,
  required String nameTopAbility,
}) {
  return 'ترکیب عدد مسیر زندگی $lifePathNumber با عدد اسم $nameNumberValue نشان می‌دهد که $lifePathEnergy در وجودت با $nameEnergy همراه شده است. '
      'این یعنی $lifePathTopTrait را با $nameTopTalent ترکیب می‌کنی، و $nameTopAbility ابزاری است که برای رسیدن به ماموریت روحت ($lifePathMission) در اختیار داری.';
}
