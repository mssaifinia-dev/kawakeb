import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../../quran/data/quran_verses_data.dart';

class IstikharaScreen extends StatefulWidget {
  const IstikharaScreen({super.key});

  @override
  State<IstikharaScreen> createState() => _IstikharaScreenState();
}

class _IstikharaScreenState extends State<IstikharaScreen> {
  IstikharaResult? _result;
  bool _isLoading = false;

  Future<void> _doIstikhara() async {
    setState(() => _isLoading = true);
    final result = await pickRandomIstikhara();
    if (!mounted) return;
    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  void _reset() {
    setState(() {
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text('استخاره با قرآن'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: _result == null ? _buildIntro() : _buildResult(_result!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.auto_stories_outlined, size: 80, color: AppColors.gold),
        const SizedBox(height: 25),
        Text('نیت خود را در دل مرور کن', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          'پس از آرام شدن ذهن، برای موضوع مورد نظر خود استخاره بگیر.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _doIstikhara,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnGold),
                  )
                : const Text('استخاره کن', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  Widget _buildResult(IstikharaResult result) {
    final verdictInfo = quranVerdictInfo[result.verdict]!;

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: verdictInfo.color.withOpacity(.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: verdictInfo.color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(verdictInfo.icon, color: verdictInfo.color),
              const SizedBox(width: 8),
              Text(verdictInfo.label, style: AppTextStyles.cardLabel.copyWith(color: verdictInfo.color)),
            ],
          ),
        ),
        if (result.reference != null) ...[
          const SizedBox(height: 10),
          Text(result.reference!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        ],
        const SizedBox(height: 25),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            children: [
              Text(
                result.verse,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gold, height: 2, fontSize: 20),
              ),
              if (result.translation != null) ...[
                const SizedBox(height: 20),
                const Divider(color: AppColors.glassBorder),
                const SizedBox(height: 15),
                Text(result.translation!, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
              ],
            ],
          ),
        ),
        const SizedBox(height: 25),
        Text('راهنمایی', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
        if (result.isInterpretive) ...[
          const SizedBox(height: 4),
          Text('(برداشت تفسیری عمومی، مستقل از متن آیه)',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11)),
        ],
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Text(result.guidance, textAlign: TextAlign.center, style: AppTextStyles.bodyLarge),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(onPressed: _reset, child: const Text('استخاره دوباره')),
        ),
      ],
    );
  }
}
