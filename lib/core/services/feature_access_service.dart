import 'package:flutter/material.dart';
import 'supabase_config.dart';
import '../theme/app_colors.dart';
import '../../features/subscription/presentation/subscription_screen.dart';

class FeatureAccessService {
  static const List<String> tierOrder = [
    'free',
    'gold',
    'vip',
  ];

  static const Map<String, String> tierLabels = {
    'free': 'رایگان',
    'gold': 'طلایی',
    'vip': 'VIP',
  };

  /// منطق مرکزی: سطح واقعی/مؤثر یک اشتراک با توجه به تاریخ انقضا.
  /// همه‌جای اپ (چک دسترسی فال‌ها، پروفایل، پنل ادمین) باید
  /// از همین تابع استفاده کنه تا هیچ‌وقت جایی از جای دیگه عقب نیفته.
  static String effectiveTierOf(String? tier, DateTime? expiresAt) {
    final rawTier = tier ?? 'free';

    if (!tierOrder.contains(rawTier)) {
      return 'free';
    }

    if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
      return 'free';
    }

    return rawTier;
  }

  /// سطح اشتراک فعلی کاربر
  static Future<String> getCurrentUserTier() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return 'free';
    }

    try {
      final row = await supabase
          .from('subscriptions')
          .select('tier, expires_at')
          .eq('user_id', user.id)
          .maybeSingle();

      if (row == null) {
        return 'free';
      }

      final expiresRaw = row['expires_at'] as String?;
      final expiresAt = expiresRaw != null ? DateTime.tryParse(expiresRaw) : null;

      return effectiveTierOf(row['tier'] as String?, expiresAt);
    } catch (_) {
      return 'free';
    }
  }

  /// سطح لازم برای یک فال
  ///
  /// اگر در feature_access تعریف نشده باشد،
  /// طبق منطق پنل ادمین، رایگان است.
  static Future<String> getRequiredTier(String featureKey) async {
    try {
      final row = await supabase
          .from('feature_access')
          .select('tier')
          .eq('feature_key', featureKey)
          .maybeSingle();

      if (row == null) {
        return 'free';
      }

      final tier = row['tier'] as String? ?? 'free';

      if (!tierOrder.contains(tier)) {
        return 'free';
      }

      return tier;
    } catch (_) {
      return 'free';
    }
  }

  /// آیا کاربر اجازه ورود دارد؟
  static Future<bool> canAccess(String featureKey) async {
    final userTier = await getCurrentUserTier();
    final requiredTier = await getRequiredTier(featureKey);

    final userIndex = tierOrder.indexOf(userTier);
    final requiredIndex = tierOrder.indexOf(requiredTier);

    return userIndex >= requiredIndex;
  }

  /// بررسی دسترسی و در صورت نداشتن دسترسی،
  /// پیام ارتقای اشتراک را نمایش می‌دهد.
  ///
  /// اگر کاربر «ارتقا بده» رو بزنه، مستقیم به صفحه‌ی اشتراک
  /// با پلن درست‌ازقبل‌انتخاب‌شده هدایت می‌شه و خودکار وارد
  /// فرآیند پرداخت می‌شه.
  static Future<bool> checkAccess(
    BuildContext context, {
    required String featureKey,
    required String featureTitle,
  }) async {
    final userTier = await getCurrentUserTier();
    final requiredTier = await getRequiredTier(featureKey);

    final userIndex = tierOrder.indexOf(userTier);
    final requiredIndex = tierOrder.indexOf(requiredTier);

    if (userIndex >= requiredIndex) {
      return true;
    }

    if (!context.mounted) {
      return false;
    }

    final requiredLabel =
        tierLabels[requiredTier] ?? requiredTier;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            featureTitle,
            textAlign: TextAlign.right,
          ),
          content: Text(
            'این فال مخصوص اشتراک $requiredLabel است.\n\n'
            'برای دسترسی، اشتراکت رو ارتقا بده.',
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('فعلاً نه'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);

                if (!context.mounted) return;

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SubscriptionScreen(
                      preselectedTier: requiredTier,
                    ),
                  ),
                );
              },
              child: const Text('ارتقا بده'),
            ),
          ],
        );
      },
    );

    return false;
  }

  /// اجرای مستقیم یک صفحه با کنترل دسترسی
  static Future<void> open(
    BuildContext context, {
    required String featureKey,
    required String featureTitle,
    required WidgetBuilder builder,
  }) async {
    final allowed = await checkAccess(
      context,
      featureKey: featureKey,
      featureTitle: featureTitle,
    );

    if (!allowed || !context.mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: builder),
    );
  }
}