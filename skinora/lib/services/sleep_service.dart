import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SleepEntry {
  final String date; // yyyy-MM-dd
  final int bedHour, bedMinute;
  final int wakeHour, wakeMinute;
  final int durationMinutes;

  SleepEntry({
    required this.date,
    required this.bedHour,
    required this.bedMinute,
    required this.wakeHour,
    required this.wakeMinute,
    required this.durationMinutes,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'bedHour': bedHour,
        'bedMinute': bedMinute,
        'wakeHour': wakeHour,
        'wakeMinute': wakeMinute,
        'durationMinutes': durationMinutes,
      };

  factory SleepEntry.fromJson(Map<String, dynamic> json) => SleepEntry(
        date: json['date'],
        bedHour: json['bedHour'],
        bedMinute: json['bedMinute'],
        wakeHour: json['wakeHour'],
        wakeMinute: json['wakeMinute'],
        durationMinutes: json['durationMinutes'],
      );

  String get timeRangeLabel {
    String fmt(int h, int m) {
      final period = h >= 12 ? 'PM' : 'AM';
      final displayHour = h % 12 == 0 ? 12 : h % 12;
      return '$displayHour:${m.toString().padLeft(2, '0')} $period';
    }

    return '${fmt(bedHour, bedMinute)} - ${fmt(wakeHour, wakeMinute)}';
  }

  String get durationLabel {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return '${h}h ${m}m';
  }

  double get durationHours => durationMinutes / 60;
}

/// Shared sleep history state — used by both SleepTrackerScreen and the Home
/// Dashboard's "Today at a Glance" card, so logging sleep in one place
/// reflects everywhere immediately. Persisted locally via shared_preferences.
class SleepService extends ChangeNotifier {
  static final SleepService _instance = SleepService._internal();
  factory SleepService() => _instance;
  SleepService._internal() {
    _load();
  }

  static const String _prefsKey = 'sleep_history_v1';

  List<SleepEntry> _history = [];
  bool _loaded = false;

  List<SleepEntry> get history => _history;
  bool get isLoaded => _loaded;

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Today's logged sleep entry, if any.
  SleepEntry? get todayEntry =>
      (_history.isNotEmpty && _history.first.date == _todayKey) ? _history.first : null;

  /// Hours slept last night, or 0 if nothing has been logged today.
  double get lastNightHours => todayEntry?.durationHours ?? 0;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    _history = raw.map((s) => SleepEntry.fromJson(jsonDecode(s))).toList();
    _history.sort((a, b) => b.date.compareTo(a.date)); // newest first
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _history.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_prefsKey, raw);
  }

  int calculateDuration(TimeOfDay bed, TimeOfDay wake) {
    final bedMinutes = bed.hour * 60 + bed.minute;
    var wakeMinutes = wake.hour * 60 + wake.minute;
    if (wakeMinutes <= bedMinutes) wakeMinutes += 24 * 60; // crossed midnight
    return wakeMinutes - bedMinutes;
  }

  Future<void> logSleep(TimeOfDay bed, TimeOfDay wake) async {
    final duration = calculateDuration(bed, wake);
    final entry = SleepEntry(
      date: _todayKey,
      bedHour: bed.hour,
      bedMinute: bed.minute,
      wakeHour: wake.hour,
      wakeMinute: wake.minute,
      durationMinutes: duration,
    );

    // Replace today's entry if it already exists.
    _history.removeWhere((e) => e.date == _todayKey);
    _history.insert(0, entry);
    notifyListeners();
    await _save();
  }
}
