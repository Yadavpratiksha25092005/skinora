import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  int _currentWater = 2; // Glasses
  final int _waterGoal = 8;

  void _addWater() {
    if (_currentWater < _waterGoal) {
      setState(() {
        _currentWater++;
      });
    }
  }

  void _removeWater() {
    if (_currentWater > 0) {
      setState(() {
        _currentWater--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentWater / _waterGoal;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Water Tracker'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeInDown(
                child: Text(
                  'Daily Goal',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                child: Text(
                  '$_waterGoal Glasses (2 Liters)',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
              const SizedBox(height: 48),
              FadeInUp(
                child: CircularPercentIndicator(
                  radius: 120.0,
                  lineWidth: 24.0,
                  animation: true,
                  animateFromLastPercent: true,
                  percent: progress,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.water_drop, color: Colors.blue, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        '$_currentWater / $_waterGoal',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0),
                      ),
                    ],
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.blue,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 48),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      heroTag: 'remove',
                      onPressed: _removeWater,
                      backgroundColor: AppTheme.surfaceColor,
                      foregroundColor: AppTheme.textPrimaryColor,
                      elevation: 0,
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(width: 32),
                    FloatingActionButton.extended(
                      heroTag: 'add',
                      onPressed: _addWater,
                      backgroundColor: Colors.blue,
                      elevation: 0,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Add Glass', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Drinking water helps flush out toxins and keeps your skin hydrated and glowing.',
                          style: TextStyle(color: Colors.blue.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
