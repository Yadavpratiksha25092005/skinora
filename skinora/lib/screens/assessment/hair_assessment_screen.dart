import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/quiz_progress_bar.dart';
import '../../widgets/option_card.dart';
import '../../services/assessment_draft.dart';

class HairAssessmentScreen extends StatefulWidget {
  const HairAssessmentScreen({super.key});

  @override
  State<HairAssessmentScreen> createState() => _HairAssessmentScreenState();
}

class _HairAssessmentScreenState extends State<HairAssessmentScreen> {
  int _currentQuestionIndex = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is your hair type?',
      'field': 'hairType',
      'options': [
        {'text': 'Straight', 'icon': Icons.format_strikethrough, 'value': 'straight'},
        {'text': 'Wavy', 'icon': Icons.waves, 'value': 'wavy'},
        {'text': 'Curly', 'icon': Icons.gesture, 'value': 'curly'},
        {'text': 'Coily', 'icon': Icons.all_inclusive, 'value': 'coily'},
      ]
    },
    {
      'question': 'What is your scalp type?',
      'field': 'scalpType',
      'options': [
        {'text': 'Dry', 'icon': Icons.dry, 'value': 'dry'},
        {'text': 'Oily', 'icon': Icons.water_drop, 'value': 'oily'},
        {'text': 'Normal', 'icon': Icons.sentiment_satisfied_alt, 'value': 'normal'},
        {'text': 'Combination', 'icon': Icons.tune, 'value': 'combination'},
      ]
    },
    {
      'question': 'What is your biggest hair concern?',
      'field': 'hairConcern',
      'options': [
        {'text': 'Hair Fall', 'icon': Icons.arrow_downward, 'value': 'Hair Fall'},
        {'text': 'Dandruff', 'icon': Icons.snowing, 'value': 'Dandruff'},
        {'text': 'Frizzy Hair', 'icon': Icons.bolt, 'value': 'Frizzy Hair'},
      ]
    },
  ];

  final Map<int, int> _selectedAnswers = {};
  final AssessmentDraft _draft = AssessmentDraft();

  void _saveAnswerToDraft(int questionIndex, int optionIndex) {
    final field = _questions[questionIndex]['field'] as String;
    final value = (_questions[questionIndex]['options'] as List)[optionIndex]['value'] as String;

    switch (field) {
      case 'hairType':
        _draft.hairType = value;
        break;
      case 'scalpType':
        _draft.scalpType = value;
        break;
      case 'hairConcern':
        _draft.hairConcern = value;
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
      context.push('/assessment-results');
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
        title: const Text('Hair Assessment'),
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
                text: _currentQuestionIndex == _questions.length - 1 ? 'Analyze Results' : 'Continue',
                onPressed: _nextQuestion,
              ),
            ],
          ),
        ),
      ),
    );
  }
}