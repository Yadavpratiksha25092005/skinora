import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class HairGoalsScreen extends StatefulWidget {
  const HairGoalsScreen({super.key});

  @override
  State<HairGoalsScreen> createState() => _HairGoalsScreenState();
}

class _HairGoalsScreenState extends State<HairGoalsScreen> {
  final List<String> _goals = [
    'Reduce Hair Fall',
    'Hair Growth',
    'Dandruff Control',
    'Strong Hair',
    'Smooth Hair',
    'Thick Hair',
    'Healthy Scalp',
    'Frizz Control'
  ];

  final Set<String> _selectedGoals = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Hair Goals'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Text(
                  'What are your hair goals?',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select all that apply to you.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: FadeInUp(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _goals.length,
                    itemBuilder: (context, index) {
                      final goal = _goals[index];
                      final isSelected = _selectedGoals.contains(goal);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedGoals.remove(goal);
                            } else {
                              _selectedGoals.add(goal);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF86B0F2) : AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF86B0F2) : Colors.transparent,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              goal,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              CustomButton(
                text: 'Generate AI Routine',
                onPressed: () {
                  if (_selectedGoals.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one goal')),
                    );
                    return;
                  }
                  context.push('/routine-result');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
