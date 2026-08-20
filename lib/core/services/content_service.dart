import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ContentItem {
  final String id;
  final String title;
  final String icon;
  final String accessLevel;
  final String route;

  ContentItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.accessLevel,
    required this.route,
  });

  factory ContentItem.fromMap(Map<String, dynamic> map) {
    return ContentItem(
      id: map['id'],
      title: map['title'],
      icon: map['icon'] ?? 'sparkles',
      accessLevel: map['access_level'] ?? 'free',
      route: map['route'] ?? '',
    );
  }
}

class ContentCategory {
  final String id;
  final String title;
  final String icon;
  final List<ContentItem> items;

  ContentCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.items,
  });
}

class ContentService {
  static Future<List<ContentCategory>> getHomeContent() async {
    final categories = await supabase
        .from('content_categories')
        .select()
        .eq('is_active', true)
        .order('sort_order');

    final items = await supabase
        .from('content_items')
        .select()
        .eq('is_active', true)
        .order('sort_order');

    final itemsByCategory = <String, List<ContentItem>>{};

    for (final row in items as List) {
      final categoryId = row['category_id'] as String;
      itemsByCategory.putIfAbsent(categoryId, () => []);
      itemsByCategory[categoryId]!.add(ContentItem.fromMap(row));
    }

    return (categories as List)
        .map((c) => ContentCategory(
              id: c['id'],
              title: c['title'],
              icon: c['icon'] ?? 'sparkles',
              items: itemsByCategory[c['id']] ?? [],
            ))
        .toList();
  }
}