import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class RoutineResultScreen extends StatelessWidget {
  const RoutineResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Your AI Routine'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Text(
                  'Here is your customized routine.',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: 32),
              FadeInRight(
                delay: const Duration(milliseconds: 100),
                child: _buildRoutineCard(
                  context,
                  title: 'Morning Routine',
                  icon: Icons.wb_sunny_rounded,
                  color: Colors.orange.withOpacity(0.1),
                  iconColor: Colors.orange,
                  steps: ['Gentle Cleanser', 'Vitamin C Serum', 'Light Moisturizer', 'SPF 50 Sunscreen'],
                ),
              ),
              const SizedBox(height: 24),
              FadeInLeft(
                delay: const Duration(milliseconds: 300),
                child: _buildRoutineCard(
                  context,
                  title: 'Night Routine',
                  icon: Icons.nights_stay_rounded,
                  color: Colors.indigo.withOpacity(0.1),
                  iconColor: Colors.indigo,
                  steps: ['Oil Cleanser', 'Hydrating Cleanser', 'Retinol Serum', 'Heavy Moisturizer'],
                ),
              ),
              const SizedBox(height: 24),
              FadeInRight(
                delay: const Duration(milliseconds: 500),
                child: _buildRoutineCard(
                  context,
                  title: 'Hair Routine (Wash Day)',
                  icon: Icons.face_retouching_natural_rounded,
                  color: Colors.pink.withOpacity(0.1),
                  iconColor: Colors.pink,
                  steps: ['Scalp Oiling', 'Anti-Dandruff Shampoo', 'Hydrating Conditioner', 'Hair Serum'],
                ),
              ),
              const SizedBox(height: 48),
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: CustomButton(
                  text: 'Continue to Dashboard',
                  onPressed: () {
                    context.go('/home');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required List<String> steps,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    step,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
