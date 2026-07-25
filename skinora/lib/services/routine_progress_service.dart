import 'package:flutter/material.dart';

/// Shared routine completion state — used by both RoutineScreen (Skin/Hair
/// tabs) and the Home Dashboard's "Today's Routine" summary, so ticking a
/// task in one place reflects everywhere. Currently in-memory only; swap
/// the internals for a real backend/local-storage call later without
/// changing how screens read from it.
class RoutineProgressService extends ChangeNotifier {
  static final RoutineProgressService _instance = RoutineProgressService._internal();
  factory RoutineProgressService() => _instance;
  RoutineProgressService._internal();

  final Map<String, List<Map<String, dynamic>>> skinRoutines = {
    'Morning Routine': [
      {'task': 'Cleanser', 'isCompleted': false},
      {'task': 'Vitamin C', 'isCompleted': false},
      {'task': 'Moisturizer', 'isCompleted': false},
      {'task': 'Sunscreen', 'isCompleted': false},
    ],
    'Afternoon Routine': [
      {'task': 'Reapply Sunscreen', 'isCompleted': false},
      {'task': 'Drink Water', 'isCompleted': false},
    ],
    'Night Routine': [
      {'task': 'Oil Cleanser', 'isCompleted': false},
      {'task': 'Face Wash', 'isCompleted': false},
      {'task': 'Night Serum', 'isCompleted': false},
      {'task': 'Moisturizer', 'isCompleted': false},
    ],
  };

  final Map<String, List<Map<String, dynamic>>> hairRoutines = {
    'Morning Hair Care': [
      {'task': 'Detangle Hair', 'isCompleted': false},
      {'task': 'Apply Hair Serum', 'isCompleted': false},
      {'task': 'Scalp Massage (2 min)', 'isCompleted': false},
    ],
    'Wash Day Routine': [
      {'task': 'Pre-wash Oiling', 'isCompleted': false},
      {'task': 'Shampoo', 'isCompleted': false},
      {'task': 'Conditioner', 'isCompleted': false},
      {'task': 'Hair Mask', 'isCompleted': false},
    ],
    'Night Hair Care': [
      {'task': 'Leave-in Conditioner', 'isCompleted': false},
      {'task': 'Braid / Loose Bun', 'isCompleted': false},
      {'task': 'Silk Pillowcase / Scarf', 'isCompleted': false},
    ],
  };

  void toggleTask(Map<String, List<Map<String, dynamic>>> routines, String routineName, int index) {
    routines[routineName]![index]['isCompleted'] = !(routines[routineName]![index]['isCompleted'] == true);
    notifyListeners();
  }

  void resetRoutine(Map<String, List<Map<String, dynamic>>> routines, String routineName) {
    for (var task in routines[routineName]!) {
      task['isCompleted'] = false;
    }
    notifyListeners();
  }

  void addTask(Map<String, List<Map<String, dynamic>>> routines, String routineName, String taskName) {
    routines[routineName]!.add({'task': taskName, 'isCompleted': false});
    notifyListeners();
  }

  void deleteTask(Map<String, List<Map<String, dynamic>>> routines, String routineName, int index) {
    routines[routineName]!.removeAt(index);
    notifyListeners();
  }

  // ---------- Combined summaries for the Home Dashboard ----------

  List<Map<String, dynamic>> get _morningTasks => [
        ...skinRoutines['Morning Routine']!,
        ...hairRoutines['Morning Hair Care']!,
      ];

  List<Map<String, dynamic>> get _nightTasks => [
        ...skinRoutines['Night Routine']!,
        ...hairRoutines['Night Hair Care']!,
      ];

  int get morningDoneCount => _morningTasks.where((t) => t['isCompleted'] == true).length;
  int get morningTotalCount => _morningTasks.length;
  bool get isMorningDone => morningTotalCount > 0 && morningDoneCount == morningTotalCount;

  int get nightDoneCount => _nightTasks.where((t) => t['isCompleted'] == true).length;
  int get nightTotalCount => _nightTasks.length;
  bool get isNightDone => nightTotalCount > 0 && nightDoneCount == nightTotalCount;
}