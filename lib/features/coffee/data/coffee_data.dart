import 'package:flutter/material.dart';

class CoffeeSymbol {
  final String name;
  final IconData icon;
  final String interpretation;

  const CoffeeSymbol({
    required this.name,
    required this.icon,
    required this.interpretation,
  });
}

const List<CoffeeSymbol> coffeeSymbols = [
  CoffeeSymbol(
    name: 'قلب',
    icon: Icons.favorite_outline,
    interpretation: 'نشانه‌ی عشقی صادق یا اتفاقی شیرین در حوزه‌ی احساسات که به‌زودی رخ می‌دهد.',
  ),
  CoffeeSymbol(
    name: 'پرنده',
    icon: Icons.flutter_dash,
    interpretation: 'خبر خوش و پیامی مثبت در راه است؛ چیزی که مدتی منتظرش بودی.',
  ),
  CoffeeSymbol(
    name: 'درخت',
    icon: Icons.park_outlined,
    interpretation: 'نشانه‌ی رشد پایدار، ریشه‌دار بودن تصمیمات و ثباتی که در حال شکل‌گیری‌ست.',
  ),
  CoffeeSymbol(
    name: 'ماهی',
    icon: Icons.set_meal_outlined,
    interpretation: 'نماد روزی و برکت مالی؛ فرصتی برای بهبود وضعیت اقتصادی نزدیک است.',
  ),
  CoffeeSymbol(
    name: 'کلید',
    icon: Icons.vpn_key_outlined,
    interpretation: 'راه‌حلی که دنبالش بودی پیدا می‌شود؛ دری که تصور می‌کردی بسته است، باز خواهد شد.',
  ),
  CoffeeSymbol(
    name: 'ستاره',
    icon: Icons.star_border,
    interpretation: 'شانس و موفقیت در راه است، به‌خصوص در موضوعی که اخیراً برایش تلاش کرده‌ای.',
  ),
  CoffeeSymbol(
    name: 'دایره',
    icon: Icons.circle_outlined,
    interpretation: 'نشانه‌ی کامل شدن یک دوره یا بازگشت چیزی از گذشته به شکلی تازه.',
  ),
  CoffeeSymbol(
    name: 'خط مواج',
    icon: Icons.waves,
    interpretation: 'سفر یا تغییری در پیش است؛ مسیر ممکن است پرپیچ‌وخم باشد اما به مقصد می‌رسی.',
  ),
  CoffeeSymbol(
    name: 'صلیب',
    icon: Icons.add,
    interpretation: 'نشانه‌ی یک تصمیم دشوار یا دوراهی‌ست که باید با دقت بیشتری به آن فکر کنی.',
  ),
  CoffeeSymbol(
    name: 'تاج',
    icon: Icons.emoji_events_outlined,
    interpretation: 'موفقیت، افتخار یا به‌رسمیت شناخته شدن تلاش‌هایت نزدیک است.',
  ),
  CoffeeSymbol(
    name: 'چتر',
    icon: Icons.beach_access_outlined,
    interpretation: 'نیاز به محافظت از خود در برابر مشکلی موقتی؛ محتاط باش اما نگران نباش.',
  ),
  CoffeeSymbol(
    name: 'لنگر',
    icon: Icons.anchor_outlined,
    interpretation: 'ثبات و امنیتی که به دنبالش بودی، در حال رسیدن است؛ جایی برای تکیه کردن پیدا می‌کنی.',
  ),
  CoffeeSymbol(
    name: 'ماه',
    icon: Icons.nightlight_outlined,
    interpretation: 'دوره‌ای احساسی و درون‌گرایانه در پیش داری؛ به شهودت اعتماد کن.',
  ),
  CoffeeSymbol(
    name: 'خورشید',
    icon: Icons.wb_sunny_outlined,
    interpretation: 'نشانه‌ی شادی، موفقیت و روزهای روشن پیش‌رو؛ دوره‌ی خوبی در راه است.',
  ),
  CoffeeSymbol(
    name: 'پروانه',
    icon: Icons.emoji_nature_outlined,
    interpretation: 'تحولی مثبت در شخصیت یا زندگی‌ات در حال شکل‌گیری‌ست؛ استقبال کن.',
  ),
  CoffeeSymbol(
    name: 'مار',
    icon: Icons.gesture,
    interpretation: 'هشداری برای مراقبت از یک فرد یا موقعیت که ممکن است صادق نباشد.',
  ),
  CoffeeSymbol(
    name: 'کوه',
    icon: Icons.terrain_outlined,
    interpretation: 'چالشی بزرگ اما قابل عبور در راه است؛ با پشتکار به آن غلبه می‌کنی.',
  ),
  CoffeeSymbol(
    name: 'جاده',
    icon: Icons.route_outlined,
    interpretation: 'مسیر روشنی پیش رویت باز می‌شود؛ زمان مناسبی برای تصمیم‌گیری قاطع است.',
  ),
  CoffeeSymbol(
    name: 'خانه',
    icon: Icons.home_outlined,
    interpretation: 'ثبات خانوادگی، خبری درباره‌ی محل زندگی یا آرامشی که به آن نیاز داشتی.',
  ),
  CoffeeSymbol(
    name: 'حلقه',
    icon: Icons.circle,
    interpretation: 'نشانه‌ی تعهد، پیمانی تازه یا خبری مرتبط با ازدواج و روابط رسمی.',
  ),
];
