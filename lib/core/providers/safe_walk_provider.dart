import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final safeWalkProvider = StateNotifierProvider<SafeWalkNotifier, bool>((ref) {
  return SafeWalkNotifier();
});

class SafeWalkNotifier extends StateNotifier<bool> {
  SafeWalkNotifier() : super(true) {
    _loadPreference();
  }

  static const String _prefKey = 'safe_walk_enabled';

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_prefKey) ?? true; 
  }

  Future<void> setSafeWalk(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
    state = enabled;
  }
}
