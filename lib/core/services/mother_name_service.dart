import 'package:shared_preferences/shared_preferences.dart';

/// ذخیره و بازیابی نام مادر روی خود دستگاه (shared_preferences).
/// برای فال جفر لازم است. اگر بعداً Sync با Supabase (ستون profiles.mother_name)
/// اضافه شد، این سرویس باید مثل BirthdateService/NameService به‌روزرسانی شود.
class MotherNameService {
  static const _key = 'mother_name';

  static Future<void> saveMotherName(String motherName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, motherName);
  }

  static Future<String?> getMotherName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<bool> hasMotherName() async {
    final value = await getMotherName();
    return value != null && value.trim().isNotEmpty;
  }
}
