import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../core/theme/app_theme.dart';

/// One routine block (e.g. "Morning Routine") with a progress bar,
/// a reset action, an editable checklist (swipe to delete), and an
/// "Add step" row to add custom tasks.
class RoutineSectionCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> tasks;
  final ValueChanged<int> onToggleTask;
  final VoidCallback onReset;
  final ValueChanged<int>? onDeleteTask;
  final ValueChanged<String>? onAddTask;

  const RoutineSectionCard({
    super.key,
    required this.title,
    required this.tasks,
    required this.onToggleTask,
    required this.onReset,
    this.onDeleteTask,
    this.onAddTask,
  });

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add step'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Niacinamide Serum'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null && onAddTask != null) {
      onAddTask!(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks.where((t) => t['isCompleted'] == true).length;
    final progress = tasks.isEmpty ? 0.0 : completedCount / tasks.length;

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
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
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
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    onSelected: (value) {
                      if (value == 'add') _showAddTaskDialog(context);
                      if (value == 'reset') onReset();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'add', child: Text('Add step')),
                      const PopupMenuItem(value: 'reset', child: Text('Reset today')),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.secondaryColor),
            ...tasks.asMap().entries.map((entry) {
              final idx = entry.key;
              final task = entry.value;
              final isCompleted = task['isCompleted'] == true;

              return Dismissible(
                key: ValueKey('${title}_${task['task']}_$idx'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red.shade400,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                ),
                onDismissed: (_) => onDeleteTask?.call(idx),
                child: InkWell(
                  onTap: () => onToggleTask(idx),
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
                        Expanded(
                          child: Text(
                            task['task'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500,
                              color: isCompleted
                                  ? AppTheme.textPrimaryColor
                                  : AppTheme.textSecondaryColor,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            InkWell(
              onTap: () => _showAddTaskDialog(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryColor, size: 22),
                    SizedBox(width: 16),
                    Text(
                      'Add step',
                      style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}