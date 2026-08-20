import 'package:supabase_flutter/supabase_flutter.dart';

class AiChatService {
  static final _supabase = Supabase.instance.client;

  static Future<String> sendMessage(String message) async {
    try {
      final response = await _supabase.functions.invoke(
        'ai-chat',
        body: {'message': message},
      );

      if (response.data == null) {
        return 'پاسخی دریافت نشد';
      }

      if (response.data is Map && response.data['reply'] != null) {
        return response.data['reply'].toString();
      }

      return response.data.toString();
    } catch (e) {
      return 'خطا: $e';
    }
  }
}