import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_config.dart';

class FamilyMember {
  final String id;
  final String relation; // 'همسر' | 'فرزند' | 'دوست' | 'همکار'
  final String name;
  final int day;
  final int month;
  final int year;

  const FamilyMember({
    required this.id,
    required this.relation,
    required this.name,
    required this.day,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'relation': relation,
        'name': name,
        'day': day,
        'month': month,
        'year': year,
      };

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
        id: json['id'] as String,
        relation: json['relation'] as String,
        name: json['name'] as String,
        day: json['day'] as int,
        month: json['month'] as int,
        year: json['year'] as int,
      );
}

class FamilyMembersService {
  static const _key = 'family_members_list';

  /// خواندن لیست اعضا: اول محلی؛ اگر محلی خالی بود ولی کاربر لاگین بود،
  /// از سرور می‌خواند و محلی را هم پر می‌کند.
  static Future<List<FamilyMember>> getMembers() async {
    final local = await _getLocal();
    if (local.isNotEmpty) return local;

    final remote = await _getRemote();
    if (remote.isNotEmpty) {
      await _saveLocal(remote);
    }
    return remote;
  }

  static Future<void> addMember(FamilyMember member) async {
    final members = await _getLocal();
    members.add(member);
    await _saveLocal(members);
    await _addRemoteIfPossible(member);
  }

  static Future<void> removeMember(String id) async {
    final members = await _getLocal();
    members.removeWhere((m) => m.id == id);
    await _saveLocal(members);
    await _removeRemoteIfPossible(id);
  }

  // ---------- محلی ----------

  static Future<List<FamilyMember>> _getLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => FamilyMember.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> _saveLocal(List<FamilyMember> members) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(members.map((m) => m.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  // ---------- سرور (Supabase) ----------

  static Future<List<FamilyMember>> _getRemote() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await supabase.from('family_members').select().eq('user_id', user.id);
      final rows = response as List;
      return rows
          .map((r) => FamilyMember(
                id: r['id'] as String,
                relation: r['relation'] as String,
                name: r['name'] as String,
                day: r['birth_day'] as int,
                month: r['birth_month'] as int,
                year: r['birth_year'] as int,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> _addRemoteIfPossible(FamilyMember member) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      await supabase.from('family_members').insert({
        'user_id': user.id,
        'relation': member.relation,
        'name': member.name,
        'birth_day': member.day,
        'birth_month': member.month,
        'birth_year': member.year,
      });
    } catch (e) {
      // اگر سرور شکست خورد، نسخه‌ی محلی همچنان کار می‌کند.
    }
  }

  static Future<void> _removeRemoteIfPossible(String id) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      await supabase.from('family_members').delete().eq('id', id).eq('user_id', user.id);
    } catch (e) {
      // نادیده گرفته می‌شود.
    }
  }
}
