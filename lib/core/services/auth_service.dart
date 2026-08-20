import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class AuthService {
  AuthService._();

  /// ارسال کد تأیید ۵ رقمی به ایمیل (واقعی، از طریق Supabase Auth).
  static Future<void> sendEmailOtp(String email) async {
    await supabase.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true,
    );
  }

  /// تایید کدی که کاربر از ایمیلش وارد کرده.
  static Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    return await supabase.auth.verifyOTP(
      type: OtpType.email,
      email: email,
      token: token,
    );
  }

  // TODO: ارسال/تایید کد پیامکی برای شماره‌های ایرانی.
  // نیاز به اتصال یک سرویس پیامکی ایرانی (مثل Kavenegar) از طریق
  // یک Supabase Edge Function دارد، چون سرویس پیش‌فرض Supabase (Twilio)
  // برای شماره‌های ایرانی کار نمی‌کند. فعلاً این مسیر شبیه‌سازی شده است.
}
