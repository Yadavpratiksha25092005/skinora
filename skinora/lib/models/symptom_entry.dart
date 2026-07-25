/// A single day's mood, symptom and energy log.
class SymptomEntry {
  final String id;
  final DateTime date;
  final String mood; // e.g. "😊 Happy"
  final List<String> symptoms;
  final int energyLevel; // 1-5
  final String notes;

  const SymptomEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.symptoms,
    required this.energyLevel,
    this.notes = '',
  });

  SymptomEntry copyWith({
    DateTime? date,
    String? mood,
    List<String>? symptoms,
    int? energyLevel,
    String? notes,
  }) {
    return SymptomEntry(
      id: id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      symptoms: symptoms ?? this.symptoms,
      energyLevel: energyLevel ?? this.energyLevel,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood,
      'symptoms': symptoms,
      'energyLevel': energyLevel,
      'notes': notes,
    };
  }

  factory SymptomEntry.fromJson(Map<String, dynamic> json) {
    return SymptomEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: json['mood'] as String? ?? '',
      symptoms: (json['symptoms'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
      energyLevel: json['energyLevel'] as int? ?? 3,
      notes: json['notes'] as String? ?? '',
    );
  }
}
