import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fa')
  ];

  /// App name shown on splash
  ///
  /// In fa, this message translates to:
  /// **'کواکب'**
  String get appName;

  /// No description provided for @splashSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'راهنمای روزانه‌ی شما برای الهام و خودشناسی'**
  String get splashSubtitle;

  /// No description provided for @splashDisclaimer.
  ///
  /// In fa, this message translates to:
  /// **'کواکب یک فضای سرگرمی، خودشناسی و الهام‌گیری از دانش‌های سنتی و نمادین است. محتوای این اپ جنبه‌ی علمی یا پیش‌گویی قطعی ندارد و نباید جایگزین تصمیم‌های مهم زندگی، پزشکی، مالی یا حقوقی شود. با ذهنی باز و سرگرم‌کننده همراه ما باش ✨'**
  String get splashDisclaimer;

  /// No description provided for @signupTitle.
  ///
  /// In fa, this message translates to:
  /// **'ثبت‌نام'**
  String get signupTitle;

  /// No description provided for @signupCountryLabel.
  ///
  /// In fa, this message translates to:
  /// **'کشور'**
  String get signupCountryLabel;

  /// No description provided for @signupPhoneHint.
  ///
  /// In fa, this message translates to:
  /// **'شماره موبایل'**
  String get signupPhoneHint;

  /// No description provided for @signupEmailHint.
  ///
  /// In fa, this message translates to:
  /// **'آدرس ایمیل'**
  String get signupEmailHint;

  /// No description provided for @signupCodeHint.
  ///
  /// In fa, this message translates to:
  /// **'کد ۶ رقمی'**
  String get signupCodeHint;

  /// No description provided for @signupSendCode.
  ///
  /// In fa, this message translates to:
  /// **'ارسال کد'**
  String get signupSendCode;

  /// No description provided for @signupResendCode.
  ///
  /// In fa, this message translates to:
  /// **'ارسال دوباره'**
  String get signupResendCode;

  /// No description provided for @signupContinue.
  ///
  /// In fa, this message translates to:
  /// **'ادامه'**
  String get signupContinue;

  /// No description provided for @signupNameHint.
  ///
  /// In fa, this message translates to:
  /// **'نام و نام‌خانوادگی'**
  String get signupNameHint;

  /// No description provided for @signupBirthDateLabel.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ تولد'**
  String get signupBirthDateLabel;

  /// No description provided for @signupCalendarShamsi.
  ///
  /// In fa, this message translates to:
  /// **'شمسی'**
  String get signupCalendarShamsi;

  /// No description provided for @signupCalendarGregorian.
  ///
  /// In fa, this message translates to:
  /// **'میلادی'**
  String get signupCalendarGregorian;

  /// No description provided for @signupCalendarHijri.
  ///
  /// In fa, this message translates to:
  /// **'قمری'**
  String get signupCalendarHijri;

  /// No description provided for @signupDayHint.
  ///
  /// In fa, this message translates to:
  /// **'روز'**
  String get signupDayHint;

  /// No description provided for @signupMonthHint.
  ///
  /// In fa, this message translates to:
  /// **'ماه'**
  String get signupMonthHint;

  /// No description provided for @signupYearHint.
  ///
  /// In fa, this message translates to:
  /// **'سال'**
  String get signupYearHint;

  /// No description provided for @signupGenderMale.
  ///
  /// In fa, this message translates to:
  /// **'آقا'**
  String get signupGenderMale;

  /// No description provided for @signupGenderFemale.
  ///
  /// In fa, this message translates to:
  /// **'خانم'**
  String get signupGenderFemale;

  /// No description provided for @signupPhoneDigitsHelper.
  ///
  /// In fa, this message translates to:
  /// **'{min} تا {max} رقم (بدون صفر ابتدایی)'**
  String signupPhoneDigitsHelper(int min, int max);

  /// No description provided for @homeGreeting.
  ///
  /// In fa, this message translates to:
  /// **'سلام {name} 🌙'**
  String homeGreeting(String name);

  /// No description provided for @homeTodayMessage.
  ///
  /// In fa, this message translates to:
  /// **'پیام امروز'**
  String get homeTodayMessage;

  /// No description provided for @homeTodayCard.
  ///
  /// In fa, this message translates to:
  /// **'کارت امروز'**
  String get homeTodayCard;

  /// No description provided for @homeViewInterpretation.
  ///
  /// In fa, this message translates to:
  /// **'مشاهده تفسیر'**
  String get homeViewInterpretation;

  /// No description provided for @homeTodayLuck.
  ///
  /// In fa, this message translates to:
  /// **'شانس امروز'**
  String get homeTodayLuck;

  /// No description provided for @homeLuckColor.
  ///
  /// In fa, this message translates to:
  /// **'رنگ پیشنهادی'**
  String get homeLuckColor;

  /// No description provided for @homeLuckNumber.
  ///
  /// In fa, this message translates to:
  /// **'عدد شانس'**
  String get homeLuckNumber;

  /// No description provided for @homeLuckHour.
  ///
  /// In fa, this message translates to:
  /// **'ساعت مناسب'**
  String get homeLuckHour;

  /// No description provided for @homeTodayElement.
  ///
  /// In fa, this message translates to:
  /// **'عنصر امروز'**
  String get homeTodayElement;

  /// No description provided for @homeQuickHafez.
  ///
  /// In fa, this message translates to:
  /// **'فال حافظ'**
  String get homeQuickHafez;

  /// No description provided for @homeQuickIstikhara.
  ///
  /// In fa, this message translates to:
  /// **'استخاره'**
  String get homeQuickIstikhara;

  /// No description provided for @homeQuickDream.
  ///
  /// In fa, this message translates to:
  /// **'تعبیر خواب'**
  String get homeQuickDream;

  /// No description provided for @homeQuickAssistant.
  ///
  /// In fa, this message translates to:
  /// **'دستیار هوشمند'**
  String get homeQuickAssistant;

  /// No description provided for @homeDestinyBookTitle.
  ///
  /// In fa, this message translates to:
  /// **'کتاب سرنوشت'**
  String get homeDestinyBookTitle;

  /// No description provided for @homeDestinyBookSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'رازهای اسم و تاریخ تولدت رو کشف کن'**
  String get homeDestinyBookSubtitle;

  /// No description provided for @homeTotalPoints.
  ///
  /// In fa, this message translates to:
  /// **'امتیاز کل'**
  String get homeTotalPoints;

  /// No description provided for @homeStreakLabel.
  ///
  /// In fa, this message translates to:
  /// **'آفرین! عالی پیش می‌روی'**
  String get homeStreakLabel;

  /// No description provided for @navHome.
  ///
  /// In fa, this message translates to:
  /// **'خانه'**
  String get navHome;

  /// No description provided for @navFals.
  ///
  /// In fa, this message translates to:
  /// **'فال‌ها'**
  String get navFals;

  /// No description provided for @navAI.
  ///
  /// In fa, this message translates to:
  /// **'هوش مصنوعی'**
  String get navAI;

  /// No description provided for @navLearning.
  ///
  /// In fa, this message translates to:
  /// **'آموزش'**
  String get navLearning;

  /// No description provided for @navProfile.
  ///
  /// In fa, this message translates to:
  /// **'پروفایل'**
  String get navProfile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
