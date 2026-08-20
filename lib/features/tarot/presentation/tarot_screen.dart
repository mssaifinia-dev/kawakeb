import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/tarot_data.dart';

class TarotScreen extends StatefulWidget {
  const TarotScreen({super.key});

  @override
  State<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends State<TarotScreen>
    with SingleTickerProviderStateMixin {
  late List<TarotCardData> _choices;
  int? _selectedIndex;
  bool _isRevealed = false;

  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _isRevealed = true);
      }
    });
    _pickNewChoices();
  }

  void _pickNewChoices() {
    final shuffled = List<TarotCardData>.from(tarotDeck)..shuffle();
    _choices = shuffled.take(3).toList();
  }

  void _selectCard(int index) {
    if (_selectedIndex != null) return;
    setState(() => _selectedIndex = index);
    _flipController.forward();
  }

  void _reset() {
    setState(() {
      _selectedIndex = null;
      _isRevealed = false;
      _pickNewChoices();
    });
    _flipController.reset();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تاروت')),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    _selectedIndex == null
                        ? 'یکی از کارت‌ها را با تمرکز انتخاب کن'
                        : (_isRevealed ? 'کارت تو' : 'در حال گشودن کارت...'),
                    style: AppTextStyles.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _selectedIndex == null
                      ? _buildCardSelection()
                      : _buildRevealArea(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----- حالت انتخاب: سه کارت پشت‌ورو -----
  Widget _buildCardSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_choices.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: () => _selectCard(index),
            child: _CardBack(width: 90, height: 140),
          ),
        );
      }),
    );
  }

  // ----- حالت نمایش: انیمیشن باز شدن کارت انتخابی -----
  Widget _buildRevealArea() {
    final card = _choices[_selectedIndex!];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final angle = _flipAnimation.value;
            final showFront = angle > pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(angle),
              child: showFront
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: _CardFront(card: card, width: 160, height: 250),
                    )
                  : const _CardBack(width: 160, height: 250),
            );
          },
        ),
        if (_isRevealed) ...[
          const SizedBox(height: 24),
          AnimatedOpacity(
            opacity: _isRevealed ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(card.name, style: AppTextStyles.displayMedium.copyWith(color: AppColors.gold)),
                const SizedBox(height: 4),
                Text(card.keyword, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.glassFill,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Text(
                    card.meaning,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge,
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _reset,
                  child: const Text('گرفتن فال دیگر'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// پشت کارت: طرح یکنواخت با نماد ماه و ستاره (مطابق برند).
class _CardBack extends StatelessWidget {
  final double width;
  final double height;
  const _CardBack({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.darkPurple, AppColors.black],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold, width: 1.4),
      ),
      child: const Center(
        child: Icon(Icons.nightlight_round, color: AppColors.gold, size: 36),
      ),
    );
  }
}

/// روی کارت: نماد و اسم کارت (بعداً می‌شه تصویر واقعی جایگزین کرد).
class _CardFront extends StatelessWidget {
  final TarotCardData card;
  final double width;
  final double height;
  const _CardFront({required this.card, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2B0D3A), Color(0xFF120620)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold, width: 1.6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(card.icon, color: AppColors.gold, size: 48),
          const SizedBox(height: 12),
          Text(
            card.nameEn,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}
