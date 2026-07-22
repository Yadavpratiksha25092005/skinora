import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';

class SleepTrackerScreen extends StatelessWidget {
  const SleepTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Sleep Tracker'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.indigo.shade100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Last Night', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            '7h 30m',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.indigo.shade900),
                          ),
                          const SizedBox(height: 4),
                          const Text('11:00 PM - 6:30 AM', style: TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Icon(Icons.bedtime, size: 64, color: Colors.indigo.shade300),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInLeft(
                delay: const Duration(milliseconds: 200),
                child: Text('Sleep Quality', style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: 16),
              FadeInLeft(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQualityBox(context, 'Deep', '3h 15m', Colors.indigo.shade700),
                    _buildQualityBox(context, 'Light', '4h 00m', Colors.indigo.shade300),
                    _buildQualityBox(context, 'Awake', '15m', Colors.orange.shade300),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Text('Weekly History', style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text('Chart Placeholder', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
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
                          'Your sleep quality was great last night. Good sleep deeply heals your skin!',
                          style: TextStyle(fontWeight: FontWeight.w500),
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

  Widget _buildQualityBox(BuildContext context, String title, String time, Color color) {
    return Container(
      width: (MediaQuery.of(context).size.width - 48 - 32) / 3, // padding subtracted
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(time, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
