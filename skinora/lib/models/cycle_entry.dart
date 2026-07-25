/// A single logged menstrual cycle entry.
class CycleEntry {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final String flowIntensity; // light / medium / heavy

  const CycleEntry({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.flowIntensity,
  });

  CycleEntry copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? flowIntensity,
  }) {
    return CycleEntry(
      id: id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      flowIntensity: flowIntensity ?? this.flowIntensity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'flowIntensity': flowIntensity,
    };
  }

  factory CycleEntry.fromJson(Map<String, dynamic> json) {
    return CycleEntry(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      flowIntensity: json['flowIntensity'] as String? ?? 'medium',
    );
  }
}
