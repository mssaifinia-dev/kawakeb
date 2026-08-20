import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_config.dart';

class BirthdateService {
  static const _keyDay = 'birthdate_day';
  static const _keyMonth = 'birthdate_month';
  static const _keyYear = 'birthdate_year';

  /// تاریخ تولد را برمی‌گرداند: اول از حافظه‌ی محلی (سریع)، و اگر محلی
  /// چیزی نداشت ولی کاربر session واقعی Supabase دارد (یعنی با ایمیل وارد شده)،
  /// تلاش می‌کند از سرور بخواند و در محلی هم کش کند (برای همگام‌سازی بین دستگاه‌ها).
  static Future<(int, int, int)?> getBirthdate() async {
    final local = await _getLocal();
    if (local != null) return local;

    final remote = await _getRemote();
    if (remote != null) {
      await _saveLocal(day: remote.$1, month: remote.$2, year: remote.$3);
    }
    return remote;
  }

  /// تاریخ تولد را همیشه محلی ذخیره می‌کند، و اگر کاربر session واقعی
  /// Supabase داشت (فعلاً فقط کاربران ایمیلی)، در سرور هم ذخیره/به‌روزرسانی می‌کند
  /// تا بین دستگاه‌های مختلف کاربر همگام بماند.
  static Future<void> saveBirthdate({
    required int day,
    required int month,
    required int year,
  }) async {
    await _saveLocal(day: day, month: month, year: year);
    await _saveRemoteIfPossible(day: day, month: month, year: year);
  }

  static Future<void> clearBirthdate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDay);
    await prefs.remove(_keyMonth);
    await prefs.remove(_keyYear);
  }

  // ---------- محلی (shared_preferences) ----------

  static Future<(int, int, int)?> _getLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final day = prefs.getInt(_keyDay);
    final month = prefs.getInt(_keyMonth);
    final year = prefs.getInt(_keyYear);
    if (day == null || month == null || year == null) return null;
    return (day, month, year);
  }

  static Future<void> _saveLocal({
    required int day,
    required int month,
    required int year,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDay, day);
    await prefs.setInt(_keyMonth, month);
    await prefs.setInt(_keyYear, year);
  }

  // ---------- سرور (Supabase) — فقط وقتی کاربر واقعاً لاگین است ----------

  static Future<(int, int, int)?> _getRemote() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await supabase
          .from('profiles')
          .select('birth_day, birth_month, birth_year')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return null;
      final day = response['birth_day'] as int?;
      final month = response['birth_month'] as int?;
      final year = response['birth_year'] as int?;
      if (day == null || month == null || year == null) return null;
      return (day, month, year);
    } catch (e) {
      // اگر جدول هنوز ساخته نشده یا مشکل شبکه بود، بی‌صدا نادیده می‌گیریم
      // تا اپ خراب نشود؛ نسخه‌ی محلی همچنان کار می‌کند.
      return null;
    }
  }

  static Future<void> _saveRemoteIfPossible({
    required int day,
    required int month,
    required int year,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'birth_day': day,
        'birth_month': month,
        'birth_year': year,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // اگر ذخیره‌ی سرور شکست خورد، مشکلی نیست — نسخه‌ی محلی از قبل ذخیره شده.
    }
  }
}
