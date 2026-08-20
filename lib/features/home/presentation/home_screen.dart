import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../../../core/widgets/zodiac_wheel.dart';
import '../../tarot/presentation/tarot_home_screen.dart';
import '../../hafez/presentation/hafez_screen.dart';
import '../../istikhara/presentation/istikhara_screen.dart';
import '../../../shared/placeholder_screen.dart';
import '../../dream_interpretation/presentation/dream_interpretation_screen.dart';
import '../../daily_fortune/presentation/daily_fortune_card.dart';
import '../../numerology/presentation/destiny_book_promo_card.dart';
String _todayJalali() {
  final now = DateTime.now();

  final result = _gregorianToJalali(
    now.year,
    now.month,
    now.day,
  );

  const weekdays = [
    '',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنجشنبه',
    'جمعه',
    'شنبه',
    'یکشنبه',
  ];

  const months = [
    '',
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  return '${weekdays[now.weekday]} '
      '${_toPersianDigits(result[2].toString())} '
      '${months[result[1]]} '
      '${_toPersianDigits(result[0].toString())}';
}

List<int> _gregorianToJalali(int gy, int gm, int gd) {
  const gDays = [
    0,
    31,
    59,
    90,
    120,
    151,
    181,
    212,
    243,
    273,
    304,
    334,
  ];

  const jDays = [
    0,
    31,
    62,
    93,
    124,
    155,
    186,
    216,
    246,
    276,
    306,
    336,
  ];

  final gy2 = gm > 2 ? gy + 1 : gy;

  int days = 355666 +
      (365 * gy) +
      ((gy2 + 3) ~/ 4) -
      ((gy2 + 99) ~/ 100) +
      ((gy2 + 399) ~/ 400) +
      gd +
      gDays[gm - 1];

  int jy = -1595 + 33 * (days ~/ 12053);
  days %= 12053;

  jy += 4 * (days ~/ 1461);
  days %= 1461;

  if (days > 365) {
    jy += (days - 1) ~/ 365;
    days = (days - 1) % 365;
  }

  int jm;
  int jd;

  if (days < 186) {
    jm = 1 + (days ~/ 31);
    jd = 1 + (days % 31);
  } else {
    jm = 7 + ((days - 186) ~/ 30);
    jd = 1 + ((days - 186) % 30);
  }

  return [jy, jm, jd];
}

String _toPersianDigits(String value) {
  const english = '0123456789';
  const persian = '۰۱۲۳۴۵۶۷۸۹';

  return value.split('').map((char) {
    final index = english.indexOf(char);
    return index == -1 ? char : persian[index];
  }).join();
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              children: [
                const _TopBar(),
                const SizedBox(height: 4),
                const _MoonHeader(),
                const SizedBox(height: 20),
                const _TodayMessageCard(),
                const SizedBox(height: 16),
                _TodayCardAndLuckRow(),
                const SizedBox(height: 16),
                const DailyFortuneCard(),
                const SizedBox(height: 20),
                _QuickActionsRow(),
                const SizedBox(height: 16),
                const DestinyBookPromoCard(),
                const SizedBox(height: 16),
                const _SaffatVersesCard(),
                const SizedBox(height: 24),
                const _StatsBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 20),
        ),
        Expanded(
          child: Center(child: Text('کواکب', style: AppTextStyles.displayMedium)),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.secondaryButtonGradient),
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}

class _MoonHeader extends StatelessWidget {
  const _MoonHeader();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ZodiacWheel(size: 180),
        const SizedBox(height: 14),
        Text('سلام مرتضی 🌙', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(_todayJalali(), style: AppTextStyles.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _TodayMessageCard extends StatelessWidget {
  const _TodayMessageCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.gold, size: 16),
              const SizedBox(width: 6),
              Text('پیام امروز', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
              const SizedBox(width: 6),
              const Icon(Icons.auto_awesome, color: AppColors.gold, size: 16),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'امروز زمان خوبی برای شروع کارهای نیمه‌تمام است.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _TodayCardAndLuckRow extends StatelessWidget {
  const _TodayCardAndLuckRow();
  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _TodayTarotCard()),
        SizedBox(width: 12),
        Expanded(child: _TodayLuckCard()),
      ],
    );
  }
}

class _TodayTarotCard extends StatelessWidget {
  const _TodayTarotCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('✦ کارت امروز ✦', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 175,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2B0D3A), Color(0xFF120620)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderGold),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Icon(Icons.star, color: AppColors.gold.withOpacity(0.25), size: 12),
                  ),
                  Positioned(
                    bottom: 18,
                    right: 16,
                    child: Icon(Icons.star, color: AppColors.gold.withOpacity(0.2), size: 9),
                  ),
                  Positioned(
                    top: 24,
                    right: 20,
                    child: Icon(Icons.star, color: AppColors.gold.withOpacity(0.15), size: 7),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                      gradient: RadialGradient(
                        colors: [AppColors.gold.withOpacity(0.15), Colors.transparent],
                      ),
                    ),
                    child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 26),
                  ),
                  Positioned(
                    bottom: 18,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('THE STAR', style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold, letterSpacing: 1.5, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text('امید و الهام', style: AppTextStyles.bodySmall.copyWith(fontSize: 9)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TarotHomeScreen()),
                );
              },
              child: const Text('مشاهده تفسیر'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayLuckCard extends StatelessWidget {
  const _TodayLuckCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -10,
            left: -10,
            child: Icon(Icons.auto_awesome, color: AppColors.gold.withOpacity(0.06), size: 90),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('شانس امروز', textAlign: TextAlign.center, style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
              const SizedBox(height: 18),
              const _LuckItem(icon: Icons.circle, iconColor: Color(0xFF3E9CE0), label: 'رنگ پیشنهادی', value: 'آبی'),
              const SizedBox(height: 16),
              const _LuckItem(icon: Icons.looks_one_outlined, iconColor: AppColors.gold, label: 'عدد شانس', value: '۷'),
              const SizedBox(height: 16),
              const _LuckItem(icon: Icons.access_time_rounded, iconColor: Color(0xFF8B4FE0), label: 'ساعت مناسب', value: '۱۸:۰۰'),
              const SizedBox(height: 16),
              const Divider(color: AppColors.glassBorder, height: 1),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.spa_outlined, size: 14, color: AppColors.gold.withOpacity(0.8)),
                  const SizedBox(width: 6),
                  Text('عنصر امروز: آب', style: AppTextStyles.bodySmall),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LuckItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _LuckItem({required this.icon, required this.iconColor, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.18), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              Text(value, style: AppTextStyles.cardLabel),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  static final List<_QuickAction> _items = [
    _QuickAction('فال حافظ', Icons.menu_book_outlined, const Color(0xFF6B2DD9), (context) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HafezScreen()));
    }),
    _QuickAction('استخاره', Icons.circle_outlined, const Color(0xFF1E8E7E), (context) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const IstikharaScreen()));
    }),
    _QuickAction('تعبیر خواب', Icons.nightlight_outlined, const Color(0xFF3E6FE0), (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DreamInterpretationScreen()),
      );
    }),
    _QuickAction('دستیار هوشمند', Icons.auto_awesome, const Color(0xFF9C3EE0), (context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'دستیار هوشمند', icon: Icons.auto_awesome),
        ),
      );
    }),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_items.length, (index) {
        final item = _items[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => item.onTap(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.glassFill,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: item.color.withOpacity(0.2), shape: BoxShape.circle),
                        child: Icon(item.icon, color: item.color, size: 20),
                      ),
                      const SizedBox(height: 8),
                      Text(item.title, textAlign: TextAlign.center, style: AppTextStyles.cardLabel.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final void Function(BuildContext) onTap;
  _QuickAction(this.title, this.icon, this.color, this.onTap);
}

class _SaffatVerse {
  final int number;
  final String arabic;
  final String translation;
  const _SaffatVerse(this.number, this.arabic, this.translation);
}

const List<_SaffatVerse> _saffatVerses = [
  _SaffatVerse(1, 'وَالصَّافَّاتِ صَفًّا', 'سوگند به صف‌بستگان که صفی [منظم] بسته‌اند،'),
  _SaffatVerse(2, 'فَالزَّاجِرَاتِ زَجْرًا', 'و به بازدارندگان که [انسان‌ها را از گناه] به‌شدت باز می‌دارند،'),
  _SaffatVerse(3, 'فَالتَّالِيَاتِ ذِكْرًا', 'و به تلاوت‌کنندگان ذکر [آیات الهی]،'),
  _SaffatVerse(4, 'إِنَّ إِلَٰهَكُمْ لَوَاحِدٌ', 'که معبود شما یکی است؛'),
  _SaffatVerse(5, 'رَّبُّ السَّمَاوَاتِ وَالْأَرْضِ وَمَا بَيْنَهُمَا وَرَبُّ الْمَشَارِقِ',
      'پروردگار آسمان‌ها و زمین و آنچه میان آن‌هاست، و پروردگار مشرق‌ها،'),
  _SaffatVerse(6, 'إِنَّا زَيَّنَّا السَّمَاءَ الدُّنْيَا بِزِينَةٍ الْكَوَاكِبِ',
      'ما آسمان دنیا را با ستارگان زینت بخشیدیم،'),
  _SaffatVerse(7, 'وَحِفْظًا مِّن كُلِّ شَيْطَانٍ مَّارِدٍ', 'و آن را از هر شیطان سرکش محفوظ داشتیم؛'),
  _SaffatVerse(8, 'لَّا يَسَّمَّعُونَ إِلَى الْمَلَإِ الْأَعْلَىٰ وَيُقْذَفُونَ مِن كُلِّ جَانِبٍ',
      'نمی‌توانند به [سخنان] فرشتگان بالا گوش دهند و از هر طرف رانده می‌شوند،'),
  _SaffatVerse(9, 'دُحُورًا ۖ وَلَهُمْ عَذَابٌ وَاصِبٌ', 'تا رانده شوند و برایشان عذابی پیوسته است؛'),
  _SaffatVerse(10, 'إِلَّا مَنْ خَطِفَ الْخَطْفَةَ فَأَتْبَعَهُ شِهَابٌ ثَاقِبٌ',
      'مگر کسی که ناگهان چیزی برباید، که شهابی شکافنده دنبالش می‌آید.'),
];

class _SaffatVersesCard extends StatefulWidget {
  const _SaffatVersesCard();

  @override
  State<_SaffatVersesCard> createState() => _SaffatVersesCardState();
}

class _SaffatVersesCardState extends State<_SaffatVersesCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                const Icon(Icons.menu_book_outlined, color: AppColors.gold, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'سوره صافات — ۱۰ آیه نخست',
                    style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold),
                  ),
                ),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.gold,
                ),
              ],
            ),
          ),
          if (!_expanded) ...[
            const SizedBox(height: 10),
            Text(
              _saffatVerses.first.arabic,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.8, fontSize: 17),
            ),
          ] else ...[
            const SizedBox(height: 14),
            for (final verse in _saffatVerses) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${verse.number}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          verse.arabic,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodyLarge.copyWith(height: 1.8, fontSize: 17),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          verse.translation,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (verse.number != _saffatVerses.length) ...[
                const SizedBox(height: 10),
                const Divider(color: AppColors.glassBorder, height: 1),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.military_tech, color: AppColors.gold, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('۲,۴۵۰', style: AppTextStyles.cardLabel),
                Text('امتیاز کل', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Container(width: 1, height: 30, color: AppColors.glassBorder),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('۱۲ روز', style: AppTextStyles.cardLabel),
                Text('آفرین! عالی پیش می‌روی', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.local_fire_department, color: Color(0xFFE0A63E), size: 26),
        ],
      ),
    );
  }
}
