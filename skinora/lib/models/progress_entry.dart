class ProgressEntry {
  final String id;
  final String imagePath; // local file path on device
  final String note;
  final String category; // "Skin" or "Hair"
  final DateTime date;

  ProgressEntry({
    required this.id,
    required this.imagePath,
    required this.note,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'note': note,
        'category': category,
        'date': date.toIso8601String(),
      };

  factory ProgressEntry.fromJson(Map<String, dynamic> json) => ProgressEntry(
        id: json['id'],
        imagePath: json['imagePath'],
        note: json['note'] ?? '',
        category: json['category'] ?? 'Skin',
        date: DateTime.parse(json['date']),
      );
}