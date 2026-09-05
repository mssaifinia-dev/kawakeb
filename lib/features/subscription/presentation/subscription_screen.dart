import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../../../core/services/supabase_config.dart';

class SubscriptionScreen extends StatefulWidget {
  final String? preselectedTier;

  const SubscriptionScreen({super.key, this.preselectedTier});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _loading = true;
  String _currentTier = 'free';
  DateTime? _expiresAt;
  Map<String, (int, int)> _plans = {}; // tier -> (price, days)
  String? _buyingTier;
  String? _errorMessage;
  String? _referralCode;
  int _pendingCredits = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final sub = await supabase
          .from('subscriptions')
          .select('tier, expires_at')
          .eq('user_id', user.id)
          .maybeSingle();
      if (sub != null) {
        _currentTier = sub['tier'] as String;
        final expiresRaw = sub['expires_at'] as String?;
        _expiresAt = expiresRaw != null ? DateTime.tryParse(expiresRaw) : null;
      }

      final profile = await supabase.from('profiles').select('referral_code').eq('id', user.id).maybeSingle();
      _referralCode = profile?['referral_code'] as String?;

      final credits = await supabase
          .from('referral_credits')
          .select('id')
          .eq('referrer_id', user.id)
          .eq('redeemed', false);
      _pendingCredits = (credits as List).length;
    }

    final rows = await supabase.from('plans').select('tier, price_toman, duration_days');
    final map = <String, (int, int)>{};
    for (final r in rows as List) {
      map[r['tier'] as String] = (r['price_toman'] as int, r['duration_days'] as int);
    }

    if (!mounted) return;
    setState(() {
      _plans = map;
      _loading = false;
    });

    // اگه از دیالوگ ارتقا با یه پلن مشخص اومده باشیم،
    // و کاربر همین الان اون پلن رو فعال نداشته باشه،
    // خودکار وارد فرآیند پرداخت همون پلن می‌شیم.
    final preselected = widget.preselectedTier;
    if (preselected != null) {
      final alreadyHasIt = _currentTier == preselected && !_isExpired;
      if (!alreadyHasIt && _plans[preselected] != null) {
        _buy(preselected);
      }
    }
  }

  bool get _isExpired => _expiresAt != null && _expiresAt!.isBefore(DateTime.now());

  Future<void> _buy(String tier) async {
    setState(() {
      _buyingTier = tier;
      _errorMessage = null;
    });
    try {
      final res = await supabase.functions.invoke('zarinpal-request-payment', body: {'tier': tier});
      final data = res.data as Map<String, dynamic>?;

      if (res.status != 200 || data?['paymentUrl'] == null) {
        setState(() {
          _errorMessage = (data?['error'] as String?) ?? 'خطا در اتصال به درگاه پرداخت';
          _buyingTier = null;
        });
        return;
      }

      final url = Uri.parse(data!['paymentUrl'] as String);
      await launchUrl(url, webOnlyWindowName: '_self');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'خطا: $e';
        _buyingTier = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اشتراک')),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildCurrentStatus(),
                      const SizedBox(height: 20),
                      if (_plans['gold'] != null) _buildPlanCard('gold', 'طلایی', AppColors.gold),
                      const SizedBox(height: 14),
                      if (_plans['vip'] != null) _buildPlanCard('vip', 'VIP', const Color(0xFF9C3EE0)),
                      const SizedBox(height: 20),
                      _buildReferralCard(),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Text(_errorMessage!,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                              textAlign: TextAlign.center),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus() {
    final label = {'free': 'رایگان', 'gold': 'طلایی', 'vip': 'VIP'}[_currentTier] ?? _currentTier;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.gold.withOpacity(0.15), AppColors.purple.withOpacity(0.15)]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_outlined, color: AppColors.gold, size: 26),
              const SizedBox(width: 10),
              Text('اشتراک فعلی: $label', style: AppTextStyles.cardLabel),
            ],
          ),
          if (_expiresAt != null) ...[
            const SizedBox(height: 6),
            Text(
              _isExpired
                  ? 'اشتراکت منقضی شده'
                  : 'تا ${_expiresAt!.year}/${_expiresAt!.month.toString().padLeft(2, '0')}/${_expiresAt!.day.toString().padLeft(2, '0')} فعاله',
              style: AppTextStyles.bodySmall.copyWith(color: _isExpired ? AppColors.error : AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanCard(String tier, String label, Color color) {
    final (price, days) = _plans[tier]!;
    final isCurrent = _currentTier == tier && !_isExpired;
    final isBuying = _buyingTier == tier;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: color),
              const SizedBox(width: 8),
              Text('اشتراک $label', style: AppTextStyles.cardLabel.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} تومان / $days روز',
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: (isCurrent || isBuying) ? null : () => _buy(tier),
            child: isBuying
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnGold),
                  )
                : Text(isCurrent ? 'اشتراک فعلی توست' : 'خرید'),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard() {
    return Container(
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
          Row(
            children: [
              const Icon(Icons.card_giftcard_outlined, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text('کد معرف تو', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'وقتی دوستت با این کد ثبت‌نام کنه و اشتراک بخره، تو تخفیف می‌گیری.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 14),
          if (_referralCode != null)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Clipboard.setData(ClipboardData(text: _referralCode!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('کد معرف کپی شد')),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGold),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.copy, size: 16, color: AppColors.gold),
                    const SizedBox(width: 8),
                    Text(_referralCode!,
                        style: AppTextStyles.headlineSmall.copyWith(color: AppColors.gold, letterSpacing: 2)),
                  ],
                ),
              ),
            ),
          if (_pendingCredits > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 14, color: AppColors.gold),
                const SizedBox(width: 6),
                Text('$_pendingCredits تخفیف آماده‌ی استفاده داری — خودکار رو خرید بعدی اعمال می‌شه',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}