import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';

String? _normalizePhone(String raw) {
  var digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
  if (digits.startsWith('+')) return digits;
  if (digits.startsWith('0')) digits = digits.substring(1);
  if (digits.length == 10 && digits.startsWith('9')) {
    return '+98$digits';
  }
  if (digits.isNotEmpty) return '+98$digits';
  return null;
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;
  bool _success = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _motherNameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _phoneController.text.trim().isNotEmpty &&
      _motherNameController.text.trim().isNotEmpty &&
      _newPasswordController.text.length >= 6 &&
      _newPasswordController.text == _confirmPasswordController.text;

  Future<void> _onReset() async {
    final phone = _normalizePhone(_phoneController.text.trim());
    if (phone == null) {
      setState(() => _errorMessage = 'فرمت شماره‌موبایل درست نیست.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final client = Supabase.instance.client;
      final res = await client.functions.invoke(
        'reset-password',
        body: {
          'phone': phone,
          'motherName': _motherNameController.text.trim(),
          'newPassword': _newPasswordController.text,
        },
      );

      if (res.status != 200) {
        final data = res.data as Map<String, dynamic>?;
        setState(() {
          _errorMessage = (data?['error'] as String?) ?? 'خطا در بازیابی رمز، دوباره تلاش کنید.';
          _isSubmitting = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _success = true;
        _isSubmitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'خطا: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                      const Expanded(
                        child: Text('بازیابی رمز عبور', textAlign: TextAlign.center),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _success ? _buildSuccess() : _buildForm(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle_outline, color: AppColors.gold, size: 56),
        const SizedBox(height: 16),
        Text('رمز عبور با موفقیت تغییر کرد', style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('حالا می‌تونی با رمز جدید وارد شوی.', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('بازگشت به صفحه‌ی ورود'),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'برای بازیابی رمز، شماره‌موبایل و نام مادرت رو (همونی که موقع ثبت‌نام زدی) وارد کن.',
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'شماره‌موبایل',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _motherNameController,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'نام مادر',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _newPasswordController,
          obscureText: true,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'رمز عبور جدید (حداقل ۶ کاراکتر)',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'تکرار رمز جدید',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              _errorMessage!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              textAlign: TextAlign.right,
            ),
          ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: (_isFormValid && !_isSubmitting) ? _onReset : null,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnGold),
                )
              : const Text('تغییر رمز عبور'),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
