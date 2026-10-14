import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalCustomerStore {
  static const _storage = FlutterSecureStorage();
  
  static const String _favoritesKey = 'favorite_restaurant_ids';
  static const String _recentViewsKey = 'recently_viewed_ids';
  static const String _recentSearchesKey = 'recent_searches_list';

  // Read list and convert internal string elements back to integers natively
  static Future<List<int>> _getIntList(String key) async {
    final data = await _storage.read(key: key);
    if (data == null) return [];
    try {
      final List<dynamic> decoded = json.decode(data);
      return decoded.map((e) => int.tryParse(e.toString())).whereType<int>().toList();
    } catch (_) {
      return [];
    }
  }

  // Fetch favorite restaurant IDs as integers
  static Future<List<int>> favoriteRestaurantIds() async {
    return await _getIntList(_favoritesKey);
  }

  // Fetch recently viewed restaurant IDs as integers
  static Future<List<int>> recentlyViewedIds() async {
    return await _getIntList(_recentViewsKey);
  }

  /// Searches kept in history, newest first.
  static const maxSearches = 8;

  /// Newest first, without half-typed duplicates: "pr", "pro" and "prof"
  /// are dropped when "profile" is there too (older versions saved every
  /// keystroke).
  static List<String> tidySearches(Iterable<String> searches) {
    final kept = <String>[];
    for (final raw in searches) {
      final query = raw.trim();
      if (query.length < 2) continue;
      final lower = query.toLowerCase();
      final covered = kept.any((k) => k.toLowerCase().startsWith(lower));
      if (covered) continue;
      kept.removeWhere((k) => lower.startsWith(k.toLowerCase()));
      kept.add(query);
    }
    return kept.take(maxSearches).toList();
  }

  static Future<List<String>> recentSearches() async {
    final data = await _storage.read(key: _recentSearchesKey);
    if (data == null) return [];
    try {
      final stored = List<String>.from(json.decode(data));
      final tidy = tidySearches(stored);
      if (tidy.length != stored.length) {
        await _storage.write(key: _recentSearchesKey, value: json.encode(tidy));
      }
      return tidy;
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearSearches() => _storage.delete(key: _recentSearchesKey);

  // Toggle restaurant favorite status natively using an integer
  static Future<void> toggleFavorite(int restaurantId) async {
    final recents = await _getIntList(_favoritesKey);
    final List<String> stringList = recents.map((e) => e.toString()).toList();
    final idString = restaurantId.toString();

    if (stringList.contains(idString)) {
      stringList.remove(idString);
    } else {
      stringList.add(idString);
    }
    await _storage.write(key: _favoritesKey, value: json.encode(stringList));
  }

  // Append new item to recently viewed history list using an integer
  static Future<void> addRecentlyViewed(int restaurantId) async {
    final recents = await _getIntList(_recentViewsKey);
    final List<String> stringList = recents.map((e) => e.toString()).toList();
    final idString = restaurantId.toString();

    stringList.remove(idString); 
    stringList.insert(0, idString); 
    if (stringList.length > 10) stringList.removeLast(); 
    await _storage.write(key: _recentViewsKey, value: json.encode(stringList));
  }

  // Append a query search keyword tracking string
  static Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;
    final data = await _storage.read(key: _recentSearchesKey);
    List<String> searches = [];
    if (data != null) {
      try { searches = List<String>.from(json.decode(data)); } catch (_) {}
    }
    searches = tidySearches([query.trim(), ...searches]);
    await _storage.write(key: _recentSearchesKey, value: json.encode(searches));
  }
}
