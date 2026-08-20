import 'package:shared_preferences/shared_preferences.dart';

class NameService {
  static const _keyFullName = 'user_full_name';

  static Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFullName);
  }

  static Future<void> saveFullName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFullName, name);
  }

  static Future<void> clearFullName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFullName);
  }
}
