import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/learning_articles_data.dart';

class LearningArticleScreen extends StatelessWidget {
  final LearningArticle article;
  const LearningArticleScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(color: article.color.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(article.icon, color: article.color, size: 34),
                  ),
                  const SizedBox(height: 20),
                  _section('چیست؟', Icons.info_outline, AppColors.gold, article.whatItIs),
                  const SizedBox(height: 16),
                  _section('چطور خونده می‌شه؟', Icons.menu_book_outlined, const Color(0xFF3E9C6E), article.howToRead),
                  if (article.advancedSkill != null) ...[
                    const SizedBox(height: 16),
                    _section('مهارت پیشرفته', Icons.auto_awesome_outlined, const Color(0xFF9C3EE0), article.advancedSkill!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, IconData icon, Color color, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(title, style: AppTextStyles.cardLabel.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Text(text, textAlign: TextAlign.center, style: AppTextStyles.bodyLarge.copyWith(height: 1.9)),
        ),
      ],
    );
  }
}
