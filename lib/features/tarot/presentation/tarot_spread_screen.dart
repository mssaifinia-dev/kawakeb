import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/tarot_data.dart';

/// صفحه‌ای عمومی برای هر آرایش چندکارتی (مثلاً سه‌کارتی یا ده‌کارتی).
/// با دادن یک لیست از عنوان جایگاه‌ها (positions)، به همان تعداد کارت
/// تصادفی و غیرتکراری کشیده و به هرکدام یک جایگاه اختصاص می‌دهد.
class TarotSpreadScreen extends StatefulWidget {
  final String title;
  final List<String> positions;

  const TarotSpreadScreen({super.key, required this.title, required this.positions});

  @override
  State<TarotSpreadScreen> createState() => _TarotSpreadScreenState();
}

class _TarotSpreadScreenState extends State<TarotSpreadScreen> {
  List<TarotCardData>? _drawnCards;
  final _random = Random();

  void _draw() {
    final shuffled = List<TarotCardData>.from(tarotDeck)..shuffle(_random);
    setState(() {
      _drawnCards = shuffled.take(widget.positions.length).toList();
    });
  }

  void _reset() => setState(() => _drawnCards = null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: _drawnCards == null ? _buildIntro() : _buildResultList(_drawnCards!),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.style_outlined, color: AppColors.gold, size: 64),
            const SizedBox(height: 20),
            Text(widget.title, style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              'با تمرکز بر سؤالت، آماده‌ی دریافت ${widget.positions.length} کارت باش.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _draw, child: const Text('گرفتن کارت‌ها')),
          ],
        ),
      ),
    );
  }

  Widget _buildResultList(List<TarotCardData> cards) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: cards.length + 1,
      itemBuilder: (context, index) {
        if (index == cards.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 24),
            child: Center(
              child: OutlinedButton(onPressed: _reset, child: const Text('گرفتن آرایش جدید')),
            ),
          );
        }

        final card = cards[index];
        final position = widget.positions[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Icon(card.icon, color: AppColors.gold),
              title: Text('$position — ${card.name}', style: AppTextStyles.cardLabel),
              subtitle: Text(card.keyword, style: AppTextStyles.bodySmall),
              iconColor: AppColors.gold,
              collapsedIconColor: AppColors.textSecondary,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    card.meaning,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
