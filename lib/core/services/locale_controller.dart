import 'package:flutter/material.dart';

/// یک نگهدارنده‌ی سراسری برای زبان فعلی اپ که به هر تغییری فوری واکنش نشون می‌ده
/// (برخلاف قبل که فقط موقع شروع اپ خونده می‌شد و نیاز به رفرش داشت).
class LocaleController {
  LocaleController._();

  static final ValueNotifier<Locale> notifier = ValueNotifier(const Locale('fa'));

  static void setLocale(String code) {
    notifier.value = Locale(code);
  }
}
