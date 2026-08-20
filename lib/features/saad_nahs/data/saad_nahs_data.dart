enum DayQuality { saad, nahs, moderate }

class DayQualityInfo {
  final int day;
  final DayQuality quality;
  final String note;

  const DayQualityInfo({
    required this.day,
    required this.quality,
    required this.note,
  });
}

extension DayQualityLabel on DayQuality {
  String get label {
    switch (this) {
      case DayQuality.saad:
        return 'سعد (مبارک)';
      case DayQuality.nahs:
        return 'نحس (نامبارک)';
      case DayQuality.moderate:
        return 'معتدل';
    }
  }
}

/// جدول سنتی سعد و نحس ایام ماه (روز ۱ تا ۳۰) — این جدول یک نسخه‌ی رایج و
/// نمادین از باورهای سنتی است، نه یک منبع واحد و رسمی مورد‌اجماع.
const List<DayQualityInfo> saadNahsTable = [
  DayQualityInfo(day: 1, quality: DayQuality.saad, note: 'روزی مناسب برای شروع کارهای تازه.'),
  DayQualityInfo(day: 2, quality: DayQuality.moderate, note: 'روزی معمولی؛ نه زمان مناسبی برای ریسک بزرگ.'),
  DayQualityInfo(day: 3, quality: DayQuality.saad, note: 'مناسب برای سفر و دیدارهای مهم.'),
  DayQualityInfo(day: 4, quality: DayQuality.nahs, note: 'بهتر است تصمیم مهمی گرفته نشود.'),
  DayQualityInfo(day: 5, quality: DayQuality.saad, note: 'روزی خوب برای معاملات و امور مالی.'),
  DayQualityInfo(day: 6, quality: DayQuality.moderate, note: 'روزی متعادل برای کارهای روزمره.'),
  DayQualityInfo(day: 7, quality: DayQuality.saad, note: 'مناسب برای شروع پیمان و توافق‌ها.'),
  DayQualityInfo(day: 8, quality: DayQuality.moderate, note: 'روزی معمولی؛ احتیاط در گفت‌وگوها.'),
  DayQualityInfo(day: 9, quality: DayQuality.nahs, note: 'بهتر است در این روز از دعوا پرهیز شود.'),
  DayQualityInfo(day: 10, quality: DayQuality.saad, note: 'روزی نیکو برای شروع درمان یا بهبودی.'),
  DayQualityInfo(day: 11, quality: DayQuality.moderate, note: 'روزی متعادل؛ زمان خوبی برای برنامه‌ریزی.'),
  DayQualityInfo(day: 12, quality: DayQuality.saad, note: 'مناسب برای ازدواج و پیمان‌های عاطفی.'),
  DayQualityInfo(day: 13, quality: DayQuality.nahs, note: 'سنتاً روزی برای احتیاط بیشتر دانسته شده.'),
  DayQualityInfo(day: 14, quality: DayQuality.saad, note: 'روزی خوب برای امور خانوادگی.'),
  DayQualityInfo(day: 15, quality: DayQuality.saad, note: 'میانه‌ی ماه؛ روزی رو به برکت.'),
  DayQualityInfo(day: 16, quality: DayQuality.moderate, note: 'روزی معمولی، مناسب کارهای روتین.'),
  DayQualityInfo(day: 17, quality: DayQuality.saad, note: 'مناسب برای گفت‌وگوهای مهم و مذاکره.'),
  DayQualityInfo(day: 18, quality: DayQuality.moderate, note: 'روزی متعادل؛ نه خیلی مساعد نه نامساعد.'),
  DayQualityInfo(day: 19, quality: DayQuality.nahs, note: 'بهتر است از سفرهای دور پرهیز شود.'),
  DayQualityInfo(day: 20, quality: DayQuality.saad, note: 'روزی مناسب برای شروع کار یا پروژه‌ی تازه.'),
  DayQualityInfo(day: 21, quality: DayQuality.saad, note: 'مناسب برای امور مالی و سرمایه‌گذاری کوچک.'),
  DayQualityInfo(day: 22, quality: DayQuality.moderate, note: 'روزی معمولی برای کارهای روزمره.'),
  DayQualityInfo(day: 23, quality: DayQuality.nahs, note: 'روزی برای احتیاط در تصمیم‌های عجولانه.'),
  DayQualityInfo(day: 24, quality: DayQuality.saad, note: 'مناسب برای آشتی و رفع کدورت‌ها.'),
  DayQualityInfo(day: 25, quality: DayQuality.moderate, note: 'روزی متعادل؛ زمان خوبی برای استراحت.'),
  DayQualityInfo(day: 26, quality: DayQuality.saad, note: 'روزی نیکو برای شروع یادگیری چیزی تازه.'),
  DayQualityInfo(day: 27, quality: DayQuality.nahs, note: 'بهتر است از قرارهای مهم اجتناب شود.'),
  DayQualityInfo(day: 28, quality: DayQuality.saad, note: 'مناسب برای دیدار با خانواده و دوستان.'),
  DayQualityInfo(day: 29, quality: DayQuality.moderate, note: 'روزی معمولی رو به پایان ماه.'),
  DayQualityInfo(day: 30, quality: DayQuality.saad, note: 'پایان ماه با روزی نیکو و پرامید.'),
];
