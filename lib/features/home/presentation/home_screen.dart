import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/feature_access_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../../../core/widgets/zodiac_wheel.dart';
import '../../../core/services/name_service.dart';
import '../../../core/services/birthdate_service.dart';
import '../../../core/services/supabase_config.dart';
import '../../../core/utils/persian_date_converter.dart';

import '../../tarot/presentation/tarot_home_screen.dart';
import '../../tarot/data/tarot_data.dart';
import '../../hafez/presentation/hafez_screen.dart';
import '../../istikhara/presentation/istikhara_screen.dart';
import '../../dream_interpretation/presentation/dream_interpretation_screen.dart';
import '../../daily_fortune/presentation/daily_fortune_card.dart';
import '../../numerology/presentation/destiny_book_promo_card.dart';
import '../../support/presentation/support_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../subscription/presentation/subscription_screen.dart';
import '../../ai_assistant/presentation/ai_assistant_screen.dart';

import '../../../core/services/support_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _name;
  (int, int, int)? _birthdate;
  int _unreadReplies = 0;
  int _successfulReferrals = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await NameService.getFullName();
    final birthdate = await BirthdateService.getBirthdate();
    final unread = await SupportService.getUnreadReplyCount();

    int referrals = 0;

    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        final rows = await supabase
            .from('referral_credits')
            .select('id')
            .eq('referrer_id', user.id);

        referrals = (rows as List).length;
      } catch (_) {
        referrals = 0;
      }
    }

    if (!mounted) return;

    setState(() {
      _name = name;
      _birthdate = birthdate;
      _unreadReplies = unread;
      _successfulReferrals = referrals;
    });
  }

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
                _TopBar(
                  unreadReplies: _unreadReplies,
                  // ⚠️ این قبلاً اشتباهاً به تعبیر خواب وصل شده بود؛
                  // زنگوله باید به پشتیبانی بره، نه یه فال.
                  onNotificationTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SupportScreen()),
                    );
                    _load();
                  },
                  onProfileTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                    _load();
                  },
                ),

                const SizedBox(height: 4),

                _MoonHeader(
                  name: _name,
                  birthdate: _birthdate,
                ),

                const SizedBox(height: 20),

                const _TodayMessageCard(),

                const SizedBox(height: 16),

                _TodayCardAndLuckRow(
                  birthdate: _birthdate,
                ),

                const SizedBox(height: 16),

                const DailyFortuneCard(),

                const SizedBox(height: 16),
                const _DailyMysteryCard(),

                const SizedBox(height: 16),
                const _DailyMissionCard(),

                const SizedBox(height: 16),
                _RelationshipPulseCard(ownBirthdate: _birthdate),

                const SizedBox(height: 20),

                const _QuickActionsRow(),

                const SizedBox(height: 16),

                const DestinyBookPromoCard(),

                const SizedBox(height: 16),

                const _SaffatVersesCard(),

                const SizedBox(height: 24),

                _StatsBar(
                  successfulReferrals: _successfulReferrals,
                ),

                const SizedBox(height: 28),

                const _KawakibFooter(),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TOP BAR
// ============================================================

class _TopBar extends StatelessWidget {
  final int unreadReplies;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const _TopBar({
    required this.unreadReplies,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(21),
          onTap: onNotificationTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.glassBorder,
                  ),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              if (unreadReplies > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadReplies > 9 ? '۹+' : '$unreadReplies',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        Expanded(
          child: Center(
            child: Text(
              'کواکب',
              style: AppTextStyles.displayMedium,
            ),
          ),
        ),

        InkWell(
          borderRadius: BorderRadius.circular(21),
          onTap: onProfileTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.secondaryButtonGradient,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MOON HEADER
// ============================================================

class _MoonHeader extends StatelessWidget {
  final String? name;
  final (int, int, int)? birthdate;

  const _MoonHeader({
    required this.name,
    required this.birthdate,
  });

  static const List<String> _weekdays = [
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنجشنبه',
    'جمعه',
    'شنبه',
    'یکشنبه',
  ];

  static const List<String> _jalaliMonths = [
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

  String get _todayDisplay {
    final now = DateTime.now();

    final jalali = gregorianToJalali(
      now.year,
      now.month,
      now.day,
    );

    final weekday = _weekdays[now.weekday - 1];

    return '$weekday ${jalali.day} ${_jalaliMonths[jalali.month - 1]} ${jalali.year}';
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        (name != null && name!.trim().isNotEmpty)
            ? name!.trim()
            : 'کاربر کواکب';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ZodiacWheel(size: 180),

        const SizedBox(height: 14),

        Text(
          'سلام $displayName 🌙',
          style: AppTextStyles.headlineSmall,
        ),

        const SizedBox(height: 6),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              _todayDisplay,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// TODAY MESSAGE
// ============================================================

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
        border: Border.all(
          color: AppColors.glassBorder,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppColors.gold,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'پیام امروز',
                style: AppTextStyles.cardLabel.copyWith(
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.auto_awesome,
                color: AppColors.gold,
                size: 16,
              ),
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

// ============================================================
// TODAY CARDS
// ============================================================

class _TodayCardAndLuckRow extends StatelessWidget {
  final (int, int, int)? birthdate;

  const _TodayCardAndLuckRow({required this.birthdate});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _TodayTarotCard(birthdate: birthdate)),
        const SizedBox(width: 12),
        Expanded(child: _TodayLuckCard(birthdate: birthdate)),
      ],
    );
  }
}

// ============================================================
// TODAY TAROT — کارت واقعی روزانه، قفل‌شونده پشت اشتراک
// ============================================================

class _TodayTarotCard extends StatefulWidget {
  final (int, int, int)? birthdate;
  const _TodayTarotCard({required this.birthdate});

  @override
  State<_TodayTarotCard> createState() => _TodayTarotCardState();
}

class _TodayTarotCardState extends State<_TodayTarotCard> {
  bool _loadingAccess = true;
  bool _unlocked = false;
  String _requiredTier = 'free';

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  /// کارت امروز: قطعی (نه Random) — بر پایه‌ی تاریخ امروز + تاریخ تولد
  /// کاربر، پس هم هر روز عوض می‌شه هم بین کاربرای مختلف فرق می‌کنه.
  TarotCardData get _todaysCard {
    final now = DateTime.now();
    final dayOfYear = int.parse(
      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
    );
    var seed = dayOfYear;
    if (widget.birthdate != null) {
      final (day, month, year) = widget.birthdate!;
      // ضرایب متفاوت از کارت «شانس امروز» تا دو کارت تصادفاً هم‌زمان عوض نشن
      seed += day * 17 + month * 29 + year * 3;
    }
    return tarotDeck[seed % tarotDeck.length];
  }

  Future<void> _checkAccess() async {
    final userTier = await FeatureAccessService.getCurrentUserTier();
    final requiredTier = await FeatureAccessService.getRequiredTier('daily_tarot');
    final userIndex = FeatureAccessService.tierOrder.indexOf(userTier);
    final requiredIndex = FeatureAccessService.tierOrder.indexOf(requiredTier);
    if (!mounted) return;
    setState(() {
      _unlocked = userIndex >= requiredIndex;
      _requiredTier = requiredTier;
      _loadingAccess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = _todaysCard;

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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2B0D3A), Color(0xFF120620)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGold),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  child: Icon(card.icon, color: AppColors.gold, size: 26),
                ),
                const SizedBox(height: 10),
                Text(
                  card.nameEn,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold, letterSpacing: 1.5, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(card.keyword, style: AppTextStyles.bodySmall.copyWith(fontSize: 9)),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _loadingAccess
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.gold),
                        )
                      : _unlocked
                          ? Text(
                              card.meaning,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall.copyWith(height: 1.7, fontSize: 10.5),
                            )
                          : Text(
                              'تفسیر کامل این کارت فقط برای اعضای ${FeatureAccessService.tierLabels[_requiredTier]} باز است.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall
                                  .copyWith(height: 1.6, fontSize: 10, color: AppColors.textSecondary),
                            ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (!_loadingAccess && !_unlocked)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SubscriptionScreen(preselectedTier: _requiredTier)),
                  );
                },
                child: const Text('دیدن تفسیر کامل'),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                FeatureAccessService.open(
                  context,
                  featureKey: 'tarot',
                  featureTitle: 'تاروت',
                  builder: (_) => const TarotHomeScreen(),
                );
              },
              child: const Text('فال تاروت کامل'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TODAY LUCK
// ============================================================

class _TodayLuckCard extends StatelessWidget {
  final (int, int, int)? birthdate;

  const _TodayLuckCard({
    required this.birthdate,
  });

  static const List<String> _colors = [
    'قرمز',
    'نارنجی',
    'زرد',
    'سبز',
    'آبی',
    'بنفش',
    'صورتی',
    'طلایی',
    'فیروزه‌ای',
  ];

  static const List<Color> _colorSwatches = [
    Color(0xFFD64545),
    Color(0xFFE0A63E),
    Color(0xFFE0D23E),
    Color(0xFF3E9C6E),
    Color(0xFF3E9CE0),
    Color(0xFF8B4FE0),
    Color(0xFFE0507A),
    AppColors.gold,
    Color(0xFF3EC7C7),
  ];

  static const List<String> _hours = [
    '۹:۰۰',
    '۱۱:۰۰',
    '۱۳:۰۰',
    '۱۵:۰۰',
    '۱۶:۳۰',
    '۱۸:۰۰',
    '۲۰:۰۰',
    '۲۱:۳۰',
  ];

  static const List<String> _elements = [
    'آب',
    'آتش',
    'خاک',
    'باد',
  ];

  int _seed() {
    final now = DateTime.now();

    final dayOfYear = int.parse(
      '${now.year}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}',
    );

    if (birthdate == null) {
      return dayOfYear;
    }

    final (day, month, year) = birthdate!;

    return dayOfYear + day * 31 + month * 12 + year;
  }

  @override
  Widget build(BuildContext context) {
    final seed = _seed();

    final colorIndex = seed % _colors.length;
    final numberValue = (seed % 9) + 1;
    final hourValue = _hours[seed % _hours.length];
    final elementValue = _elements[seed % _elements.length];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.glassBorder,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -10,
            left: -10,
            child: Icon(
              Icons.auto_awesome,
              color: AppColors.gold.withOpacity(0.06),
              size: 90,
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'شانس امروز',
                textAlign: TextAlign.center,
                style: AppTextStyles.cardLabel.copyWith(
                  color: AppColors.gold,
                ),
              ),

              const SizedBox(height: 18),

              _LuckItem(
                icon: Icons.circle,
                iconColor: _colorSwatches[colorIndex],
                label: 'رنگ پیشنهادی',
                value: _colors[colorIndex],
              ),

              const SizedBox(height: 16),

              _LuckItem(
                icon: Icons.looks_one_outlined,
                iconColor: AppColors.gold,
                label: 'عدد شانس',
                value: '$numberValue',
              ),

              const SizedBox(height: 16),

              _LuckItem(
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFF8B4FE0),
                label: 'ساعت مناسب',
                value: hourValue,
              ),

              const SizedBox(height: 16),

              const Divider(
                color: AppColors.glassBorder,
                height: 1,
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.spa_outlined,
                    size: 14,
                    color: AppColors.gold.withOpacity(0.8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'عنصر امروز: $elementValue',
                    style: AppTextStyles.bodySmall,
                  ),
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

  const _LuckItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 15,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall,
              ),
              Text(
                value,
                style: AppTextStyles.cardLabel,
              ),
            ],
          ),
        ),
      ],
    );
  }
}


// ============================================================
// DAILY MYSTERY — راز پنهان امروز
// ============================================================

class _DailyMysteryCard extends StatelessWidget {
  const _DailyMysteryCard();

  static const List<String> _messages = [
    'امروز نشانه‌ای کوچک می‌تواند سرنخ یک تصمیم بزرگ باشد.',
    'چیزی که فکر می‌کنی اتفاقی است، شاید تو را به یک انتخاب تازه هدایت کند.',
    'یک گفت‌وگوی کوتاه امروز می‌تواند دیدت را نسبت به موضوعی قدیمی عوض کند.',
    'امروز بیشتر از همیشه به حس درونی‌ات هنگام انتخاب‌ها توجه کن.',
    'یک خبر یا پیام غیرمنتظره ممکن است حال و هوای روزت را تغییر دهد.',
    'کاری که مدت‌ها عقب انداخته‌ای، امروز می‌تواند ساده‌تر از چیزی باشد که فکر می‌کنی.',
    'یک نشانه کوچک در اطرافت ممکن است یادآور هدفی باشد که فراموشش کرده‌ای.',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final message = _messages[seed % _messages.length];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.lock_outline, color: AppColors.gold, size: 17),
            const SizedBox(width: 7),
            Text('راز پنهان امروز', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
          ]),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodySmall.copyWith(height: 1.8)),
          const SizedBox(height: 6),
          Text('تفسیر روزانه و سرگرمی', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 9)),
        ],
      ),
    );
  }
}

// ============================================================
// DAILY MISSION — ماموریت امروز
// ============================================================

class _DailyMissionCard extends StatefulWidget {
  const _DailyMissionCard();
  @override
  State<_DailyMissionCard> createState() => _DailyMissionCardState();
}

class _DailyMissionCardState extends State<_DailyMissionCard> {
  bool _done = false;

  static const List<String> _missions = [
    'امروز یک کار نیمه‌تمام را کامل کن.',
    'امروز ۱۰ دقیقه بدون تلفن برای خودت وقت بگذار.',
    'امروز با یک نفر که دوستش داری تماس بگیر.',
    'امروز یک تصمیم کوچک را بدون بهانه عقب نینداز.',
    'امروز یک کار خوب را بدون انتظار جبران انجام بده.',
    'امروز سه چیز خوب زندگی‌ات را به یاد بیاور.',
    'امروز یک قدم واقعی به سمت هدفت بردار.',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final mission = _missions[seed % _missions.length];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => setState(() => _done = !_done),
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_done ? AppColors.gold : AppColors.glassFill).withOpacity(0.18),
                border: Border.all(color: _done ? AppColors.gold : AppColors.glassBorder),
              ),
              child: Icon(_done ? Icons.check : Icons.flag_outlined, color: _done ? AppColors.gold : AppColors.textSecondary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ماموریت امروز', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
            const SizedBox(height: 5),
            Text(mission, style: AppTextStyles.bodySmall.copyWith(height: 1.6)),
          ])),
          const SizedBox(width: 6),
          Tooltip(message: _done ? 'انجام شد' : 'انجام دادم', child: Icon(_done ? Icons.done_all : Icons.touch_app_outlined, color: _done ? AppColors.gold : AppColors.textSecondary, size: 18)),
        ],
      ),
    );
  }
}

// ============================================================
// RELATIONSHIP PULSE — نبض رابطه
// ============================================================

class _RelationshipPulseCard extends StatefulWidget {
  final (int, int, int)? ownBirthdate;
  const _RelationshipPulseCard({required this.ownBirthdate});

  @override
  State<_RelationshipPulseCard> createState() => _RelationshipPulseCardState();
}

class _RelationshipPulseCardState extends State<_RelationshipPulseCard> {
  String? _personName;
  (int, int, int)? _personBirthdate;

  int _score() {
    final now = DateTime.now();
    var seed = now.year * 10000 + now.month * 100 + now.day;
    if (widget.ownBirthdate != null) {
      final (d, m, y) = widget.ownBirthdate!;
      seed += d * 17 + m * 29 + y * 3;
    }
    if (_personBirthdate != null) {
      final (d, m, y) = _personBirthdate!;
      seed += d * 31 + m * 13 + y * 7;
    }
    return 55 + (seed.abs() % 46);
  }

  Future<void> _configure() async {
    final controller = TextEditingController(text: _personName ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('نبض رابطه'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(labelText: 'نام شخص'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('ادامه')),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || name == null || name.isEmpty) return;

    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1300),
      lastDate: DateTime.now(),
      initialDate: DateTime(1370),
      helpText: 'تاریخ تولد شخص',
    );
    if (!mounted || picked == null) return;

    // در این بخش برای سازگاری با مدل ذخیره‌شده‌ی اپ، تاریخ میلادی به‌صورت
    // ساده نگه داشته می‌شود؛ تاریخ تولد خود کاربر از BirthdateService می‌آید.
    setState(() {
      _personName = name;
      _personBirthdate = (picked.day, picked.month, picked.year);
    });
  }

  @override
  Widget build(BuildContext context) {
    final configured = _personName != null && _personBirthdate != null;
    final score = configured ? _score() : null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.favorite_border, color: AppColors.gold, size: 18),
          const SizedBox(width: 7),
          Text('نبض رابطه', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
        ]),
        const SizedBox(height: 10),
        if (!configured)
          Text('رابطه‌ات را تنظیم کن تا نبض امروز آن را ببینی.', textAlign: TextAlign.center, style: AppTextStyles.bodySmall)
        else ...[
          Text('امروز تو و $_personName', style: AppTextStyles.bodySmall),
          const SizedBox(height: 4),
          Text('$score٪', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.gold)),
          const SizedBox(height: 3),
          Text(score! >= 85 ? 'هماهنگی امروز بالاست.' : score >= 70 ? 'امروز برای گفت‌وگوی آرام مناسب است.' : 'امروز کمی صبوری و درک متقابل بیشتر لازم است.', textAlign: TextAlign.center, style: AppTextStyles.bodySmall),
        ],
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton(onPressed: _configure, child: Text(configured ? 'تغییر شخص' : 'تنظیم رابطه')),
          const SizedBox(width: 6),
          OutlinedButton(
            onPressed: () => FeatureAccessService.open(
              context,
              featureKey: 'relationship_pulse',
              featureTitle: 'نبض رابطه',
              builder: (_) => _RelationshipPulseFullScreen(personName: _personName, score: score),
            ),
            child: const Text('جزئیات'),
          ),
        ]),
      ]),
    );
  }
}

class _RelationshipPulseFullScreen extends StatelessWidget {
  final String? personName;
  final int? score;
  const _RelationshipPulseFullScreen({required this.personName, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نبض رابطه')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.favorite, color: AppColors.gold, size: 52),
            const SizedBox(height: 16),
            Text(personName == null ? 'رابطه هنوز تنظیم نشده' : 'نبض رابطه با $personName', textAlign: TextAlign.center, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 12),
            if (score != null) Text('$score٪', style: AppTextStyles.displayMedium.copyWith(color: AppColors.gold)),
            const SizedBox(height: 12),
            Text('این نتیجه برای سرگرمی و خودشناسی است و مبنای قطعی برای تصمیم‌گیری درباره روابط نیست.', textAlign: TextAlign.center, style: AppTextStyles.bodySmall),
          ]),
        ),
      ),
    );
  }
}

// ============================================================
// QUICK ACTIONS
// ============================================================

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  // ⚠️ قبلاً هر آیتم مستقیم Navigator.push می‌کرد، بدون چک اشتراک.
  // الان همه (به‌جز دستیار هوشمند که فالِ قفل‌شونده نیست) از
  // FeatureAccessService عبور می‌کنن، دقیقاً با همون featureKeyهایی
  // که تو fal_list_screen.dart و پنل ادمین استفاده می‌شن.
  //
  // «دستیار هوشمند» قبلاً یه PlaceholderScreen با پیام «به‌زودی»
  // باز می‌کرد. الان که دستیار هوشمند واقعی تو نوار پایین کار
  // می‌کنه، مستقیم همون صفحه‌ی واقعی رو باز می‌کنیم.
  static final List<_QuickAction> _items = [
    _QuickAction(
      'فال حافظ',
      Icons.menu_book_outlined,
      const Color(0xFF6B2DD9),
      (context) {
        FeatureAccessService.open(
          context,
          featureKey: 'hafez',
          featureTitle: 'فال حافظ',
          builder: (_) => const HafezScreen(),
        );
      },
    ),
    _QuickAction(
      'استخاره',
      Icons.circle_outlined,
      const Color(0xFF1E8E7E),
      (context) {
        FeatureAccessService.open(
          context,
          featureKey: 'istikhara',
          featureTitle: 'استخاره',
          builder: (_) => const IstikharaScreen(),
        );
      },
    ),
    _QuickAction(
      'تعبیر خواب',
      Icons.nightlight_outlined,
      const Color(0xFF3E6FE0),
      (context) {
        FeatureAccessService.open(
          context,
          featureKey: 'dream_interpretation',
          featureTitle: 'تعبیر خواب',
          builder: (_) => const DreamInterpretationScreen(),
        );
      },
    ),
    _QuickAction(
      'دستیار هوشمند',
      Icons.auto_awesome,
      const Color(0xFF9C3EE0),
      (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AiAssistantScreen(),
          ),
        );
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        _items.length,
        (index) {
          final item = _items[index];

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 8,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => item.onTap(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.glassBorder,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            color: item.color,
                            size: 20,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.cardLabel.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final void Function(BuildContext) onTap;

  _QuickAction(
    this.title,
    this.icon,
    this.color,
    this.onTap,
  );
}

// ============================================================
// SAFFAT
// ============================================================

class _SaffatVerse {
  final int number;
  final String arabic;
  final String translation;

  const _SaffatVerse(
    this.number,
    this.arabic,
    this.translation,
  );
}

const List<_SaffatVerse> _saffatVerses = [
  _SaffatVerse(
    1,
    'وَالصَّافَّاتِ صَفًّا',
    'سوگند به صف‌بستگان که صفی [منظم] بسته‌اند،',
  ),
  _SaffatVerse(
    2,
    'فَالزَّاجِرَاتِ زَجْرًا',
    'و به بازدارندگان که [انسان‌ها را از گناه] به‌شدت باز می‌دارند،',
  ),
  _SaffatVerse(
    3,
'فَالتَّالِيَاتِ ذِكْرًا',
    'و به تلاوت‌کنندگان ذکر [آیات الهی]،',
  ),
  _SaffatVerse(
    4,
    'إِنَّ إِلَٰهَكُمْ لَوَاحِدٌ',
    'که معبود شما یکی است؛',
  ),
  _SaffatVerse(
    5,
    'رَّبُّ السَّمَاوَاتِ وَالْأَرْضِ وَمَا بَيْنَهُمَا وَرَبُّ الْمَشَارِقِ',
    'پروردگار آسمان‌ها و زمین و آنچه میان آن‌هاست، و پروردگار مشرق‌ها،',
  ),
  _SaffatVerse(
    6,
    'إِنَّا زَيَّنَّا السَّمَاءَ الدُّنْيَا بِزِينَةٍ الْكَوَاكِبِ',
    'ما آسمان دنیا را با ستارگان زینت بخشیدیم،',
  ),
  _SaffatVerse(
    7,
    'وَحِفْظًا مِّن كُلِّ شَيْطَانٍ مَّارِدٍ',
    'و آن را از هر شیطان سرکش محفوظ داشتیم؛',
  ),
  _SaffatVerse(
    8,
    'لَّا يَسَّمَّعُونَ إِلَى الْمَلَإِ الْأَعْلَىٰ وَيُقْذَفُونَ مِن كُلِّ جَانِبٍ',
    'نمی‌توانند به [سخنان] فرشتگان بالا گوش دهند و از هر طرف رانده می‌شوند،',
  ),
  _SaffatVerse(
    9,
    'دُحُورًا ۖ وَلَهُمْ عَذَابٌ وَاصِبٌ',
    'تا رانده شوند و برایشان عذابی پیوسته است؛',
  ),
  _SaffatVerse(
    10,
    'إِلَّا مَنْ خَطِفَ الْخَطْفَةَ فَأَتْبَعَهُ شِهَابٌ ثَاقِبٌ',
    'مگر کسی که ناگهان چیزی برباید، که شهابی شکافنده دنبالش می‌آید.',
  ),
];

class _SaffatVersesCard extends StatefulWidget {
  const _SaffatVersesCard();

  @override
  State<_SaffatVersesCard> createState() =>
      _SaffatVersesCardState();
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
        border: Border.all(
          color: AppColors.glassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.gold,
                  size: 18,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    'سوره صافات — ۱۰ آیه نخست',
                    style: AppTextStyles.cardLabel.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                ),

                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
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
              style: AppTextStyles.bodyLarge.copyWith(
                height: 1.8,
                fontSize: 17,
              ),
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
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gold,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          verse.arabic,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodyLarge.copyWith(
                            height: 1.8,
                            fontSize: 17,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          verse.translation,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (verse.number != _saffatVerses.length) ...[
                const SizedBox(height: 10),
                const Divider(
                  color: AppColors.glassBorder,
                  height: 1,
                ),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

// ============================================================
// STATS BAR
// ============================================================

class _StatsBar extends StatelessWidget {
  final int successfulReferrals;

  const _StatsBar({
    required this.successfulReferrals,
  });

  @override
  Widget build(BuildContext context) {
    final points = successfulReferrals * 100;

    final pointsDisplay = points.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );

    final subtitle = successfulReferrals == 0
        ? 'دوستاتو دعوت کن، امتیاز بگیر'
        : 'آفرین! عالی پیش می‌روی';

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.glassBorder,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.military_tech,
            color: AppColors.gold,
            size: 26,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  pointsDisplay,
                  style: AppTextStyles.cardLabel,
                ),
                Text(
                  'امتیاز کل',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          Container(
            width: 1,
            height: 30,
            color: AppColors.glassBorder,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '$successfulReferrals معرفی',
                  style: AppTextStyles.cardLabel,
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          const Icon(
            Icons.people_alt_outlined,
            color: Color(0xFFE0A63E),
            size: 26,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// KAWAKIB FOOTER
// ============================================================

class _KawakibFooter extends StatelessWidget {
  const _KawakibFooter();

  static const String _enamadUrl =
      'https://trustseal.enamad.ir/?id=7449551&Code=n0sdd9mipg5gIDGP6zqx7tlXz5Tyv70E';

  static const String _enamadLogoUrl =
      'https://trustseal.enamad.ir/logo.aspx?id=7449551&Code=n0sdd9mipg5gIDGP6zqx7tlXz5Tyv70E';

  static const String _supportEmail = 'ms.kawakeb@gmail.com';

  Future<void> _openEnamad() async {
    final uri = Uri.parse(_enamadUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> _openEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: const {
        'subject': 'پشتیبانی کواکب',
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openInfoPage(
    BuildContext context,
    String title,
    IconData icon,
    List<InfoSection> sections,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KawakebInfoScreen(
          title: title,
          icon: icon,
          sections: sections,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Text(
            'کواکب',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'سرگرمی، خودشناسی و الهام',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 2,
            children: [
              TextButton(
                onPressed: () {
                  _openInfoPage(
                    context,
                    'قوانین و مقررات',
                    Icons.gavel_outlined,
                    const [
                      InfoSection(
                        title: 'درباره کواکب',
                        text:
                            'کواکب یک پلتفرم سرگرمی، خودشناسی و الهام است که محتواهایی مانند تاروت، فال حافظ، استخاره، تعبیر خواب، طالع‌بینی و سایر خدمات مرتبط را در اختیار کاربران قرار می‌دهد.',
                      ),
                      InfoSection(
                        title: 'ماهیت محتوا',
                        text:
                            'محتوا و نتایج ارائه‌شده در کواکب جنبه سرگرمی، خودشناسی و تأمل شخصی دارند و نباید به عنوان پیش‌بینی قطعی آینده یا جایگزین مشاوره تخصصی پزشکی، روان‌شناسی، حقوقی یا مالی تلقی شوند.',
                      ),
                      InfoSection(
                        title: 'حساب کاربری',
                        text:
                            'کاربر مسئول حفظ اطلاعات حساب کاربری خود و استفاده صحیح از خدمات کواکب است. هرگونه تلاش برای سوءاستفاده از سامانه، ایجاد حساب‌های متعدد برای دور زدن محدودیت‌ها یا دسترسی غیرمجاز به امکانات ممنوع است.',
                      ),
                      InfoSection(
                        title: 'اشتراک‌ها',
                        text:
                            'امکانات و محتوای ویژه بر اساس نوع اشتراک انتخاب‌شده در اختیار کاربر قرار می‌گیرد. مدت اعتبار و سطح دسترسی هر اشتراک مطابق اطلاعات نمایش‌داده‌شده هنگام خرید است.',
                      ),
                      InfoSection(
                        title: 'پرداخت و بازگشت وجه',
                        text:
                            'پرداخت‌های مربوط به خرید اشتراک از طریق درگاه پرداخت انجام می‌شود. شرایط لغو یا بازگشت وجه تابع مقررات و شرایط اعلام‌شده هنگام خرید و قوانین مربوطه خواهد بود.',
                      ),
                      InfoSection(
                        title: 'تغییر قوانین',
                        text:
                            'کواکب می‌تواند در صورت نیاز قوانین و شرایط استفاده از خدمات را به‌روزرسانی کند. ادامه استفاده از خدمات پس از اعمال تغییرات به منزله پذیرش شرایط جدید خواهد بود.',
                      ),
                    ],
                  );
                },
                child: const Text('قوانین و مقررات'),
              ),
              TextButton(
                onPressed: () {
                  _openInfoPage(
                    context,
                    'حریم خصوصی',
                    Icons.privacy_tip_outlined,
                    const [
                      InfoSection(
                        title: 'اطلاعاتی که دریافت می‌کنیم',
                        text:
                            'برای ارائه بهتر خدمات ممکن است اطلاعاتی مانند نام، تاریخ تولد، اطلاعات حساب کاربری و اطلاعات موردنیاز برای استفاده از امکانات برنامه دریافت و نگهداری شود.',
                      ),
                      InfoSection(
                        title: 'نحوه استفاده از اطلاعات',
                        text:
                            'اطلاعات کاربران برای ایجاد و مدیریت حساب، شخصی‌سازی برخی خدمات، ارائه نتایج مرتبط، پشتیبانی و بهبود عملکرد کواکب استفاده می‌شود.',
                      ),
                      InfoSection(
                        title: 'اطلاعات پرداخت',
                        text:
                            'پرداخت‌ها از طریق درگاه پرداخت انجام می‌شوند. اطلاعات محرمانه کارت بانکی مانند رمز کارت و رمز پویا توسط کواکب دریافت یا ذخیره نمی‌شود.',
                      ),
                      InfoSection(
                        title: 'حفاظت از اطلاعات',
                        text:
                            'کواکب تلاش می‌کند اطلاعات کاربران را در برابر دسترسی غیرمجاز، سوءاستفاده یا افشای غیرضروری محافظت کند.',
                      ),
                      InfoSection(
                        title: 'اشتراک‌گذاری اطلاعات',
                        text:
                            'اطلاعات شخصی کاربران بدون مجوز قانونی یا رضایت کاربر در اختیار اشخاص غیرمرتبط قرار نخواهد گرفت؛ مگر در مواردی که ارائه اطلاعات بر اساس قانون الزامی باشد.',
                      ),
                      InfoSection(
                        title: 'درخواست کاربر',
                        text:
                            'در صورت وجود امکان فنی و قانونی، کاربر می‌تواند برای اصلاح اطلاعات حساب یا درخواست حذف اطلاعات خود از طریق بخش پشتیبانی با کواکب در ارتباط باشد.',
                      ),
                    ],
                  );
                },
                child: const Text('حریم خصوصی'),
              ),
              TextButton(
                onPressed: () {
                  _openInfoPage(
                    context,
                    'تماس با ما',
                    Icons.support_agent_outlined,
                    const [
                      InfoSection(
                        title: 'پشتیبانی کواکب',
                        text:
                            'برای پیگیری سریع‌تر، پیشنهاد می‌کنیم ابتدا از بخش پشتیبانی داخل برنامه یک تیکت ثبت کنید. تیم پشتیبانی درخواست شما را بررسی کرده و پاسخ را در همان بخش اعلام می‌کند.',
                      ),
                      InfoSection(
                        title: 'تماس از طریق ایمیل',
                        text:
                            'در صورت تمایل می‌توانید درخواست یا مشکل خود را به ایمیل پشتیبانی کواکب ارسال کنید:',
                      ),
                      InfoSection(
                        title: 'موضوعات قابل پیگیری',
                        text:
                            'مشکلات پرداخت و اشتراک، فعال نشدن امکانات، مشکلات حساب کاربری، خطاهای برنامه، پیشنهادها و گزارش مشکلات فنی از طریق پشتیبانی قابل پیگیری هستند.',
                      ),
                    ],

                  );
                },
                child: const Text('تماس با ما'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.glassBorder, height: 1),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 14,
            children: [
              InkWell(
                onTap: _openEnamad,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 115,
                  height: 105,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.network(
                          _enamadLogoUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.verified_user_outlined,
                              color: Colors.blueGrey,
                              size: 46,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'نماد اعتماد',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 115,
                height: 105,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withOpacity(0.10),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.gold,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'زرین‌پال',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '© کواکب — تمامی حقوق محفوظ است',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// KAWAKEB INFO SCREEN
// ============================================================

class InfoSection {
  final String title;
  final String text;

  const InfoSection({
    required this.title,
    required this.text,
  });
}

class KawakebInfoScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<InfoSection> sections;
  final bool contactActions;

  const KawakebInfoScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.sections,
    this.contactActions = false,
  });

  Future<void> _openEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'ms.kawakeb@gmail.com',
      queryParameters: const {
        'subject': 'پشتیبانی کواکب',
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(title, style: AppTextStyles.headlineSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
              children: [
                Container(
                  width: 68,
                  height: 68,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withOpacity(0.12),
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.35),
                    ),
                  ),
                  child: Icon(icon, color: AppColors.gold, size: 30),
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 24),
                ...sections.map(
                  (section) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.glassFill,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            section.title,
                            textAlign: TextAlign.right,
                            style: AppTextStyles.cardLabel.copyWith(
                              color: AppColors.gold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            section.text,
                            textAlign: TextAlign.right,
                            style: AppTextStyles.bodyMedium.copyWith(
                              height: 1.9,
                            ),
                          ),
                          if (contactActions &&
                              section.title == 'تماس از طریق ایمیل') ...[
                            const SizedBox(height: 12),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                'ms.kawakeb@gmail.com',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.cardLabel.copyWith(
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (contactActions) ...[
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SupportScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.support_agent_outlined),
                      label: const Text('ثبت تیکت در پشتیبانی'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openEmail,
                      icon: const Icon(Icons.email_outlined),
                      label: const Text('ارسال پیام به ایمیل پشتیبانی'),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'کواکب — سرگرمی، خودشناسی و الهام',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
