import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/progress_entry.dart';

/// Handles saving/loading progress photo entries.
///
/// NOTE: Photos are currently stored as local file paths only (on-device).
/// Once the backend adds S3 upload support, this service is the only place
/// that needs to change — swap local file storage for an upload + URL flow.
/// The UI (ProgressScreen, comparison view) won't need to change.
class ProgressService {
  static const String _prefsKey = 'progress_entries_v1';

  Future<List<ProgressEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    final entries = raw.map((s) => ProgressEntry.fromJson(jsonDecode(s))).toList();
    entries.sort((a, b) => b.date.compareTo(a.date)); // newest first
    return entries;
  }

  Future<void> addEntry(ProgressEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getEntries();
    entries.insert(0, entry);
    final raw = entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_prefsKey, raw);
  }

  Future<void> deleteEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getEntries();
    entries.removeWhere((e) => e.id == id);
    final raw = entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_prefsKey, raw);
  }

  /// Groups entries by "Month Year" (e.g. "July 2026") for the timeline view.
  Map<String, List<ProgressEntry>> groupByMonth(List<ProgressEntry> entries) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final Map<String, List<ProgressEntry>> grouped = {};
    for (final entry in entries) {
      final key = '${months[entry.date.month - 1]} ${entry.date.year}';
      grouped.putIfAbsent(key, () => []).add(entry);
    }
    return grouped;
  }
}