import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class SkinGoalsScreen extends StatefulWidget {
  const SkinGoalsScreen({super.key});

  @override
  State<SkinGoalsScreen> createState() => _SkinGoalsScreenState();
}

class _SkinGoalsScreenState extends State<SkinGoalsScreen> {
  final List<String> _goals = [
    'Clear Skin',
    'Glass Skin',
    'Acne Free',
    'Bright Skin',
    'Hydrated Skin',
    'Even Skin Tone',
    'Reduce Pigmentation',
    'Anti Aging'
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
        title: const Text('Skin Goals'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Text(
                  'What are your skin goals?',
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
                            color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
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
                text: 'Next: Hair Goals',
                onPressed: () {
                  if (_selectedGoals.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one goal')),
                    );
                    return;
                  }
                  context.push('/hair-goals');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
