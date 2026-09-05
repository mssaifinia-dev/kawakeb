import 'dart:html' as html;
import 'package:flutter/material.dart';

/// این کلاس کلید/ژست برگشت مرورگر (که کاربرهای موبایل عادت دارن باهاش
/// برگردن) رو به Navigator داخلی اپ وصل می‌کنه.
///
/// چرا لازمه؟
/// Flutter Web با Navigator.push معمولی (بدون named routes) هیچ
/// رکوردی تو تاریخچه‌ی مرورگر ثبت نمی‌کنه. پس با اولین دکمه‌ی
/// برگشت، کاربر مستقیم از کل سایت خارج می‌شه، نه از صفحه‌ی فعلی.
///
/// این کلاس با هر Navigator.push یه «state» جعلی به تاریخچه‌ی مرورگر
/// اضافه می‌کنه، و وقتی popstate اتفاق بیفته (یعنی دکمه/ژست برگشت
/// زده بشه)، به‌جای اینکه بذاره مرورگر از سایت خارج بشه، Navigator
/// داخلی اپ رو یه قدم می‌بره عقب.
class BrowserBackHandler {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static bool _initialized = false;

  /// برای وقتی که هیچ صفحه‌ای برای pop کردن نیست (یعنی رو ریشه‌ی
  /// ناوبری اپیم، مثلاً MainNavigationScreen با نوار پایین).
  /// اگه ست بشه، قبل از اینکه بذاریم از سایت خارج بشیم صداش می‌زنیم.
  /// اگه true برگردونه یعنی «خودم مدیریتش کردم» (مثلاً برگشتن به
  /// تب خانه)، و اپ باز می‌مونه.
  static bool Function()? rootBackInterceptor;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    // یه state پایه برای صفحه‌ی هوم ثبت می‌کنیم.
    html.window.history.pushState(null, '', html.window.location.href);

    html.window.onPopState.listen((event) {
      final navigator = navigatorKey.currentState;

      if (navigator != null && navigator.canPop()) {
        navigator.pop();

        // یه state جدید push می‌کنیم تا "جای" برگشتی که مرورگر
        // همین الان مصرف کرد، دوباره پر بشه و دکمه‌ی برگشت بعدی
        // هم درست کار کنه.
        html.window.history.pushState(null, '', html.window.location.href);
        return;
      }

      // هیچ صفحه‌ای برای pop کردن نیست — قبل از اینکه بذاریم از
      // سایت خارج بشه، ببینیم کسی (مثلاً نوار پایین) خودش
      // می‌خواد این حالت رو مدیریت کنه یا نه.
      final handledLocally = rootBackInterceptor?.call() ?? false;

      if (handledLocally) {
        html.window.history.pushState(null, '', html.window.location.href);
      }
      // وگرنه کاری نمی‌کنیم و رفتار پیش‌فرض مرورگر (خروج) انجام
      // می‌شه — که همون رفتار درسته وقتی دیگه واقعاً جایی برای
      // برگشتن داخل اپ نمونده (مثلاً از قبل تو تب خانه‌ایم).
    });
  }

  /// هر بار یه صفحه‌ی جدید push می‌شه، این باید صدا زده بشه تا یه
  /// state متناظر تو تاریخچه‌ی مرورگر ثبت بشه.
  static void onPush() {
    html.window.history.pushState(null, '', html.window.location.href);
  }
}

/// این observer به‌صورت خودکار با هر Navigator.push (شامل دیالوگ‌ها و
/// bottom sheet ها هم می‌شه، چون اونا هم از همین Navigator رد می‌شن)
/// یه history state تو مرورگر ثبت می‌کنه — بدون نیاز به تغییر
/// تک‌تک صفحه‌ها.
class BrowserHistoryNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (previousRoute != null) {
      // فقط وقتی رو یه صفحه‌ی قبلی push شده (نه همون اولین صفحه‌ی اپ)
      BrowserBackHandler.onPush();
    }
  }
}