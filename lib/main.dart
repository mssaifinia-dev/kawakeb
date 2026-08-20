import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_config.dart';
import 'core/services/locale_service.dart';
import 'core/services/locale_controller.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Supabase error: $e');
  }

  final localeCode = await LocaleService.getLocaleCode();
  LocaleController.notifier.value = Locale(localeCode);

  runApp(const KawakibApp());
}

class KawakibApp extends StatelessWidget {
  const KawakibApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleController.notifier,
      builder: (context, locale, child) {
        final isRtl = locale.languageCode == 'fa' || locale.languageCode == 'ar';

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: locale,
          supportedLocales: const [Locale('fa'), Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: const SplashScreen(),
          ),
        );
      },
    );
  }
}
