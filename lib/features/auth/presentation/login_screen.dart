import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../../../shared/main_navigation_screen.dart';
import 'forgot_password_screen.dart';

/// اگر شماره با 0 یا 9 شروع بشه، فرض می‌کنیم شماره‌ی ایرانیه و +98 اضافه می‌کنیم.
/// اگر با + شروع بشه، همون‌طور که هست استفاده می‌شه.
String? _normalizeLoginPhone(String raw) {
  var digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
  if (digits.startsWith('+')) return digits;
  if (digits.startsWith('0')) digits = digits.substring(1);
  if (digits.length == 10 && digits.startsWith('9')) {
    return '+98$digits';
  }
  if (digits.isNotEmpty) return '+98$digits';
  return null;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid => _phoneController.text.trim().isNotEmpty && _passwordController.text.isNotEmpty;

  Future<void> _onLogin() async {
    final phone = _normalizeLoginPhone(_phoneController.text.trim());
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
      await client.auth.signInWithPassword(phone: phone, password: _passwordController.text);

      // برای ورود خودکار راحت‌تر روی همین دستگاه، دفعه‌ی بعد
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_phone', phone);
      await prefs.setString('auth_password', _passwordController.text);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      final message = e.message.toLowerCase().contains('invalid')
          ? 'شماره‌موبایل یا رمز عبور اشتباه است.'
          : 'خطای ورود: ${e.message}';
      setState(() {
        _errorMessage = message;
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
                        child: Text('ورود', textAlign: TextAlign.center),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          textAlign: TextAlign.right,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'شماره‌موبایل (مثلاً 09123456789)',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _onLogin(),
                          textAlign: TextAlign.right,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'رمز عبور',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                              );
                            },
                            child: const Text('رمز عبور را فراموش کردم'),
                          ),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, bottom: 10),
                            child: Text(
                              _errorMessage!,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: (_isFormValid && !_isSubmitting) ? _onLogin : null,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnGold),
                                )
                              : const Text('ورود'),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
