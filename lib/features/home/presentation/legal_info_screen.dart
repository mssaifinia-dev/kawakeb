import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../support/presentation/support_screen.dart';
import 'legal_content.dart';

enum LegalPageType {
  terms,
  privacy,
  contact,
}

class LegalInfoScreen extends StatelessWidget {
  final LegalPageType type;

  const LegalInfoScreen({
    super.key,
    required this.type,
  });

  String get _title {
    switch (type) {
      case LegalPageType.terms:
        return 'قوانین و مقررات';
      case LegalPageType.privacy:
        return 'حریم خصوصی';
      case LegalPageType.contact:
        return 'تماس با ما';
    }
  }

  List<Map<String, String>> get _items {
    switch (type) {
      case LegalPageType.terms:
        return LegalContent.terms;
      case LegalPageType.privacy:
        return LegalContent.privacy;
      case LegalPageType.contact:
        return LegalContent.contact;
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
        title: Text(
          _title,
          style: AppTextStyles.cardLabel.copyWith(
            color: AppColors.gold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            30,
          ),
          child: Column(
            children: [
              _Header(type: type),
              const SizedBox(height: 18),

              ..._items.map(
                (item) => _LegalCard(
                  title: item['title'] ?? '',
                  text: item['text'] ?? '',
                ),
              ),

              if (type == LegalPageType.contact) ...[
                const SizedBox(height: 4),
                _SupportButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final LegalPageType type;

  const _Header({
    required this.type,
  });

  IconData get _icon {
    switch (type) {
      case LegalPageType.terms:
        return Icons.gavel_rounded;
      case LegalPageType.privacy:
        return Icons.shield_outlined;
      case LegalPageType.contact:
        return Icons.support_agent_rounded;
    }
  }

  String get _description {
    switch (type) {
      case LegalPageType.terms:
        return 'لطفاً پیش از استفاده از خدمات کواکب، قوانین و شرایط استفاده را مطالعه کنید.';
      case LegalPageType.privacy:
        return 'در این بخش نحوه دریافت، استفاده و حفاظت از اطلاعات کاربران توضیح داده شده است.';
      case LegalPageType.contact:
        return 'ما آماده دریافت پرسش‌ها، پیشنهادها و درخواست‌های پشتیبانی شما هستیم.';
    }
  }

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
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withOpacity(0.12),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.25),
              ),
            ),
            child: Icon(
              _icon,
              color: AppColors.gold,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'کواکب',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalCard extends StatelessWidget {
  final String title;
  final String text;

  const _LegalCard({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.glassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: AppTextStyles.cardLabel.copyWith(
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.9,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportButton extends StatelessWidget {
  const _SupportButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
        icon: const Icon(
          Icons.chat_bubble_outline_rounded,
        ),
        label: const Text(
          'ارتباط با پشتیبانی',
        ),
      ),
    );
  }
}