import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../numerology/presentation/numerology_dashboard_screen.dart';

/// کارت تبلیغاتی متحرک برای «کتاب سرنوشت» (عددشناسی) — با درخشش پالسی
/// که حس چیزی جادویی و منتظر کشف‌شدن را منتقل می‌کند.
class DestinyBookPromoCard extends StatefulWidget {
  const DestinyBookPromoCard({super.key});

  @override
  State<DestinyBookPromoCard> createState() => _DestinyBookPromoCardState();
}

class _DestinyBookPromoCardState extends State<DestinyBookPromoCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NumerologyDashboardScreen()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.purple.withOpacity(0.25), AppColors.gold.withOpacity(0.12)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderGold),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _glow,
              builder: (context, child) {
                return Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppColors.gold.withOpacity(_glow.value * 0.5), Colors.transparent],
                    ),
                    boxShadow: [
                      BoxShadow(color: AppColors.gold.withOpacity(_glow.value * 0.4), blurRadius: 18, spreadRadius: 2),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.auto_stories, color: AppColors.gold.withOpacity(0.7 + _glow.value * 0.3), size: 28),
                  ),
                );
              },
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('کتاب سرنوشت', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
                  const SizedBox(height: 4),
                  Text(
                    'رازهای اسم و تاریخ تولدت رو کشف کن',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}
