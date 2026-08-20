import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../../../core/utils/persian_date_converter.dart';
import '../../../core/utils/hijri_date_converter.dart';
import '../../../core/services/birthdate_service.dart';
import '../../../core/services/name_service.dart';
import '../../../core/services/mother_name_service.dart';
import '../../../core/services/locale_service.dart';
import '../../../core/services/locale_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/main_navigation_screen.dart';
import 'login_screen.dart';

class _Country {
  final String flag, name, dialCode;
  final int minLength, maxLength;
  const _Country(this.flag, this.name, this.dialCode, this.minLength, this.maxLength);
}

const List<_Country> _countries = [
  _Country('🇮🇷', 'ایران', '+98', 10, 10),
  _Country('🇩🇪', 'آلمان', '+49', 9, 11),
  _Country('🇺🇸', 'آمریکا', '+1', 10, 10),
  _Country('🇬🇧', 'انگلستان', '+44', 9, 10),
  _Country('🇹🇷', 'ترکیه', '+90', 10, 10),
  _Country('🇦🇪', 'امارات', '+971', 8, 9),
  _Country('🇨🇦', 'کانادا', '+1', 10, 10),
  _Country('🇸🇪', 'سوئد', '+46', 7, 10),
  _Country('🇨🇳', 'چین', '+86', 11, 11),
  _Country('🇯🇵', 'ژاپن', '+81', 9, 10),
  _Country('🇮🇳', 'هند', '+91', 10, 10),
  _Country('🇸🇦', 'عربستان', '+966', 9, 9),
  _Country('🇮🇶', 'عراق', '+964', 10, 10),
  _Country('🇦🇫', 'افغانستان', '+93', 9, 9),
  _Country('🇫🇷', 'فرانسه', '+33', 9, 9),
  _Country('🇮🇹', 'ایتالیا', '+39', 9, 10),
  _Country('🇪🇸', 'اسپانیا', '+34', 9, 9),
  _Country('🇦🇺', 'استرالیا', '+61', 9, 9),
  _Country('🇶🇦', 'قطر', '+974', 8, 8),
  _Country('🇰🇼', 'کویت', '+965', 8, 8),
];

enum _CalendarType { shamsi, gregorian, hijri }

extension _CalendarTypeLabel on _CalendarType {
  String get label {
    switch (this) {
      case _CalendarType.shamsi:
        return 'شمسی';
      case _CalendarType.gregorian:
        return 'میلادی';
      case _CalendarType.hijri:
        return 'قمری';
    }
  }

  String get yearHint {
    switch (this) {
      case _CalendarType.shamsi:
        return 'سال (مثلاً ۱۳۷۵)';
      case _CalendarType.gregorian:
        return 'سال (مثلاً ۱۹۹۶)';
      case _CalendarType.hijri:
        return 'سال (مثلاً ۱۴۱۷)';
    }
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _step = 0;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _gender = 'خانم';
  _Country _country = _countries.first;

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _motherNameController = TextEditingController();

  // فیلدهای تاریخ تولد چندتقویمی
  _CalendarType _calendarType = _CalendarType.shamsi;
  final _bdDayController = TextEditingController();
  final _bdMonthController = TextEditingController();
  final _bdYearController = TextEditingController();
  String? _birthDateError;

  // کشورهای عربی‌زبان که با انتخابشان، زبان اپ روی عربی تنظیم می‌شود
  static const List<String> _arabicDialCodes = ['+966', '+971', '+964', '+974', '+965'];
  bool get _isIran => _country.dialCode == '+98';

  String _resolveLocaleCode() {
    if (_isIran) return 'fa';
    if (_arabicDialCodes.contains(_country.dialCode)) return 'ar';
    return 'en';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _motherNameController.dispose();
    _bdDayController.dispose();
    _bdMonthController.dispose();
    _bdYearController.dispose();
    super.dispose();
  }

  bool get _isPhoneValid =>
      _phoneController.text.length >= _country.minLength && _phoneController.text.length <= _country.maxLength;

  bool get _isBirthDateFilled =>
      _bdDayController.text.trim().isNotEmpty &&
      _bdMonthController.text.trim().isNotEmpty &&
      _bdYearController.text.trim().isNotEmpty;

  bool get _isStepTwoValid =>
      _nameController.text.trim().isNotEmpty &&
      _motherNameController.text.trim().isNotEmpty &&
      _isBirthDateFilled;

  /// تاریخ تولد وارد‌شده را (با توجه به نوع تقویم انتخابی) به میلادی تبدیل می‌کند.
  GregorianDate? _resolveBirthDate() {
    final day = int.tryParse(_bdDayController.text.trim());
    final month = int.tryParse(_bdMonthController.text.trim());
    final year = int.tryParse(_bdYearController.text.trim());

    switch (_calendarType) {
      case _CalendarType.shamsi:
        if (!isValidJalaliDate(year, month, day)) return null;
        return jalaliToGregorian(year!, month!, day!);
      case _CalendarType.hijri:
        if (!isValidHijriDate(year, month, day)) return null;
        return hijriToGregorian(year!, month!, day!);
      case _CalendarType.gregorian:
        if (year == null || month == null || day == null) return null;
        if (month < 1 || month > 12 || day < 1 || day > 31) return null;
        return GregorianDate(year: year, month: month, day: day);
    }
  }

  bool get _isPasswordValid => _passwordController.text.length >= 6;
  bool get _isPasswordConfirmed => _passwordController.text == _confirmPasswordController.text;
  bool get _isStepOneValid => _isPhoneValid && _isPasswordValid && _isPasswordConfirmed;

  void _goToStepTwo() {
    if (!_isStepOneValid) return;
    setState(() {
      _errorMessage = null;
      _step = 1;
    });
  }

  Future<void> _onFinishSignup() async {
    final resolved = _resolveBirthDate();
    if (resolved == null) {
      setState(() => _birthDateError = 'تاریخ تولد را با توجه به نوع تقویم انتخابی، درست وارد کن.');
      return;
    }
    setState(() {
      _birthDateError = null;
      _isSubmitting = true;
      _errorMessage = null;
    });

    final fullPhone = '${_country.dialCode}${_phoneController.text.trim()}';
    final password = _passwordController.text;

    try {
      final client = Supabase.instance.client;

      final res = await client.functions.invoke(
        'phone-signup',
        body: {
          'phone': fullPhone,
          'password': password,
          'name': _nameController.text.trim(),
          'motherName': _motherNameController.text.trim(),
          'birthdate': '${resolved.year}-${resolved.month.toString().padLeft(2, '0')}-${resolved.day.toString().padLeft(2, '0')}',
          'country': _country.name,
        },
      );

      final data = res.data as Map<String, dynamic>?;

      if (res.status != 200) {
        final code = data?['code'];
        if (code == 'already_exists') {
          setState(() {
            _errorMessage = 'این شماره قبلاً ثبت‌نام کرده.';
            _isSubmitting = false;
          });
          return;
        }
        setState(() {
          _errorMessage = (data?['error'] as String?) ?? 'خطا در ثبت‌نام، دوباره تلاش کنید.';
          _isSubmitting = false;
        });
        return;
      }

      // حساب واقعی ساخته شد؛ حالا واقعاً وارد می‌شویم تا Session معتبر بگیریم
      await client.auth.signInWithPassword(phone: fullPhone, password: password);

      // ذخیره‌ی محلی فقط برای ورود خودکار راحت‌تر روی همین دستگاه؛
      // رمز واقعی نزد خود کاربر است، این فقط یک میانبر است.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_phone', fullPhone);
      await prefs.setString('auth_password', password);

      await BirthdateService.saveBirthdate(
        day: resolved.day,
        month: resolved.month,
        year: resolved.year,
      );
      await NameService.saveFullName(_nameController.text.trim());
      await MotherNameService.saveMotherName(_motherNameController.text.trim());
      final localeCode = _resolveLocaleCode();
      await LocaleService.saveLocaleCode(localeCode);
      LocaleController.setLocale(localeCode);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'خطای ورود: ${e.message}';
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
                        onPressed: () {
                          if (_step == 1) {
                            setState(() => _step = 0);
                          } else {
                            Navigator.of(context).maybePop();
                          }
                        },
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                      Expanded(
                        child: Text(AppLocalizations.of(context)!.signupTitle, textAlign: TextAlign.center, style: AppTextStyles.headlineSmall),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _step == 0 ? _buildStepOne() : _buildStepTwo(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepOne() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<_Country>(
          value: _country,
          isExpanded: true,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.signupCountryLabel),
          items: _countries
              .map((c) => DropdownMenuItem(value: c, child: Text('${c.flag}  ${c.name}  (${c.dialCode})')))
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _country = value;
              _phoneController.clear();
            });
            LocaleController.setLocale(_resolveLocaleCode());
          },
        ),
        const SizedBox(height: 14),
        _buildPhoneField(),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordController,
          obscureText: true,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'رمز عبور (حداقل ۶ کاراکتر)',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'تکرار رمز عبور',
            prefixIcon: const Icon(Icons.lock_outline),
            errorText: _confirmPasswordController.text.isNotEmpty && !_isPasswordConfirmed
                ? 'رمزها یکسان نیستند'
                : null,
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(_errorMessage!,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error), textAlign: TextAlign.right),
          ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _isStepOneValid ? _goToStepTwo : null,
          child: Text(AppLocalizations.of(context)!.signupContinue),
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: const Text('حساب داری؟ وارد شو'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textAlign: TextAlign.right,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _LeadingZeroStripFormatter(),
        LengthLimitingTextInputFormatter(_country.maxLength),
      ],
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.signupPhoneHint,
        prefixText: '${_country.dialCode}  ',
        counterText: '',
        helperText: AppLocalizations.of(context)!.signupPhoneDigitsHelper(_country.minLength, _country.maxLength),
      ),
    );
  }

  Widget _buildStepTwo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.signupNameHint, prefixIcon: const Icon(Icons.person_outline)),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _motherNameController,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'نام مادر',
            prefixIcon: Icon(Icons.person_outline),
            helperText: 'برای فال جفر لازم است',
          ),
        ),
        const SizedBox(height: 18),
        _buildBirthDateSection(),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(Icons.wc_outlined, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'آقا', label: Text(AppLocalizations.of(context)!.signupGenderMale)),
                  ButtonSegment(value: 'خانم', label: Text(AppLocalizations.of(context)!.signupGenderFemale)),
                ],
                selected: {_gender},
                onSelectionChanged: (value) => setState(() => _gender = value.first),
              ),
            ),
          ],
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(_errorMessage!,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error), textAlign: TextAlign.right),
          ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: (_isStepTwoValid && !_isSubmitting) ? _onFinishSignup : null,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnGold),
                )
              : Text(AppLocalizations.of(context)!.signupContinue),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildBirthDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.signupBirthDateLabel, style: AppTextStyles.bodyMedium),
          ],
        ),
        const SizedBox(height: 10),
        SegmentedButton<_CalendarType>(
          segments: _CalendarType.values
              .map((c) => ButtonSegment(value: c, label: Text(c.label)))
              .toList(),
          selected: {_calendarType},
          onSelectionChanged: (value) => setState(() {
            _calendarType = value.first;
            _birthDateError = null;
          }),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _bdDayController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(hintText: AppLocalizations.of(context)!.signupDayHint),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _bdMonthController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(hintText: AppLocalizations.of(context)!.signupMonthHint),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _bdYearController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(hintText: _calendarType.yearHint),
              ),
            ),
          ],
        ),
        if (_birthDateError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _birthDateError!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              textAlign: TextAlign.right,
            ),
          ),
      ],
    );
  }
}

/// اگر کاربر عادت داشته باشد صفر ابتدایی شماره موبایل را هم تایپ کند
/// (مثلاً ۰۹۱۲...)، این فرمتر آن صفر را خودکار حذف می‌کند.
class _LeadingZeroStripFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.startsWith('0')) {
      final stripped = newValue.text.replaceFirst(RegExp(r'^0+'), '');
      return TextEditingValue(
        text: stripped,
        selection: TextSelection.collapsed(offset: stripped.length),
      );
    }
    return newValue;
  }
}
