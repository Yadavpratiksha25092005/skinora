import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cycle_entry.dart';

/// Persists and derives predictions from logged period cycle entries.
/// All entries are stored locally as a JSON list in shared_preferences.
class CycleService {
  static final CycleService _instance = CycleService._internal();
  factory CycleService() => _instance;
  CycleService._internal();

  static const String _entriesKey = 'cycle_entries';
  static const String _manualCycleLengthKey = 'cycle_manual_average_length';
  static const int _defaultCycleLength = 28;

  /// Whether the user has logged at least one cycle entry yet — used to
  /// decide whether to show the first-time Quick Setup flow.
  Future<bool> hasAnyEntries() async {
    final entries = await getEntries();
    return entries.isNotEmpty;
  }

  /// Stores a manually entered average cycle length (from Quick Setup) so
  /// predictions have something better than the 28-day default before two
  /// real entries exist to compute an average from.
  Future<void> saveManualCycleLength(int length) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_manualCycleLengthKey, length);
  }

  Future<List<CycleEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entriesKey);
    if (raw == null || raw.isEmpty) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    final entries = list
        .map((e) => CycleEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    entries.sort((a, b) => b.startDate.compareTo(a.startDate)); // newest first
    return entries;
  }

  Future<void> addEntry(CycleEntry entry) async {
    final entries = await getEntries();
    entries.add(entry);
    await _saveEntries(entries);
  }

  Future<void> deleteEntry(String id) async {
    final entries = await getEntries();
    entries.removeWhere((e) => e.id == id);
    await _saveEntries(entries);
  }

  Future<void> _saveEntries(List<CycleEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_entriesKey, raw);
  }

  /// Average number of days between consecutive cycle start dates.
  /// Falls back to a manually entered estimate (from Quick Setup) when
  /// fewer than 2 entries exist, or the standard 28-day cycle if neither is available.
  Future<int> calculateAverageCycleLength() async {
    final entries = await getEntries();
    if (entries.length < 2) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_manualCycleLengthKey) ?? _defaultCycleLength;
    }

    // Oldest -> newest so the differences are all positive.
    final sorted = [...entries]..sort((a, b) => a.startDate.compareTo(b.startDate));

    var totalDays = 0;
    for (var i = 1; i < sorted.length; i++) {
      totalDays += sorted[i].startDate.difference(sorted[i - 1].startDate).inDays;
    }

    final average = totalDays / (sorted.length - 1);
    return average.round();
  }

  /// Predicts the next period's start date from the most recent entry.
  /// Returns null if no entries have been logged yet.
  Future<DateTime?> predictNextPeriod() async {
    final entries = await getEntries();
    if (entries.isEmpty) return null;

    final lastEntry = entries.first; // already sorted newest first
    final averageCycleLength = await calculateAverageCycleLength();
    return lastEntry.startDate.add(Duration(days: averageCycleLength));
  }

  /// Predicts the approximate ovulation date: ~14 days before the next period.
  Future<DateTime?> predictOvulation() async {
    final nextPeriod = await predictNextPeriod();
    if (nextPeriod == null) return null;
    return nextPeriod.subtract(const Duration(days: 14));
  }

  /// Determines the user's current cycle phase — 'Period', 'Follicular',
  /// 'Ovulation', or 'Luteal'. Returns null if no entries exist yet (so
  /// phase-based recommendations can be hidden for first-time users).
  Future<String?> getCurrentPhase() async {
    final entries = await getEntries();
    if (entries.isEmpty) return null;

    final lastEntry = entries.first; // newest first
    final today = DateTime.now();
    final startDate = DateTime(lastEntry.startDate.year, lastEntry.startDate.month, lastEntry.startDate.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysSinceStart = todayDate.difference(startDate).inDays;

    if (daysSinceStart < 0) return null; // logged a future date, unclear state

    final periodDuration = lastEntry.endDate != null
        ? lastEntry.endDate!.difference(lastEntry.startDate).inDays + 1
        : 5;

    final averageCycleLength = await calculateAverageCycleLength();
    final ovulationDay = (averageCycleLength - 14).clamp(1, averageCycleLength);

    if (daysSinceStart < periodDuration) {
      return 'Period';
    } else if (daysSinceStart < ovulationDay) {
      return 'Follicular';
    } else if (daysSinceStart <= ovulationDay + 1) {
      return 'Ovulation';
    } else if (daysSinceStart < averageCycleLength) {
      return 'Luteal';
    } else {
      return 'Luteal';
    }
  }
}