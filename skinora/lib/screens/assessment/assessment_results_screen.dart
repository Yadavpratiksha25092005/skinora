import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../services/assessment_draft.dart';
import '../../services/api_service.dart';

class AssessmentResultsScreen extends StatefulWidget {
  const AssessmentResultsScreen({super.key});

  @override
  State<AssessmentResultsScreen> createState() => _AssessmentResultsScreenState();
}

class _AssessmentResultsScreenState extends State<AssessmentResultsScreen> {
  final AssessmentDraft _draft = AssessmentDraft();
  final ApiService _apiService = ApiService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _submit();
  }

  Future<void> _submit() async {
    try {
      final result = await _apiService.submitAssessment(_draft.toPayload());
      _draft.clear();
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('AI Analysis Result'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryColor),
                    SizedBox(height: 16),
                    Text('Analyzing your answers...', style: TextStyle(color: AppTheme.textSecondaryColor)),
                  ],
                ),
              )
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                          const SizedBox(height: 16),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          CustomButton(text: 'Try Again', onPressed: () {
                            setState(() => _loading = true);
                            _submit();
                          }),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInDown(
                          child: Text(
                            'Your Results Are Ready!',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeInUp(
                          child: Text(
                            'Based on your answers, here is your current health profile.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        FadeInLeft(
                          delay: const Duration(milliseconds: 200),
                          child: _buildResultCard(
                            context: context,
                            title: 'Skin Score',
                            score: _result!['skin_score'] ?? 0,
                            type: _result!['skin_type'] ?? '-',
                            concerns: _result!['skin_concerns'] ?? '-',
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInRight(
                          delay: const Duration(milliseconds: 400),
                          child: _buildResultCard(
                            context: context,
                            title: 'Hair Score',
                            score: _result!['hair_score'] ?? 0,
                            type: _result!['hair_type'] ?? '-',
                            concerns: _result!['hair_concerns'] ?? '-',
                            color: const Color(0xFF86B0F2),
                          ),
                        ),
                        const SizedBox(height: 48),
                        FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          child: CustomButton(
                            text: 'Set Your Goals',
                            onPressed: () {
                              context.push('/skin-goals');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildResultCard({
    required BuildContext context,
    required String title,
    required int score,
    required String type,
    required String concerns,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 50.0,
            lineWidth: 10.0,
            animation: true,
            percent: score / 100,
            animationDuration: 1500,
            center: Text(
              "$score",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: color,
            backgroundColor: color.withOpacity(0.1),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text('Type: $type', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Concerns: $concerns', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}