import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../services/sleep_service.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  final SleepService _service = SleepService();

  TimeOfDay _bedTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    _service.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _service.removeListener(_onChanged);
    super.dispose();
  }

  Future<void> _logSleep() async {
    final bed = await showTimePicker(
      context: context,
      initialTime: _bedTime,
      helpText: 'Select bedtime',
    );
    if (bed == null || !mounted) return;

    final wake = await showTimePicker(
      context: context,
      initialTime: _wakeTime,
      helpText: 'Select wake-up time',
    );
    if (wake == null || !mounted) return;

    setState(() {
      _bedTime = bed;
      _wakeTime = wake;
    });
    await _service.logSleep(bed, wake);
  }

  @override
  Widget build(BuildContext context) {
    final todayEntry = _service.todayEntry;
    final weekHistory = _service.history.take(7).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Sleep Tracker'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logSleep,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Sleep', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: !_service.isLoaded
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBEAF0),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFF6D3E0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Last Night', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(
                                  todayEntry?.durationLabel ?? 'Not logged',
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(color: const Color(0xFF7A2A48)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  todayEntry?.timeRangeLabel ?? 'Tap "Log Sleep" to add today\'s data',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Icon(Icons.bedtime, size: 64, color: const Color(0xFFEC6FA6)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeInUp(
                      child: Text('Sleep History', style: Theme.of(context).textTheme.titleLarge),
                    ),
                    const SizedBox(height: 16),
                    if (weekHistory.isEmpty)
                      FadeInUp(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text('No sleep logged yet. Start tracking!', style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      )
                    else
                      FadeInUp(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: weekHistory.map((entry) {
                              final isLast = entry == weekHistory.last;
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: isLast
                                      ? null
                                      : Border(bottom: BorderSide(color: Colors.grey.shade200)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.bedtime_outlined, color: const Color(0xFFEC6FA6), size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(entry.date, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                          Text(entry.timeRangeLabel, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      entry.durationLabel,
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Aim for 7-9 hours of sleep. Good sleep helps your skin repair and glow.',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 80), // space for FAB
                  ],
                ),
              ),
      ),
    );
  }
}
