import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared daily water intake state — used by both WaterTrackerScreen and the
/// Home Dashboard's "Today at a Glance" card, so logging a glass in one
/// place reflects everywhere immediately. Persisted locally via
/// shared_preferences, resetting automatically on a new day.
class WaterService extends ChangeNotifier {
  static final WaterService _instance = WaterService._internal();
  factory WaterService() => _instance;
  WaterService._internal() {
    _load();
  }

  static const String _countKey = 'water_count';
  static const String _dateKey = 'water_date';
  static const int goal = 8;

  int _currentCount = 0;
  bool _loaded = false;

  int get currentCount => _currentCount;
  bool get isLoaded => _loaded;

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_dateKey);
    final savedCount = prefs.getInt(_countKey) ?? 0;

    // Only restore the count if it was saved today; a new day starts fresh.
    _currentCount = savedDate == _todayKey ? savedCount : 0;
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dateKey, _todayKey);
    await prefs.setInt(_countKey, _currentCount);
  }

  Future<void> addGlass() async {
    if (_currentCount < goal) {
      _currentCount++;
      notifyListeners();
      await _save();
    }
  }

  Future<void> removeGlass() async {
    if (_currentCount > 0) {
      _currentCount--;
      notifyListeners();
      await _save();
    }
  }
}
