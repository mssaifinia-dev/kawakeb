import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const _key = 'app_locale_code';

  /// کد زبان ذخیره‌شده را برمی‌گرداند ('fa' یا 'en')؛ اگر چیزی ذخیره نشده،
  /// پیش‌فرض 'fa' است (چون بازار اصلی فعلاً ایرانه).
  static Future<String> getLocaleCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? 'fa';
  }

  static Future<void> saveLocaleCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }
}
