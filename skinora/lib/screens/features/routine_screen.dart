import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/routine_section_card.dart';
import '../../services/routine_progress_service.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final RoutineProgressService _service = RoutineProgressService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleTask(Map<String, List<Map<String, dynamic>>> routines, String routineName, int index) {
    setState(() {
      _service.toggleTask(routines, routineName, index);
    });
  }

  void _resetRoutine(Map<String, List<Map<String, dynamic>>> routines, String routineName) {
    setState(() {
      _service.resetRoutine(routines, routineName);
    });
  }

  void _deleteTask(Map<String, List<Map<String, dynamic>>> routines, String routineName, int index) {
    setState(() {
      _service.deleteTask(routines, routineName, index);
    });
  }

  void _addTask(Map<String, List<Map<String, dynamic>>> routines, String routineName, String taskName) {
    setState(() {
      _service.addTask(routines, routineName, taskName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: FadeInDown(
            child: Text(
              'Your Routines',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondaryColor,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Skin'),
                Tab(text: 'Hair'),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _RoutineListView(
                routines: _service.skinRoutines,
                onToggleTask: (name, idx) => _toggleTask(_service.skinRoutines, name, idx),
                onReset: (name) => _resetRoutine(_service.skinRoutines, name),
                onDeleteTask: (name, idx) => _deleteTask(_service.skinRoutines, name, idx),
                onAddTask: (name, taskName) => _addTask(_service.skinRoutines, name, taskName),
              ),
              _RoutineListView(
                routines: _service.hairRoutines,
                onToggleTask: (name, idx) => _toggleTask(_service.hairRoutines, name, idx),
                onReset: (name) => _resetRoutine(_service.hairRoutines, name),
                onDeleteTask: (name, idx) => _deleteTask(_service.hairRoutines, name, idx),
                onAddTask: (name, taskName) => _addTask(_service.hairRoutines, name, taskName),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoutineListView extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> routines;
  final void Function(String routineName, int index) onToggleTask;
  final void Function(String routineName) onReset;
  final void Function(String routineName, int index) onDeleteTask;
  final void Function(String routineName, String taskName) onAddTask;

  const _RoutineListView({
    required this.routines,
    required this.onToggleTask,
    required this.onReset,
    required this.onDeleteTask,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final routineName in routines.keys)
            RoutineSectionCard(
              title: routineName,
              tasks: routines[routineName]!,
              onToggleTask: (idx) => onToggleTask(routineName, idx),
              onReset: () => onReset(routineName),
              onDeleteTask: (idx) => onDeleteTask(routineName, idx),
              onAddTask: (taskName) => onAddTask(routineName, taskName),
            ),
        ],
      ),
    );
  }
}