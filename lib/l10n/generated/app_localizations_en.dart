// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Kavakeb';

  @override
  String get splashSubtitle =>
      'Your daily guide to inspiration and self-discovery';

  @override
  String get splashDisclaimer =>
      'Kavakeb is a space for entertainment, self-discovery, and inspiration drawn from traditional and symbolic knowledge. Its content is not scientific or definitive prediction, and should not replace important life, medical, financial, or legal decisions. Join us with an open, playful mind ✨';

  @override
  String get signupTitle => 'Sign Up';

  @override
  String get signupCountryLabel => 'Country';

  @override
  String get signupPhoneHint => 'Mobile number';

  @override
  String get signupEmailHint => 'Email address';

  @override
  String get signupCodeHint => '6-digit code';

  @override
  String get signupSendCode => 'Send code';

  @override
  String get signupResendCode => 'Resend';

  @override
  String get signupContinue => 'Continue';

  @override
  String get signupNameHint => 'Full name';

  @override
  String get signupBirthDateLabel => 'Date of birth';

  @override
  String get signupCalendarShamsi => 'Persian';

  @override
  String get signupCalendarGregorian => 'Gregorian';

  @override
  String get signupCalendarHijri => 'Hijri';

  @override
  String get signupDayHint => 'Day';

  @override
  String get signupMonthHint => 'Month';

  @override
  String get signupYearHint => 'Year';

  @override
  String get signupGenderMale => 'Male';

  @override
  String get signupGenderFemale => 'Female';

  @override
  String signupPhoneDigitsHelper(int min, int max) {
    return '$min to $max digits (no leading zero)';
  }

  @override
  String homeGreeting(String name) {
    return 'Hi $name 🌙';
  }

  @override
  String get homeTodayMessage => 'Today\'s Message';

  @override
  String get homeTodayCard => 'Today\'s Card';

  @override
  String get homeViewInterpretation => 'View interpretation';

  @override
  String get homeTodayLuck => 'Today\'s Luck';

  @override
  String get homeLuckColor => 'Lucky color';

  @override
  String get homeLuckNumber => 'Lucky number';

  @override
  String get homeLuckHour => 'Best hour';

  @override
  String get homeTodayElement => 'Today\'s element';

  @override
  String get homeQuickHafez => 'Hafez Fortune';

  @override
  String get homeQuickIstikhara => 'Istikhara';

  @override
  String get homeQuickDream => 'Dream Interpretation';

  @override
  String get homeQuickAssistant => 'Smart Assistant';

  @override
  String get homeDestinyBookTitle => 'Book of Destiny';

  @override
  String get homeDestinyBookSubtitle =>
      'Discover the secrets of your name and birth date';

  @override
  String get homeTotalPoints => 'Total points';

  @override
  String get homeStreakLabel => 'Great! Keep it up';

  @override
  String get navHome => 'Home';

  @override
  String get navFals => 'Fortunes';

  @override
  String get navAI => 'AI';

  @override
  String get navLearning => 'Learn';

  @override
  String get navProfile => 'Profile';
}
