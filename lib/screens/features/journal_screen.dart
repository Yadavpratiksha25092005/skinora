import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  int _selectedMoodIndex = -1;

  final List<Map<String, String>> _moods = [
    {'emoji': '😁', 'label': 'Great'},
    {'emoji': '🙂', 'label': 'Good'},
    {'emoji': '😐', 'label': 'Okay'},
    {'emoji': '😞', 'label': 'Bad'},
    {'emoji': '😫', 'label': 'Terrible'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Daily Journal'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Text('How is your skin today?', style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: 16),
              FadeInDown(
                child: TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'E.g., Feeling a little dry around the cheeks...',
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInLeft(
                child: Text('How is your hair today?', style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: 16),
              FadeInLeft(
                child: TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'E.g., Very frizzy because of the humidity today...',
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInRight(
                child: Text('How are you feeling?', style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: 16),
              FadeInRight(
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _moods.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedMoodIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMoodIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(_moods[index]['emoji']!, style: const TextStyle(fontSize: 32)),
                              const SizedBox(height: 8),
                              Text(
                                _moods[index]['label']!,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 48),
              FadeInUp(
                child: CustomButton(
                  text: 'Save Journal Entry',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Journal Saved!')));
                    context.pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
