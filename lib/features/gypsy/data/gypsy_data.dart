import 'package:flutter/material.dart';

class GypsyCard {
  final String name;
  final IconData icon;
  final String interpretation;

  const GypsyCard({
    required this.name,
    required this.icon,
    required this.interpretation,
  });
}

const List<GypsyCard> gypsyCards = [
  GypsyCard(
    name: 'سوار',
    icon: Icons.directions_run,
    interpretation: 'نشانه‌ی خبری تازه یا فردی است که به‌زودی وارد زندگی‌ات می‌شود؛ منتظر پیامی از راه دور باش.',
  ),
  GypsyCard(
    name: 'گل سه‌برگ',
    icon: Icons.eco_outlined,
    interpretation: 'نشانه‌ی شانس کوچک اما دلپذیر در طول روزهای آینده است؛ به فرصت‌های ساده بی‌توجه نباش.',
  ),
  GypsyCard(
    name: 'کشتی',
    icon: Icons.sailing_outlined,
    interpretation: 'نشانه‌ی سفر، تجارت یا حرکت به‌سوی موقعیتی تازه است؛ حرکتی بزرگ در پیش داری.',
  ),
  GypsyCard(
    name: 'خانه',
    icon: Icons.home_outlined,
    interpretation: 'نشانه‌ی امنیت، خانواده و زندگی خصوصی است؛ خبری درباره‌ی محل زندگی یا خانواده در راه است.',
  ),
  GypsyCard(
    name: 'درخت',
    icon: Icons.park_outlined,
    interpretation: 'نشانه‌ی سلامتی، رشد آهسته و ریشه‌های عمیق است؛ نتیجه‌ی چیزی که کاشته‌ای به‌زودی نمایان می‌شود.',
  ),
  GypsyCard(
    name: 'ابر',
    icon: Icons.cloud_outlined,
    interpretation: 'نشانه‌ی ابهام یا سردرگمی موقت است؛ صبر کن تا هوا روشن‌تر شود پیش از تصمیم‌گیری.',
  ),
  GypsyCard(
    name: 'مار',
    icon: Icons.gesture,
    interpretation: 'هشداری برای مراقبت از فریب، حسادت یا فردی نادرست در اطرافت است.',
  ),
  GypsyCard(
    name: 'تابوت',
    icon: Icons.inventory_2_outlined,
    interpretation: 'برخلاف ظاهرش نشانه‌ی مرگ نیست، بلکه پایان یک دوره و آغاز تحولی بزرگ است.',
  ),
  GypsyCard(
    name: 'دسته گل',
    icon: Icons.local_florist_outlined,
    interpretation: 'نشانه‌ی شادی، دعوت یا هدیه‌ای خوشایند است؛ اتفاقی لذت‌بخش نزدیک است.',
  ),
  GypsyCard(
    name: 'داس',
    icon: Icons.content_cut,
    interpretation: 'نشانه‌ی تصمیمی سریع و قاطع است؛ زمان بریدن از چیزی که دیگر به کارت نمی‌آید رسیده.',
  ),
  GypsyCard(
    name: 'شلاق',
    icon: Icons.bolt_outlined,
    interpretation: 'نشانه‌ی تکرار یک بحث یا موضوع ناتمام است؛ وقتش رسیده با گفت‌وگو به آن پایان دهی.',
  ),
  GypsyCard(
    name: 'پرنده‌ها',
    icon: Icons.flutter_dash,
    interpretation: 'نشانه‌ی گفت‌وگو، شایعه یا خبرهای کوچک پیاپی است؛ مراقب حرف‌های نسنجیده باش.',
  ),
  GypsyCard(
    name: 'کودک',
    icon: Icons.child_care_outlined,
    interpretation: 'نشانه‌ی شروعی تازه، سادگی و اعتماد است؛ نگاهی معصومانه‌تر به موضوعی که ذهنت را درگیر کرده داشته باش.',
  ),
  GypsyCard(
    name: 'روباه',
    icon: Icons.pets_outlined,
    interpretation: 'نشانه‌ی نیاز به زیرکی بیشتر در محیط کار یا معاملات است؛ مراقب افراد فرصت‌طلب باش.',
  ),
  GypsyCard(
    name: 'خرس',
    icon: Icons.shield_outlined,
    interpretation: 'نشانه‌ی قدرت، محافظت یا فردی حامی در زندگی‌ات است؛ به این حمایت تکیه کن.',
  ),
  GypsyCard(
    name: 'ستاره',
    icon: Icons.star_border,
    interpretation: 'نشانه‌ی امید، هدایت روشن و موفقیت در مسیری است که این روزها دنبال می‌کنی.',
  ),
  GypsyCard(
    name: 'لک‌لک',
    icon: Icons.flight_outlined,
    interpretation: 'نشانه‌ی تغییر مکان، شغل یا شرایط زندگی است؛ حرکتی مثبت در راه است.',
  ),
  GypsyCard(
    name: 'کلید',
    icon: Icons.vpn_key_outlined,
    interpretation: 'نشانه‌ی راه‌حل قطعی برای مسئله‌ای است که مدتی دنبالش بودی.',
  ),
];
