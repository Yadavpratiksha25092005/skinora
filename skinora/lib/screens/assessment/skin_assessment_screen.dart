import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/quiz_progress_bar.dart';
import '../../widgets/option_card.dart';
import '../../services/assessment_draft.dart';

class SkinAssessmentScreen extends StatefulWidget {
  const SkinAssessmentScreen({super.key});

  @override
  State<SkinAssessmentScreen> createState() => _SkinAssessmentScreenState();
}

class _SkinAssessmentScreenState extends State<SkinAssessmentScreen> {
  int _currentQuestionIndex = 0;

  // Each option now carries a `value` — the exact string the backend expects.
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'How does your skin feel after washing?',
      'field': 'skinFeel',
      'options': [
        {'text': 'Tight and dry', 'icon': Icons.dry, 'value': 'tight_dry'},
        {'text': 'Oily and shiny', 'icon': Icons.water_drop, 'value': 'oily_shiny'},
        {'text': 'Oily in T-zone, dry elsewhere', 'icon': Icons.tune, 'value': 'combination'},
        {'text': 'Normal and comfortable', 'icon': Icons.sentiment_satisfied_alt, 'value': 'normal'},
      ]
    },
    {
      'question': 'How often do you get acne?',
      'field': 'acneFrequency',
      'options': [
        {'text': 'Rarely or never', 'icon': Icons.close_fullscreen, 'value': 'rarely'},
        {'text': 'Occasionally', 'icon': Icons.brightness_medium, 'value': 'occasionally'},
        {'text': 'Frequently', 'icon': Icons.coronavirus_outlined, 'value': 'frequently'},
      ]
    },
    {
      'question': 'How much water do you drink daily?',
      'field': 'waterIntake',
      'options': [
        {'text': 'Less than 4 glasses', 'icon': Icons.water_drop_outlined, 'value': 'low'},
        {'text': '4-8 glasses', 'icon': Icons.invert_colors, 'value': 'medium'},
        {'text': 'More than 8 glasses', 'icon': Icons.water_drop, 'value': 'high'},
      ]
    },
  ];

  final Map<int, int> _selectedAnswers = {};
  final AssessmentDraft _draft = AssessmentDraft();

  void _saveAnswerToDraft(int questionIndex, int optionIndex) {
    final field = _questions[questionIndex]['field'] as String;
    final value = (_questions[questionIndex]['options'] as List)[optionIndex]['value'] as String;

    switch (field) {
      case 'skinFeel':
        _draft.skinFeel = value;
        break;
      case 'acneFrequency':
        _draft.acneFrequency = value;
        break;
      case 'waterIntake':
        _draft.waterIntake = value;
        break;
    }
  }

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
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 26),
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
                        _saveAnswerToDraft(_currentQuestionIndex, index);
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