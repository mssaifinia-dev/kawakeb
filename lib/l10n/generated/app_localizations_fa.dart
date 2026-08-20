// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appName => 'کواکب';

  @override
  String get splashSubtitle => 'راهنمای روزانه‌ی شما برای الهام و خودشناسی';

  @override
  String get splashDisclaimer =>
      'کواکب یک فضای سرگرمی، خودشناسی و الهام‌گیری از دانش‌های سنتی و نمادین است. محتوای این اپ جنبه‌ی علمی یا پیش‌گویی قطعی ندارد و نباید جایگزین تصمیم‌های مهم زندگی، پزشکی، مالی یا حقوقی شود. با ذهنی باز و سرگرم‌کننده همراه ما باش ✨';

  @override
  String get signupTitle => 'ثبت‌نام';

  @override
  String get signupCountryLabel => 'کشور';

  @override
  String get signupPhoneHint => 'شماره موبایل';

  @override
  String get signupEmailHint => 'آدرس ایمیل';

  @override
  String get signupCodeHint => 'کد ۶ رقمی';

  @override
  String get signupSendCode => 'ارسال کد';

  @override
  String get signupResendCode => 'ارسال دوباره';

  @override
  String get signupContinue => 'ادامه';

  @override
  String get signupNameHint => 'نام و نام‌خانوادگی';

  @override
  String get signupBirthDateLabel => 'تاریخ تولد';

  @override
  String get signupCalendarShamsi => 'شمسی';

  @override
  String get signupCalendarGregorian => 'میلادی';

  @override
  String get signupCalendarHijri => 'قمری';

  @override
  String get signupDayHint => 'روز';

  @override
  String get signupMonthHint => 'ماه';

  @override
  String get signupYearHint => 'سال';

  @override
  String get signupGenderMale => 'آقا';

  @override
  String get signupGenderFemale => 'خانم';

  @override
  String signupPhoneDigitsHelper(int min, int max) {
    return '$min تا $max رقم (بدون صفر ابتدایی)';
  }

  @override
  String homeGreeting(String name) {
    return 'سلام $name 🌙';
  }

  @override
  String get homeTodayMessage => 'پیام امروز';

  @override
  String get homeTodayCard => 'کارت امروز';

  @override
  String get homeViewInterpretation => 'مشاهده تفسیر';

  @override
  String get homeTodayLuck => 'شانس امروز';

  @override
  String get homeLuckColor => 'رنگ پیشنهادی';

  @override
  String get homeLuckNumber => 'عدد شانس';

  @override
  String get homeLuckHour => 'ساعت مناسب';

  @override
  String get homeTodayElement => 'عنصر امروز';

  @override
  String get homeQuickHafez => 'فال حافظ';

  @override
  String get homeQuickIstikhara => 'استخاره';

  @override
  String get homeQuickDream => 'تعبیر خواب';

  @override
  String get homeQuickAssistant => 'دستیار هوشمند';

  @override
  String get homeDestinyBookTitle => 'کتاب سرنوشت';

  @override
  String get homeDestinyBookSubtitle => 'رازهای اسم و تاریخ تولدت رو کشف کن';

  @override
  String get homeTotalPoints => 'امتیاز کل';

  @override
  String get homeStreakLabel => 'آفرین! عالی پیش می‌روی';

  @override
  String get navHome => 'خانه';

  @override
  String get navFals => 'فال‌ها';

  @override
  String get navAI => 'هوش مصنوعی';

  @override
  String get navLearning => 'آموزش';

  @override
  String get navProfile => 'پروفایل';
}
