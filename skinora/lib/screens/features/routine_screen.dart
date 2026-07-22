import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  // Mock state for routines
  final Map<String, List<Map<String, dynamic>>> _routines = {
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
    ]
  };

  void _toggleTask(String routineName, int index) {
    setState(() {
      _routines[routineName]![index]['isCompleted'] = !_routines[routineName]![index]['isCompleted'];
    });
  }

  void _resetRoutine(String routineName) {
    setState(() {
      for (var task in _routines[routineName]!) {
        task['isCompleted'] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              'Your Routines',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const SizedBox(height: 24),
          ..._routines.keys.map((routineName) {
            final tasks = _routines[routineName]!;
            final completedCount = tasks.where((t) => t['isCompleted']).length;
            final progress = completedCount / tasks.length;
            
            return FadeInUp(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                routineName,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 6,
                                        backgroundColor: AppTheme.secondaryColor,
                                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${(progress * 100).toInt()}%',
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                                  ),
                                ],
                              )
                            ],
                          ),
                          TextButton(
                            onPressed: () => _resetRoutine(routineName),
                            child: const Text('Reset', style: TextStyle(color: Colors.grey)),
                          )
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppTheme.secondaryColor),
                    ...tasks.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final task = entry.value;
                      final isCompleted = task['isCompleted'];

                      return InkWell(
                        onTap: () => _toggleTask(routineName, idx),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCompleted ? AppTheme.primaryColor : Colors.transparent,
                                  border: Border.all(
                                    color: isCompleted ? AppTheme.primaryColor : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: isCompleted
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                task['task'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500,
                                  color: isCompleted ? AppTheme.textPrimaryColor : AppTheme.textSecondaryColor,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
