// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'كواكب';

  @override
  String get splashSubtitle => 'دليلك اليومي للإلهام ومعرفة الذات';

  @override
  String get splashDisclaimer =>
      'كواكب هو مساحة للترفيه ومعرفة الذات والإلهام المستوحى من المعارف التقليدية والرمزية. محتوى هذا التطبيق ليس علميًا أو تنبؤًا قطعيًا، ولا ينبغي أن يحل محل القرارات المهمة في الحياة أو الطبية أو المالية أو القانونية. انضم إلينا بعقل منفتح ومرح ✨';

  @override
  String get signupTitle => 'التسجيل';

  @override
  String get signupCountryLabel => 'الدولة';

  @override
  String get signupPhoneHint => 'رقم الجوال';

  @override
  String get signupEmailHint => 'البريد الإلكتروني';

  @override
  String get signupCodeHint => 'رمز مكوّن من ٦ أرقام';

  @override
  String get signupSendCode => 'إرسال الرمز';

  @override
  String get signupResendCode => 'إعادة الإرسال';

  @override
  String get signupContinue => 'متابعة';

  @override
  String get signupNameHint => 'الاسم الكامل';

  @override
  String get signupBirthDateLabel => 'تاريخ الميلاد';

  @override
  String get signupCalendarShamsi => 'الشمسي';

  @override
  String get signupCalendarGregorian => 'الميلادي';

  @override
  String get signupCalendarHijri => 'الهجري';

  @override
  String get signupDayHint => 'اليوم';

  @override
  String get signupMonthHint => 'الشهر';

  @override
  String get signupYearHint => 'السنة';

  @override
  String get signupGenderMale => 'ذكر';

  @override
  String get signupGenderFemale => 'أنثى';

  @override
  String signupPhoneDigitsHelper(int min, int max) {
    return '$min إلى $max أرقام (بدون صفر في البداية)';
  }

  @override
  String homeGreeting(String name) {
    return 'مرحبًا $name 🌙';
  }

  @override
  String get homeTodayMessage => 'رسالة اليوم';

  @override
  String get homeTodayCard => 'بطاقة اليوم';

  @override
  String get homeViewInterpretation => 'عرض التفسير';

  @override
  String get homeTodayLuck => 'حظ اليوم';

  @override
  String get homeLuckColor => 'اللون المقترح';

  @override
  String get homeLuckNumber => 'الرقم المحظوظ';

  @override
  String get homeLuckHour => 'الساعة المناسبة';

  @override
  String get homeTodayElement => 'عنصر اليوم';

  @override
  String get homeQuickHafez => 'فال حافظ';

  @override
  String get homeQuickIstikhara => 'الاستخارة';

  @override
  String get homeQuickDream => 'تفسير الأحلام';

  @override
  String get homeQuickAssistant => 'المساعد الذكي';

  @override
  String get homeDestinyBookTitle => 'كتاب القدر';

  @override
  String get homeDestinyBookSubtitle => 'اكتشف أسرار اسمك وتاريخ ميلادك';

  @override
  String get homeTotalPoints => 'مجموع النقاط';

  @override
  String get homeStreakLabel => 'أحسنت! استمر';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navFals => 'الفأل';

  @override
  String get navAI => 'الذكاء الاصطناعي';

  @override
  String get navLearning => 'تعلّم';

  @override
  String get navProfile => 'الملف الشخصي';
}
