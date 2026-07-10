import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item_model.dart';

class HistoryLocalDataSource {
  static const String _key = 'history_items';

  Future<List<HistoryItemModel>> getHistoryItems() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list
        .map((item) => HistoryItemModel.fromJson(json.decode(item) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first
  }

  Future<void> saveHistoryItem(HistoryItemModel item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];

    // Remove if already exists to update or avoid duplicates
    list.removeWhere((element) {
      final decoded = json.decode(element) as Map<String, dynamic>;
      return decoded['id'] == item.id;
    });

    list.add(json.encode(item.toJson()));
    await prefs.setStringList(_key, list);
  }

  Future<void> deleteHistoryItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.removeWhere((element) {
      final decoded = json.decode(element) as Map<String, dynamic>;
      return decoded['id'] == id;
    });
    await prefs.setStringList(_key, list);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
