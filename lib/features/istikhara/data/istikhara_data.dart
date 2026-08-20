import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum IstikharaVerdict { good, neutral, notGood }

extension IstikharaVerdictX on IstikharaVerdict {
  String get label {
    switch (this) {
      case IstikharaVerdict.good:
        return 'خوب است';
      case IstikharaVerdict.neutral:
        return 'متوسط است';
      case IstikharaVerdict.notGood:
        return 'فعلاً خوب نیست';
    }
  }

  Color get color {
    switch (this) {
      case IstikharaVerdict.good:
        return const Color(0xFF3ECF8E);
      case IstikharaVerdict.neutral:
        return AppColors.gold;
      case IstikharaVerdict.notGood:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case IstikharaVerdict.good:
        return Icons.check_circle_outline;
      case IstikharaVerdict.neutral:
        return Icons.remove_circle_outline;
      case IstikharaVerdict.notGood:
        return Icons.info_outline;
    }
  }
}

class IstikharaResult {
  final String verse; // آیه به عربی
  final String translation; // ترجمه فارسی
  final IstikharaVerdict verdict;
  final String guidance;

  const IstikharaResult({
    required this.verse,
    required this.translation,
    required this.verdict,
    required this.guidance,
  });
}

const List<IstikharaResult> istikharaResults = [
  IstikharaResult(
    verse: 'وَبَشِّرِ الْمُؤْمِنِینَ',
    translation: 'و مؤمنان را بشارت ده.',
    verdict: IstikharaVerdict.good,
    guidance: 'نشانه‌ها به نفع توست. با اطمینان و دلی آرام این کار را پیش ببر؛ نتیجه‌اش خشنودکننده خواهد بود.',
  ),
  IstikharaResult(
    verse: 'وَعَسَىٰ أَن تَکْرَهُوا شَیْئًا وَهُوَ خَیْرٌ لَّکُمْ',
    translation: 'و چه‌بسا چیزی را ناخوش دارید در حالی که برای شما خیر است.',
    verdict: IstikharaVerdict.neutral,
    guidance: 'نتیجه‌ی این کار در نگاه اول شاید مطلوب به‌نظر نرسد، اما در درازمدت خیر تو در آن نهفته است. با صبر پیش برو.',
  ),
  IstikharaResult(
    verse: 'فَاصْبِرْ صَبْرًا جَمِیلًا',
    translation: 'پس صبری نیکو پیشه کن.',
    verdict: IstikharaVerdict.neutral,
    guidance: 'زمان مناسب هنوز فرا نرسیده. کمی صبر کن و شتاب نکن؛ نتیجه بهتری در انتظار توست.',
  ),
  IstikharaResult(
    verse: 'وَلَا تَعْجَلْ بِالْقُرْآنِ مِن قَبْلِ أَن یُقْضَىٰ إِلَیْکَ وَحْیُهُ',
    translation: 'و در (خواندن) قرآن شتاب مکن پیش از آن‌که وحی آن به پایان رسد.',
    verdict: IstikharaVerdict.notGood,
    guidance: 'شتاب در این تصمیم توصیه نمی‌شود. بهتر است فعلاً از این کار صرف‌نظر کنی یا زمان بیشتری برای بررسی بگذاری.',
  ),
  IstikharaResult(
    verse: 'إِنَّ مَعَ الْعُسْرِ یُسْرًا',
    translation: 'همانا با سختی، آسانی است.',
    verdict: IstikharaVerdict.good,
    guidance: 'اگر این روزها احساس دشواری می‌کنی، بدان که گشایش نزدیک است. این قدم را با امید بردار.',
  ),
  IstikharaResult(
    verse: 'وَلَا تَلْقُوا بِأَیْدِیکُمْ إِلَى التَّهْلُکَةِ',
    translation: 'و خود را با دست خود به هلاکت نیفکنید.',
    verdict: IstikharaVerdict.notGood,
    guidance: 'این کار ممکن است ریسک بالایی داشته باشد. با احتیاط بیشتری تصمیم بگیر یا از افراد آگاه مشورت بخواه.',
  ),
];
