import 'package:flutter/material.dart';

import '../../features/istikhara/presentation/istikhara_screen.dart';
// فعلاً اگر این دو فایل هنوز ساخته نشده‌اند کامنت بمانند
// import '../../features/hafez/presentation/hafez_screen.dart';
// import '../../features/dream/presentation/dream_screen.dart';


class AppRoutes {

  static const String istikhara = '/istikhara';
  static const String hafez = '/hafez';
  static const String dream = '/dream';


  static Route<dynamic>? generateRoute(RouteSettings settings) {

    switch (settings.name) {

      case istikhara:
        return MaterialPageRoute(
          builder: (_) => const IstikharaScreen(),
        );


      // بعداً فعال می‌کنیم
      // case hafez:
      //   return MaterialPageRoute(
      //     builder: (_) => const HafezScreen(),
      //   );


      // case dream:
      //   return MaterialPageRoute(
      //     builder: (_) => const DreamScreen(),
      //   );


      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('صفحه پیدا نشد'),
            ),
          ),
        );
    }
  }
}