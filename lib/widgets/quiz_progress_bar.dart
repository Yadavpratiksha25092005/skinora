import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class QuizProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const QuizProgressBar({super.key, required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question $currentStep of $totalSteps',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryColor,
              ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: currentStep / totalSteps,
            minHeight: 8,
            backgroundColor: AppTheme.secondaryColor,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }
}
