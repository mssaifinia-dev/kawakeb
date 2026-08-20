import 'supabase_config.dart';

class AdminUserRow {
  final String userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? motherName;
  final String tier;
  final DateTime? createdAt;

  const AdminUserRow({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.motherName,
    required this.tier,
    required this.createdAt,
  });
}

class AdminStats {
  final int total;
  final int free;
  final int gold;
  final int vip;
  final int newThisWeek;

  const AdminStats({
    required this.total,
    required this.free,
    required this.gold,
    required this.vip,
    required this.newThisWeek,
  });
}

class PlanRow {
  final String tier;
  final int priceToman;
  final int durationDays;

  const PlanRow({
    required this.tier,
    required this.priceToman,
    required this.durationDays,
  });
}

class FeatureAccessRow {
  final String featureKey;
  final String label;
  final String tier;

  const FeatureAccessRow({
    required this.featureKey,
    required this.label,
    required this.tier,
  });
}

class SupportTicketRow {
  final String id;
  final String userId;
  final String? userName;
  final String? userPhone;
  final String subject;
  final String message;
  final String status;
  final String? adminReply;
  final DateTime createdAt;

  const SupportTicketRow({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.subject,
    required this.message,
    required this.status,
    required this.adminReply,
    required this.createdAt,
  });
}

class AdminService {
  static Future<bool> isCurrentUserAdmin() async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    try {
      final response = await supabase
          .from('admins')
          .select('user_id')
          .eq('user_id', user.id)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// همه‌ی کاربران (از جدول profiles) به‌همراه سطح اشتراک فعلی‌شان.
  static Future<List<AdminUserRow>> getAllUsers() async {
    final profiles = await supabase
        .from('profiles')
        .select('id, email, phone, name, mother_name, created_at');
    final subscriptions = await supabase.from('subscriptions').select('user_id, tier');

    final tierByUserId = <String, String>{};
    for (final row in subscriptions as List) {
      tierByUserId[row['user_id'] as String] = row['tier'] as String;
    }

    final rows = (profiles as List).map((row) {
      final id = row['id'] as String;
      final createdAtRaw = row['created_at'] as String?;
      return AdminUserRow(
        userId: id,
        name: row['name'] as String?,
        email: row['email'] as String?,
        phone: row['phone'] as String?,
        motherName: row['mother_name'] as String?,
        tier: tierByUserId[id] ?? 'free',
        createdAt: createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null,
      );
    }).toList();

    // جدیدترین کاربرها بالای لیست
    rows.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });

    return rows;
  }

  static Future<void> setUserTier(String userId, String tier) async {
    final admin = supabase.auth.currentUser;
    await supabase.from('subscriptions').upsert({
      'user_id': userId,
      'tier': tier,
      'granted_by': admin?.id,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// آمار خلاصه برای بالای پنل مدیریت: تعداد کل، تعداد هر سطح اشتراک،
  /// و تعداد ثبت‌نام‌های هفته‌ی اخیر.
  static AdminStats computeStats(List<AdminUserRow> users) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    int free = 0, gold = 0, vip = 0, newThisWeek = 0;

    for (final u in users) {
      switch (u.tier) {
        case 'gold':
          gold++;
          break;
        case 'vip':
          vip++;
          break;
        default:
          free++;
      }
      if (u.createdAt != null && u.createdAt!.isAfter(weekAgo)) {
        newThisWeek++;
      }
    }

    return AdminStats(
      total: users.length,
      free: free,
      gold: gold,
      vip: vip,
      newThisWeek: newThisWeek,
    );
  }

  /// قیمت و مدت فعلی اشتراک طلایی و VIP رو می‌خونه.
  static Future<List<PlanRow>> getPlans() async {
    final rows = await supabase.from('plans').select('tier, price_toman, duration_days');
    return (rows as List)
        .map((row) => PlanRow(
              tier: row['tier'] as String,
              priceToman: row['price_toman'] as int,
              durationDays: row['duration_days'] as int,
            ))
        .toList();
  }

  /// قیمت یا مدت یک سطح اشتراک (gold یا vip) رو تغییر می‌ده.
  static Future<void> updatePlan(String tier, {required int priceToman, required int durationDays}) async {
    await supabase.from('plans').upsert({
      'tier': tier,
      'price_toman': priceToman,
      'duration_days': durationDays,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// رمز عبور یک کاربر رو ریست می‌کنه. فقط خود ادمین‌ها (طبق چک سمت سرور) اجازه دارن.
  /// اگه موفق بود null برمی‌گردونه، وگرنه پیام خطا.
  static Future<String?> resetUserPassword(String userId, String newPassword) async {
    final res = await supabase.functions.invoke(
      'admin-reset-password',
      body: {'userId': userId, 'newPassword': newPassword},
    );
    if (res.status != 200) {
      final data = res.data as Map<String, dynamic>?;
      return (data?['error'] as String?) ?? 'خطا در ریست رمز';
    }
    return null;
  }

  /// همه‌ی تیکت‌های پشتیبانی رو با اطلاعات کاربر مربوطه می‌خونه.
  static Future<List<SupportTicketRow>> getAllTickets() async {
    final tickets = await supabase
        .from('support_tickets')
        .select('id, user_id, subject, message, status, admin_reply, created_at')
        .order('created_at', ascending: false);

    final profiles = await supabase.from('profiles').select('id, name, phone');
    final profileById = <String, Map<String, dynamic>>{
      for (final p in profiles as List) (p['id'] as String): p as Map<String, dynamic>,
    };

    return (tickets as List).map((row) {
      final userId = row['user_id'] as String;
      final profile = profileById[userId];
      return SupportTicketRow(
        id: row['id'] as String,
        userId: userId,
        userName: profile?['name'] as String?,
        userPhone: profile?['phone'] as String?,
        subject: row['subject'] as String,
        message: row['message'] as String,
        status: row['status'] as String,
        adminReply: row['admin_reply'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
    }).toList();
  }

  /// جواب دادن به تیکت؛ وضعیت خودکار answered می‌شه.
  static Future<void> replyToTicket(String ticketId, String reply) async {
    await supabase.from('support_tickets').update({
      'admin_reply': reply,
      'status': 'answered',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', ticketId);
  }

  static Future<void> setTicketStatus(String ticketId, String status) async {
    await supabase.from('support_tickets').update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', ticketId);
  }

  /// حذف کامل یک کاربر (حساب + پروفایل + اشتراک + تیکت‌هاش).
  /// اگه موفق بود null برمی‌گردونه، وگرنه پیام خطا.
  static Future<String?> deleteUser(String userId) async {
    final res = await supabase.functions.invoke(
      'admin-delete-user',
      body: {'userId': userId},
    );
    if (res.status != 200) {
      final data = res.data as Map<String, dynamic>?;
      return (data?['error'] as String?) ?? 'خطا در حذف کاربر';
    }
    return null;
  }

  /// لیست سطح دسترسی فال‌ها (کدوم فال رایگانه، کدوم طلایی، کدوم VIP).
  static Future<List<FeatureAccessRow>> getFeatureAccess() async {
    final rows = await supabase.from('feature_access').select().order('label');
    return (rows as List)
        .map((row) => FeatureAccessRow(
              featureKey: row['feature_key'] as String,
              label: row['label'] as String,
              tier: row['tier'] as String,
            ))
        .toList();
  }

  /// اضافه‌کردن یا ویرایش سطح دسترسی یک فال.
  static Future<void> upsertFeatureAccess({
    required String featureKey,
    required String label,
    required String tier,
  }) async {
    await supabase.from('feature_access').upsert({
      'feature_key': featureKey,
      'label': label,
      'tier': tier,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> deleteFeatureAccess(String featureKey) async {
    await supabase.from('feature_access').delete().eq('feature_key', featureKey);
  }
}
