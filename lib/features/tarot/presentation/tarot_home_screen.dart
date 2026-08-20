import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/tarot_spreads.dart';
import 'tarot_screen.dart';
import 'tarot_spread_screen.dart';

class TarotHomeScreen extends StatelessWidget {
  const TarotHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final options = [
      _SpreadOption(
        title: 'کارت روزانه',
        subtitle: 'یک کارت برای امروز',
        icon: Icons.wb_sunny_outlined,
        onTap: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(builder: (_) => const TarotScreen()),
        ),
      ),
      _SpreadOption(
        title: 'سه کارت',
        subtitle: 'گذشته، حال، آینده',
        icon: Icons.view_column_outlined,
        onTap: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (_) => const TarotSpreadScreen(
              title: 'آرایش سه کارت',
              positions: threeCardPositions,
            ),
          ),
        ),
      ),
      _SpreadOption(
        title: 'ده کارت',
        subtitle: 'آرایش کامل و جامع',
        icon: Icons.grid_view_outlined,
        onTap: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (_) => const TarotSpreadScreen(
              title: 'آرایش ده کارت',
              positions: tenCardPositions,
            ),
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('تاروت')),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 8),
                Text(
                  'چه نوع خوانشی می‌خواهی؟',
                  style: AppTextStyles.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ...options.map((o) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => o.onTap(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.glassFill,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(o.icon, color: AppColors.gold),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(o.title, style: AppTextStyles.cardLabel),
                                    Text(o.subtitle, style: AppTextStyles.bodySmall),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpreadOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final void Function(BuildContext) onTap;
  _SpreadOption({required this.title, required this.subtitle, required this.icon, required this.onTap});
}
