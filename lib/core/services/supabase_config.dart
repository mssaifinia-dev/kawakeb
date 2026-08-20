import 'package:supabase_flutter/supabase_flutter.dart';

/// تنظیمات اتصال به Supabase.
/// این دو مقدار عمومی (Publishable/Anon) هستن و افشاشون مشکلی نداره —
/// فقط کلید service_role هیچ‌وقت نباید اینجا یا در کد کلاینت قرار بگیره.
class SupabaseConfig {
  SupabaseConfig._();

  static const String projectUrl = 'https://jwokttgkpftlvlmipaco.supabase.co';
  static const String publishableKey =
      'sb_publishable_J3-DdfSNOTlHv7axjYEAWQ_Oz93Cdck';

  /// این تابع باید یک‌بار، قبل از runApp() فراخوانی بشه.
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: projectUrl,
      anonKey: publishableKey,
    );
  }
}

/// دسترسی سریع به کلاینت Supabase از هر جای اپ.
final supabase = Supabase.instance.client;
