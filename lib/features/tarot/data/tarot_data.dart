import 'package:flutter/material.dart';

/// یک کارت تاروت: نام، آیکون نمادین، کلیدواژه، و تفسیر کوتاه.
/// در آینده می‌شه به‌جای آیکون از تصویر واقعی کارت استفاده کرد.
class TarotCardData {
  final String name;
  final String nameEn;
  final IconData icon;
  final String keyword;
  final String meaning;

  const TarotCardData({
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.keyword,
    required this.meaning,
  });
}

/// مجموعه‌ای از کارت‌های آرکانای بزرگ برای شروع.
/// بعداً می‌شه کل ۷۸ کارت رو اضافه کرد.
const List<TarotCardData> tarotDeck = [
  TarotCardData(
    name: 'ستاره',
    nameEn: 'THE STAR',
    icon: Icons.auto_awesome,
    keyword: 'امید و الهام',
    meaning:
        'کارت ستاره نشانه‌ی امید، آرامش پس از طوفان و بازگشت الهام است. زمان خوبی برای اعتماد به مسیر پیش رو و رها کردن نگرانی‌های گذشته.',
  ),
  TarotCardData(
    name: 'خورشید',
    nameEn: 'THE SUN',
    icon: Icons.wb_sunny_outlined,
    keyword: 'شادی و موفقیت',
    meaning:
        'خورشید نماد شادکامی، موفقیت و انرژی مثبت است. اتفاقات پیش رو با روشنایی و وضوح همراه خواهند بود.',
  ),
  TarotCardData(
    name: 'ماه',
    nameEn: 'THE MOON',
    icon: Icons.nightlight_round,
    keyword: 'شهود و ابهام',
    meaning:
        'ماه به دنیای درون، رویاها و شهود اشاره دارد. ممکن است چیزها آن‌طور که به نظر می‌رسند نباشند؛ به ندای درونت گوش بده.',
  ),
  TarotCardData(
    name: 'چرخ بخت',
    nameEn: 'WHEEL OF FORTUNE',
    icon: Icons.donut_large_outlined,
    keyword: 'تغییر و سرنوشت',
    meaning:
        'چرخش تقدیر در راه است. اتفاقی غیرمنتظره می‌تواند مسیر زندگی‌ات را تغییر دهد — این تغییر را با آغوش باز بپذیر.',
  ),
  TarotCardData(
    name: 'عاشقان',
    nameEn: 'THE LOVERS',
    icon: Icons.favorite_outline,
    keyword: 'انتخاب و پیوند',
    meaning:
        'این کارت درباره‌ی انتخاب‌های مهم، هماهنگی و پیوندهای عاطفی است. تصمیمی که می‌گیری بازتاب ارزش‌های واقعی‌ات خواهد بود.',
  ),
  TarotCardData(
    name: 'برج',
    nameEn: 'THE TOWER',
    icon: Icons.bolt_outlined,
    keyword: 'تحول ناگهانی',
    meaning:
        'تغییری ناگهانی و آزادکننده در راه است. آنچه فرو می‌ریزد، جا را برای چیزی محکم‌تر و واقعی‌تر باز می‌کند.',
  ),
  TarotCardData(
    name: 'قدرت',
    nameEn: 'STRENGTH',
    icon: Icons.self_improvement,
    keyword: 'شجاعت درونی',
    meaning:
        'قدرت واقعی از آرامش درونی و شفقت می‌آید، نه زور. با صبر و اطمینان به خودت، بر چالش‌ها غلبه می‌کنی.',
  ),
  TarotCardData(
    name: 'ابله',
    nameEn: 'THE FOOL',
    icon: Icons.explore_outlined,
    keyword: 'آغاز تازه',
    meaning:
        'قدمی تازه و پر از ماجراجویی در پیش داری. با ذهنی باز و بدون ترس از اشتباه، به این مسیر جدید قدم بگذار.',
  ),
  TarotCardData(
    name: 'جادوگر',
    nameEn: 'THE MAGICIAN',
    icon: Icons.auto_fix_high,
    keyword: 'توانمندی و اراده',
    meaning:
        'همه‌ی ابزارهای لازم برای موفقیت را در اختیار داری. زمان آن رسیده که اراده‌ات را به عمل تبدیل کنی.',
  ),
  TarotCardData(
    name: 'ناسک',
    nameEn: 'THE HERMIT',
    icon: Icons.nightlight_outlined,
    keyword: 'تأمل و درون‌نگری',
    meaning:
        'زمان مناسبی برای عقب‌نشینی و تأمل است. پاسخی که به دنبالش هستی، در سکوت و خلوت پیدا می‌شود.',
  ),
  TarotCardData(
    name: 'دادگری',
    nameEn: 'JUSTICE',
    icon: Icons.balance_outlined,
    keyword: 'تعادل و انصاف',
    meaning:
        'نتیجه‌ی این موضوع بر پایه‌ی انصاف و حقیقت رقم می‌خورد. صادق باش و منتظر نتیجه‌ای عادلانه بمان.',
  ),
  TarotCardData(
    name: 'اعتدال',
    nameEn: 'TEMPERANCE',
    icon: Icons.water_drop_outlined,
    keyword: 'هماهنگی و صبر',
    meaning:
        'تعادل کلید این دوران است. با آرامش، بدون افراط، بین خواسته‌ها و امکاناتت هماهنگی ایجاد کن.',
  ),
  TarotCardData(
    name: 'جهان',
    nameEn: 'THE WORLD',
    icon: Icons.public,
    keyword: 'تکامل و پایان یک دوره',
    meaning:
        'دوره‌ای از تلاش به پایان می‌رسد و به تکامل می‌رسی. این پایان، دروازه‌ای برای یک آغاز بزرگ‌تر است.',
  ),
];
