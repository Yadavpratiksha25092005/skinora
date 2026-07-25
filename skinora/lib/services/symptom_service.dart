import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/symptom_entry.dart';

/// Persists logged mood/symptom entries locally as a JSON list in shared_preferences.
class SymptomService {
  static final SymptomService _instance = SymptomService._internal();
  factory SymptomService() => _instance;
  SymptomService._internal();

  static const String _entriesKey = 'symptom_entries';

  Future<List<SymptomEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entriesKey);
    if (raw == null || raw.isEmpty) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    final entries = list
        .map((e) => SymptomEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    entries.sort((a, b) => b.date.compareTo(a.date)); // newest first
    return entries;
  }

  Future<void> addEntry(SymptomEntry entry) async {
    final entries = await getEntries();
    entries.removeWhere((e) => e.id == entry.id);
    entries.add(entry);
    await _saveEntries(entries);
  }

  Future<void> deleteEntry(String id) async {
    final entries = await getEntries();
    entries.removeWhere((e) => e.id == id);
    await _saveEntries(entries);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns the entry logged for [date] if one exists, so it can be edited.
  Future<SymptomEntry?> getEntryForDate(DateTime date) async {
    final entries = await getEntries();
    for (final entry in entries) {
      if (_isSameDay(entry.date, date)) return entry;
    }
    return null;
  }

  Future<void> _saveEntries(List<SymptomEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_entriesKey, raw);
  }
}
