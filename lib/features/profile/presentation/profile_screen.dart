import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../../../core/services/birthdate_service.dart';
import '../../../core/services/name_service.dart';
import '../../../core/services/locale_service.dart';
import '../../../core/services/locale_controller.dart';
import '../../../core/services/supabase_config.dart';
import '../../../core/utils/persian_date_converter.dart';
import '../../auth/presentation/signup_screen.dart';
import '../../admin/presentation/admin_screen.dart';
import '../../support/presentation/support_screen.dart';
import '../../subscription/presentation/subscription_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  String? _name;
  (int, int, int)? _birthdate; // (day, month, year) گرگوری
  String _localeCode = 'fa';
  String _tier = 'free';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await NameService.getFullName();
    final birthdate = await BirthdateService.getBirthdate();
    final locale = await LocaleService.getLocaleCode();

    String tier = 'free';
    final user = supabase.auth.currentUser;
    if (user != null) {
      final sub = await supabase.from('subscriptions').select('tier').eq('user_id', user.id).maybeSingle();
      if (sub != null) tier = sub['tier'] as String;
    }

    if (!mounted) return;
    setState(() {
      _name = name;
      _birthdate = birthdate;
      _localeCode = locale;
      _tier = tier;
      _loading = false;
    });
  }

  String get _birthdateDisplay {
    if (_birthdate == null) return '—';
    final jalali = gregorianToJalali(_birthdate!.$3, _birthdate!.$2, _birthdate!.$1);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _name ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('ویرایش نام'),
        content: TextField(controller: controller, textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('ذخیره')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await NameService.saveFullName(result);
      if (!mounted) return;
      setState(() => _name = result);
    }
  }

  Future<void> _editBirthdate() async {
    final dayC = TextEditingController();
    final monthC = TextEditingController();
    final yearC = TextEditingController();
    String? error;

    final result = await showModalBottomSheet<(int, int, int)>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('تاریخ تولد جدید (شمسی)', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: dayC, keyboardType: TextInputType.number, textAlign: TextAlign.center, decoration: const InputDecoration(hintText: 'روز'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: monthC, keyboardType: TextInputType.number, textAlign: TextAlign.center, decoration: const InputDecoration(hintText: 'ماه'))),
                      const SizedBox(width: 10),
                      Expanded(flex: 2, child: TextField(controller: yearC, keyboardType: TextInputType.number, textAlign: TextAlign.center, decoration: const InputDecoration(hintText: 'سال'))),
                    ],
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final d = int.tryParse(dayC.text.trim());
                        final m = int.tryParse(monthC.text.trim());
                        final y = int.tryParse(yearC.text.trim());
                        if (!isValidJalaliDate(y, m, d)) {
                          setSheetState(() => error = 'تاریخ را درست وارد کن.');
                          return;
                        }
                        final g = jalaliToGregorian(y!, m!, d!);
                        Navigator.pop(ctx, (g.day, g.month, g.year));
                      },
                      child: const Text('ذخیره'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      await BirthdateService.saveBirthdate(day: result.$1, month: result.$2, year: result.$3);
      if (!mounted) return;
      setState(() => _birthdate = result);
    }
  }

  Future<void> _changeLanguage(String code) async {
    await LocaleService.saveLocaleCode(code);
    LocaleController.setLocale(code);
    setState(() => _localeCode = code);
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('خروج از حساب'),
        content: const Text('مطمئنی می‌خوای خارج بشی؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('خروج')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await supabase.auth.signOut();
    } catch (_) {}

    await BirthdateService.clearBirthdate();
    await NameService.clearFullName();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignupScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پروفایل')),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAvatarHeader(),
                        const SizedBox(height: 24),
                        _buildInfoCard(),
                        const SizedBox(height: 16),
                        _buildSubscriptionCard(),
                        const SizedBox(height: 16),
                        _buildLanguageCard(),
                        const SizedBox(height: 16),
                        _buildSupportButton(),
                        const SizedBox(height: 24),
                        _buildSignOutButton(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onLongPress: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
          },
          child: Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.secondaryButtonGradient),
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
        ),
        const SizedBox(height: 12),
        Text(_name ?? 'کاربر کواکب', style: AppTextStyles.headlineSmall),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          _infoRow(icon: Icons.person_outline, label: 'نام', value: _name ?? '—', onTap: _editName),
          const Divider(color: AppColors.glassBorder, height: 24),
          _infoRow(icon: Icons.calendar_today_outlined, label: 'تاریخ تولد', value: _birthdateDisplay, onTap: _editBirthdate),
        ],
      ),
    );
  }

  Widget _infoRow({required IconData icon, required String label, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySmall),
                Text(value, style: AppTextStyles.cardLabel),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    final label = {'free': 'رایگان', 'gold': 'طلایی', 'vip': 'VIP'}[_tier] ?? _tier;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
        _load();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.gold.withOpacity(0.15), AppColors.purple.withOpacity(0.15)]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderGold),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_outlined, color: AppColors.gold, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('اشتراک $label', style: AppTextStyles.cardLabel),
                  Text(_tier == 'free' ? 'برای ارتقا بزن' : 'مشاهده‌ی جزئیات', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_new, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language_outlined, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text('زبان اپ', style: AppTextStyles.cardLabel),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _languageChip('fa', 'فارسی'),
              _languageChip('en', 'English'),
              _languageChip('ar', 'العربية'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _languageChip(String code, String label) {
    final selected = _localeCode == code;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _changeLanguage(code),
      selectedColor: AppColors.gold.withOpacity(0.25),
    );
  }

  Widget _buildSupportButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: const Icon(Icons.support_agent_outlined, color: AppColors.gold),
        title: Text('پشتیبانی', style: AppTextStyles.cardLabel),
        trailing: const Icon(Icons.arrow_back_ios_new, size: 14, color: AppColors.textSecondary),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
        },
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _signOut,
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: Text('خروج از حساب', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
      ),
    );
  }
}
