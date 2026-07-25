import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/symptom_entry.dart';
import '../../services/symptom_service.dart';
import '../../widgets/custom_button.dart';

class SymptomTrackerScreen extends StatefulWidget {
  const SymptomTrackerScreen({super.key});

  @override
  State<SymptomTrackerScreen> createState() => _SymptomTrackerScreenState();
}

class _SymptomTrackerScreenState extends State<SymptomTrackerScreen> {
  final SymptomService _service = SymptomService();

  static const List<String> _moods = [
    '😊 Happy',
    '😐 Neutral',
    '😢 Sad',
    '😠 Irritable',
    '😰 Anxious',
  ];

  static const List<String> _allSymptoms = [
    'Cramps',
    'Headache',
    'Bloating',
    'Fatigue',
    'Acne',
    'Backache',
    'Tender Breasts',
    'Nausea',
  ];

  bool _loading = true;
  List<SymptomEntry> _recentEntries = [];
  SymptomEntry? _todayEntry;

  String? _selectedMood;
  final Set<String> _selectedSymptoms = {};
  int _energyLevel = 3;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final entries = await _service.getEntries();
    final todayEntry = await _service.getEntryForDate(DateTime.now());

    if (!mounted) return;
    setState(() {
      _recentEntries = entries.take(7).toList();
      _todayEntry = todayEntry;
      if (todayEntry != null) {
        _selectedMood = todayEntry.mood;
        _selectedSymptoms
          ..clear()
          ..addAll(todayEntry.symptoms);
        _energyLevel = todayEntry.energyLevel;
        _notesController.text = todayEntry.notes;
      }
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your mood')),
      );
      return;
    }

    final entry = SymptomEntry(
      id: _todayEntry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      mood: _selectedMood!,
      symptoms: _selectedSymptoms.toList(),
      energyLevel: _energyLevel,
      notes: _notesController.text.trim(),
    );

    await _service.addEntry(entry);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log saved')),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Symptom & Mood Tracker'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                children: [
                  FadeInDown(child: _buildDateHeader()),
                  const SizedBox(height: 20),
                  FadeInUp(child: _buildMoodSelector()),
                  const SizedBox(height: 24),
                  FadeInUp(delay: const Duration(milliseconds: 100), child: _buildSymptomChips()),
                  const SizedBox(height: 24),
                  FadeInUp(delay: const Duration(milliseconds: 150), child: _buildEnergyLevel()),
                  const SizedBox(height: 24),
                  FadeInUp(delay: const Duration(milliseconds: 200), child: _buildNotesField()),
                  const SizedBox(height: 28),
                  FadeInUp(
                    delay: const Duration(milliseconds: 250),
                    child: CustomButton(
                      text: _todayEntry != null ? 'Update Log' : 'Save Log',
                      onPressed: _save,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Text('Recent Logs', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const SizedBox(height: 12),
                  ..._buildRecentLogs(),
                ],
              ),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  _todayEntry != null ? 'Edit today\'s log' : 'Log Today',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How are you feeling?', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _moods.map((mood) {
              final selected = _selectedMood == mood;
              final parts = mood.split(' ');
              final emoji = parts.first;
              final label = parts.length > 1 ? parts.sublist(1).join(' ') : '';

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMood = mood),
                  child: Container(
                    width: 72,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(18),
                      border: selected ? null : Border.all(color: Colors.transparent),
                    ),
                    child: Column(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 26)),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Symptoms', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _allSymptoms.map((symptom) {
            final selected = _selectedSymptoms.contains(symptom);
            return FilterChip(
              label: Text(symptom),
              selected: selected,
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    _selectedSymptoms.add(symptom);
                  } else {
                    _selectedSymptoms.remove(symptom);
                  }
                });
              },
              selectedColor: AppTheme.primaryColor,
              backgroundColor: AppTheme.surfaceColor,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEnergyLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Energy Level', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final filled = starValue <= _energyLevel;
              return IconButton(
                onPressed: () => setState(() => _energyLevel = starValue),
                icon: Icon(
                  filled ? Icons.star_rounded : Icons.star_border_rounded,
                  color: filled ? AppTheme.primaryColor : Colors.grey.shade400,
                  size: 30,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notes (optional)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Anything else you want to remember about today...',
            filled: true,
            fillColor: AppTheme.surfaceColor,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRecentLogs() {
    if (_recentEntries.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              'No logs yet. Tap \'Log Today\' to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
        ),
      ];
    }

    return _recentEntries.map((entry) {
      final emoji = entry.mood.split(' ').first;
      final symptomCount = entry.symptoms.length;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEE, MMM d').format(entry.date),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      symptomCount == 0
                          ? 'No symptoms logged'
                          : '$symptomCount symptom${symptomCount == 1 ? '' : 's'} logged',
                      style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  entry.energyLevel,
                  (i) => const Icon(Icons.star_rounded, color: AppTheme.primaryColor, size: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
