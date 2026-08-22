import 'supabase_config.dart';

class SupportTicket {
  final String id;
  final String subject;
  final String message;
  final String status; // open | answered | closed
  final String? adminReply;
  final DateTime createdAt;

  const SupportTicket({
    required this.id,
    required this.subject,
    required this.message,
    required this.status,
    required this.adminReply,
    required this.createdAt,
  });

  factory SupportTicket.fromMap(Map<String, dynamic> map) {
    return SupportTicket(
      id: map['id'] as String,
      subject: map['subject'] as String,
      message: map['message'] as String,
      status: map['status'] as String,
      adminReply: map['admin_reply'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class SupportService {
  static Future<void> submitTicket({required String subject, required String message}) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('کاربر وارد نشده است');

    await supabase.from('support_tickets').insert({
      'user_id': user.id,
      'subject': subject,
      'message': message,
    });
  }

  static Future<List<SupportTicket>> getMyTickets() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final rows = await supabase
        .from('support_tickets')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (rows as List).map((r) => SupportTicket.fromMap(r as Map<String, dynamic>)).toList();
  }

  /// تعداد پاسخ‌های خوانده‌نشده (برای نشون قرمز روی زنگوله‌ی صفحه‌ی اصلی).
  static Future<int> getUnreadReplyCount() async {
    final user = supabase.auth.currentUser;
    if (user == null) return 0;

    try {
      final rows = await supabase
          .from('support_tickets')
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'answered')
          .eq('user_read', false);
      return (rows as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// همه‌ی پاسخ‌های کاربر رو «خوانده‌شده» علامت می‌زنه (وقتی صفحه‌ی
  /// پشتیبانی رو باز می‌کنه).
  static Future<void> markAllRepliesRead() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase
          .from('support_tickets')
          .update({'user_read': true})
          .eq('user_id', user.id)
          .eq('status', 'answered')
          .eq('user_read', false);
    } catch (e) {
      // بی‌اهمیت؛ دفعه‌ی بعد دوباره تلاش می‌شه
    }
  }
}
