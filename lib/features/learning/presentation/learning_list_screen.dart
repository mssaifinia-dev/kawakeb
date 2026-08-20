import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../data/learning_articles_data.dart';
import 'learning_article_screen.dart';

class LearningListScreen extends StatelessWidget {
  const LearningListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 8),
                Text('آموزش', style: AppTextStyles.displayMedium, textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(
                  'با هر فال بیشتر آشنا شو و یاد بگیر چطور بهتر بخونیش',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ...learningArticles.map((article) => _ArticleTile(article: article)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  final LearningArticle article;
  const _ArticleTile({required this.article});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => LearningArticleScreen(article: article)));
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: article.color.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(article.icon, color: article.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.title, style: AppTextStyles.cardLabel),
                    const SizedBox(height: 2),
                    Text(
                      article.whatItIs,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: AppColors.gold),
            ],
          ),
        ),
      ),
    );
  }
}
