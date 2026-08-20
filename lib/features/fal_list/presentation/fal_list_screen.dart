import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../../../core/services/supabase_config.dart';
import '../../tarot/presentation/tarot_home_screen.dart';
import '../../hafez/presentation/hafez_screen.dart';
import '../../istikhara/presentation/istikhara_screen.dart';
import '../../dream_interpretation/presentation/dream_interpretation_screen.dart';
import '../../love/presentation/love_screen.dart';
import '../../coffee/presentation/coffee_screen.dart';
import '../../candle/presentation/candle_screen.dart';
import '../../numerology/presentation/numerology_dashboard_screen.dart';
import '../../zodiac/presentation/zodiac_screen.dart';
import '../../chinese_zodiac/presentation/chinese_zodiac_screen.dart';
import '../../rashi/presentation/rashi_screen.dart';
import '../../finance/presentation/finance_screen.dart';
import '../../career/presentation/career_screen.dart';
import '../../angel/presentation/angel_screen.dart';
import '../../gypsy/presentation/gypsy_screen.dart';
import '../../abjad/presentation/abjad_screen.dart';
import '../../saad_nahs/presentation/saad_nahs_screen.dart';
import '../../qamar_aqrab/presentation/qamar_aqrab_screen.dart';
import '../../sar_ketab/presentation/sar_ketab_screen.dart';
import '../../jafr/presentation/jafr_screen.dart';

const List<String> _tierOrder = ['free', 'gold', 'vip'];

const Map<String, String> _tierLabels = {
  'free': 'رایگان',
  'gold': 'طلایی',
  'vip': 'VIP',
};

const Map<String, Color> _tierColors = {
  'free': AppColors.textSecondary,
  'gold': AppColors.gold,
  'vip': Color(0xFF9C3EE0),
};

class FalListScreen extends StatefulWidget {
  const FalListScreen({super.key});

  @override
  State<FalListScreen> createState() => _FalListScreenState();
}

class _FalListScreenState extends State<FalListScreen> {
  bool _loading = true;
  String _userTier = 'free';
  Map<String, String> _featureTiers = {}; // feature_key -> tier لازم

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = supabase.auth.currentUser;
      String userTier = 'free';
      if (user != null) {
        final sub = await supabase
            .from('subscriptions')
            .select('tier')
            .eq('user_id', user.id)
            .maybeSingle();
        if (sub != null) userTier = sub['tier'] as String;
      }

      final rows = await supabase.from('feature_access').select('feature_key, tier');
      final map = <String, String>{
        for (final r in rows as List) (r['feature_key'] as String): (r['tier'] as String),
      };

      if (!mounted) return;
      setState(() {
        _userTier = userTier;
        _featureTiers = map;
        _loading = false;
      });
    } catch (e) {
      // اگه به هر دلیلی نشد بخونیم، برای جلوگیری از قفل‌شدن کل صفحه همه رو رایگان فرض می‌کنیم
      if (!mounted) return;
      setState(() {
        _userTier = 'free';
        _featureTiers = {};
        _loading = false;
      });
    }
  }

  /// سطح لازم برای یک فال؛ اگه تو جدول تعریف نشده باشه، یعنی رایگانه.
  String _requiredTierFor(String key) => _featureTiers[key] ?? 'free';

  bool _isUnlocked(String requiredTier) {
    final userIndex = _tierOrder.indexOf(_userTier);
    final requiredIndex = _tierOrder.indexOf(requiredTier);
    return userIndex >= requiredIndex;
  }

  void _onTapItem(_FalItem item) {
    final requiredTier = _requiredTierFor(item.key);
    if (_isUnlocked(requiredTier)) {
      Navigator.of(context).push(MaterialPageRoute(builder: item.builder));
    } else {
      _showUpgradeDialog(item, requiredTier);
    }
  }

  void _showUpgradeDialog(_FalItem item, String requiredTier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(item.title),
        content: Text(
          'این فال مخصوص اشتراک ${_tierLabels[requiredTier]} است. برای دسترسی، اشتراکت رو ارتقا بده.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('باشه')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _FalItem('tarot', 'تاروت', Icons.style_outlined, const Color(0xFF6B2DD9), (ctx) => const TarotHomeScreen()),
      _FalItem('hafez', 'فال حافظ', Icons.menu_book_outlined, const Color(0xFFB9862F), (ctx) => const HafezScreen()),
      _FalItem('istikhara', 'استخاره', Icons.circle_outlined, const Color(0xFF1E8E7E), (ctx) => const IstikharaScreen()),
      _FalItem('sar_ketab', 'سرکتاب', Icons.auto_stories, const Color(0xFFB9862F), (ctx) => const SarKetabScreen()),
      _FalItem('dream_interpretation', 'تعبیر خواب', Icons.nightlight_outlined, const Color(0xFF3E6FE0), (ctx) => const DreamInterpretationScreen()),
      _FalItem('love', 'فال عشق', Icons.favorite_outline, const Color(0xFFE0507A), (ctx) => const LoveFortuneScreen()),
      _FalItem('coffee', 'فال قهوه', Icons.coffee_outlined, const Color(0xFF8B5A2B), (ctx) => const CoffeeFortuneScreen()),
      _FalItem('candle', 'فال شمع', Icons.local_fire_department_outlined, const Color(0xFFE0A63E), (ctx) => const CandleFortuneScreen()),
      _FalItem('numerology', 'کتاب سرنوشت', Icons.auto_stories_outlined, const Color(0xFF3E6FE0), (ctx) => const NumerologyDashboardScreen()),
      _FalItem('zodiac', 'طالع‌بینی کامل', Icons.brightness_7_outlined, const Color(0xFFB9862F), (ctx) => const ZodiacScreen()),
      _FalItem('chinese_zodiac', 'طالع‌بینی چینی', Icons.pets_outlined, const Color(0xFFD65A5A), (ctx) => const ChineseZodiacScreen()),
      _FalItem('rashi', 'طالع‌بینی هندی', Icons.self_improvement_outlined, const Color(0xFFE0A63E), (ctx) => const RashiScreen()),
      _FalItem('finance', 'فال مالی', Icons.account_balance_wallet_outlined, const Color(0xFF3E9C6E), (ctx) => const FinanceFortuneScreen()),
      _FalItem('career', 'فال شغلی', Icons.work_outline, const Color(0xFF3E6FE0), (ctx) => const CareerFortuneScreen()),
      _FalItem('angel', 'فال فرشتگان', Icons.auto_awesome_outlined, const Color(0xFF9C3EE0), (ctx) => const AngelFortuneScreen()),
      _FalItem('gypsy', 'فال کولی', Icons.style_outlined, const Color(0xFF6B2DD9), (ctx) => const GypsyFortuneScreen()),
      _FalItem('abjad', 'اذکار و ابجد', Icons.auto_stories_outlined, const Color(0xFF6B2DD9), (ctx) => const AbjadScreen()),
      _FalItem('saad_nahs', 'سعد و نحس ایام', Icons.calendar_month_outlined, const Color(0xFF3E9C6E), (ctx) => const SaadNahsScreen()),
      _FalItem('qamar_aqrab', 'قمر در عقرب', Icons.nightlight_round, const Color(0xFFE05A5A), (ctx) => const QamarAqrabScreen()),
      _FalItem('jafr', 'جفر', Icons.auto_fix_high_outlined, const Color(0xFF9C3EE0), (ctx) => const JafrScreen()),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SizedBox(height: 8),
                      Text('فال‌ها', style: AppTextStyles.displayMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      LayoutBuilder(
  builder: (context, constraints) {
    final isDesktop = constraints.maxWidth >= 900;
    final crossAxisCount = isDesktop ? 4 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: isDesktop ? 2.15 : 1.35,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final requiredTier = _requiredTierFor(item.key);
        final unlocked = _isUnlocked(requiredTier);

        return _FalCard(
          item: item,
          locked: !unlocked,
          requiredTier: requiredTier,
          onTap: () => _onTapItem(item),
        );
      },
    );
  },
),
                      
                     
                      const SizedBox(height: 20),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _FalCard extends StatelessWidget {
  final _FalItem item;
  final bool locked;
  final String requiredTier;
  final VoidCallback onTap;

  const _FalCard({
    required this.item,
    required this.locked,
    required this.requiredTier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                item.color.withOpacity(locked ? 0.06 : 0.14),
                AppColors.glassFill,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: item.color.withOpacity(locked ? 0.15 : 0.30),
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.color.withOpacity(
                          locked ? 0.08 : 0.16,
                        ),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color.withOpacity(
                          locked ? 0.45 : 1,
                        ),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        item.title,
                        style: AppTextStyles.cardLabel.copyWith(
                          fontSize: 11,
                          color: locked
                              ? AppColors.textSecondary
                              : null,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              if (locked)
                Positioned(
                  top: 5,
                  left: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: (_tierColors[requiredTier] ??
                              AppColors.gold)
                          .withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock,
                          size: 8,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _tierLabels[requiredTier] ?? '',
                          style: const TextStyle(
                            fontSize: 7,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
class _FalItem {
  final String key;
  final String title;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
  _FalItem(this.key, this.title, this.icon, this.color, this.builder);
}
