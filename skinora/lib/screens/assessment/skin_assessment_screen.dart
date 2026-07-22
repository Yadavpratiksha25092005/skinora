import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/quiz_progress_bar.dart';
import '../../widgets/option_card.dart';

class SkinAssessmentScreen extends StatefulWidget {
  const SkinAssessmentScreen({super.key});

  @override
  State<SkinAssessmentScreen> createState() => _SkinAssessmentScreenState();
}

class _SkinAssessmentScreenState extends State<SkinAssessmentScreen> {
  int _currentQuestionIndex = 0;
  
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'How does your skin feel after washing?',
      'options': [
        {'text': 'Tight and dry', 'icon': Icons.dry},
        {'text': 'Oily and shiny', 'icon': Icons.water_drop},
        {'text': 'Oily in T-zone, dry elsewhere', 'icon': Icons.tune},
        {'text': 'Normal and comfortable', 'icon': Icons.sentiment_satisfied_alt},
      ]
    },
    {
      'question': 'How often do you get acne?',
      'options': [
        {'text': 'Rarely or never', 'icon': Icons.close_fullscreen},
        {'text': 'Occasionally', 'icon': Icons.brightness_medium},
        {'text': 'Frequently', 'icon': Icons.coronavirus_outlined},
      ]
    },
    {
      'question': 'How much water do you drink daily?',
      'options': [
        {'text': 'Less than 4 glasses', 'icon': Icons.water_drop_outlined},
        {'text': '4-8 glasses', 'icon': Icons.invert_colors},
        {'text': 'More than 8 glasses', 'icon': Icons.water_drop},
      ]
    },
    // Adding just a subset of questions for simplicity
  ];

  final Map<int, int> _selectedAnswers = {};

  void _nextQuestion() {
    if (_selectedAnswers[_currentQuestionIndex] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option to continue.')),
      );
      return;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      context.push('/hair-assessment');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_currentQuestionIndex];
    final options = currentQ['options'] as List<Map<String, dynamic>>;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (_currentQuestionIndex > 0) {
              setState(() {
                _currentQuestionIndex--;
              });
            } else {
              context.pop();
            }
          },
        ),
        title: const Text('Skin Assessment'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuizProgressBar(
                currentStep: _currentQuestionIndex + 1,
                totalSteps: _questions.length,
              ),
              const SizedBox(height: 32),
              Text(
                currentQ['question'],
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 26,
                    ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return OptionCard(
                      text: options[index]['text'],
                      icon: options[index]['icon'],
                      isSelected: _selectedAnswers[_currentQuestionIndex] == index,
                      onTap: () {
                        setState(() {
                          _selectedAnswers[_currentQuestionIndex] = index;
                        });
                      },
                    );
                  },
                ),
              ),
              CustomButton(
                text: _currentQuestionIndex == _questions.length - 1 ? 'Next Assessment' : 'Continue',
                onPressed: _nextQuestion,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
