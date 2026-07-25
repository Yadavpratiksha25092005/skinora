import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/cycle_entry.dart';
import '../../services/cycle_service.dart';
import '../../widgets/custom_button.dart';

class CycleCalendarScreen extends StatefulWidget {
  const CycleCalendarScreen({super.key});

  @override
  State<CycleCalendarScreen> createState() => _CycleCalendarScreenState();
}

class _CycleCalendarScreenState extends State<CycleCalendarScreen> {
  final CycleService _service = CycleService();

  static const Color periodColor = Color(0xFFF28FA8); // pink
  static const Color predictedColor = Color(0xFFF9D3DF); // light pink
  static const Color ovulationColor = Color(0xFFEC6FA6); // deep pink

  bool _loading = true;
  bool _hasEntries = false;
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  List<CycleEntry> _entries = [];
  int _averageCycleLength = 28;
  DateTime? _nextPeriod;
  DateTime? _ovulationDate;

  // ---------- Quick Setup (first-time onboarding) ----------
  DateTime? _quickSetupStartDate;
  final TextEditingController _quickSetupDurationController = TextEditingController(text: '5');
  final TextEditingController _quickSetupAvgCycleController = TextEditingController(text: '28');
  bool _quickSetupSubmitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _quickSetupDurationController.dispose();
    _quickSetupAvgCycleController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final hasEntries = await _service.hasAnyEntries();
    final entries = await _service.getEntries();
    final avgLength = await _service.calculateAverageCycleLength();
    final nextPeriod = await _service.predictNextPeriod();
    final ovulation = await _service.predictOvulation();

    if (!mounted) return;
    setState(() {
      _hasEntries = hasEntries;
      _entries = entries;
      _averageCycleLength = avgLength;
      _nextPeriod = nextPeriod;
      _ovulationDate = ovulation;
      _loading = false;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isLoggedPeriodDay(DateTime day) {
    for (final entry in _entries) {
      final end = entry.endDate ?? entry.startDate;
      final start = DateTime(entry.startDate.year, entry.startDate.month, entry.startDate.day);
      final endDay = DateTime(end.year, end.month, end.day);
      final target = DateTime(day.year, day.month, day.day);
      if (!target.isBefore(start) && !target.isAfter(endDay)) return true;
    }
    return false;
  }

  bool _isPredictedPeriodDay(DateTime day) {
    if (_nextPeriod == null) return false;
    final predictedEnd = _nextPeriod!.add(const Duration(days: 4));
    final target = DateTime(day.year, day.month, day.day);
    final start = DateTime(_nextPeriod!.year, _nextPeriod!.month, _nextPeriod!.day);
    final end = DateTime(predictedEnd.year, predictedEnd.month, predictedEnd.day);
    return !target.isBefore(start) && !target.isAfter(end) && !_isLoggedPeriodDay(day);
  }

  bool _isOvulationDay(DateTime day) {
    if (_ovulationDate == null) return false;
    // Fertile window: ~5 days around the predicted ovulation date.
    final windowStart = _ovulationDate!.subtract(const Duration(days: 2));
    final windowEnd = _ovulationDate!.add(const Duration(days: 2));
    final target = DateTime(day.year, day.month, day.day);
    final start = DateTime(windowStart.year, windowStart.month, windowStart.day);
    final end = DateTime(windowEnd.year, windowEnd.month, windowEnd.day);
    return !target.isBefore(start) && !target.isAfter(end);
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  Future<void> _openLogPeriodSheet() async {
    DateTimeRange? selectedRange;
    String selectedFlow = 'medium';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Log Period', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 20),
                  Text('Period dates', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      final now = DateTime.now();
                      final range = await showDateRangePicker(
                        context: sheetContext,
                        firstDate: DateTime(now.year - 1),
                        lastDate: DateTime(now.year + 1),
                        initialDateRange: selectedRange,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: Theme.of(context).colorScheme.copyWith(
                                    primary: AppTheme.primaryColor,
                                  ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (range != null) {
                        setSheetState(() => selectedRange = range);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryColor, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            selectedRange == null
                                ? 'Select start & end date'
                                : '${DateFormat('MMM d').format(selectedRange!.start)} - ${DateFormat('MMM d, yyyy').format(selectedRange!.end)}',
                            style: TextStyle(
                              color: selectedRange == null ? AppTheme.textSecondaryColor : AppTheme.textPrimaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Flow intensity', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['light', 'medium', 'heavy'].map((flow) {
                      final selected = selectedFlow == flow;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(flow[0].toUpperCase() + flow.substring(1)),
                          selected: selected,
                          onSelected: (_) => setSheetState(() => selectedFlow = flow),
                          selectedColor: AppTheme.primaryColor,
                          backgroundColor: AppTheme.surfaceColor,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppTheme.textPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide.none,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    text: 'Save',
                    onPressed: () async {
                      if (selectedRange == null) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(content: Text('Please select the period dates')),
                        );
                        return;
                      }
                      final entry = CycleEntry(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        startDate: selectedRange!.start,
                        endDate: selectedRange!.end,
                        flowIntensity: selectedFlow,
                      );
                      await _service.addEntry(entry);
                      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                      await _load();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
        title: const Text('Cycle Tracker'),
      ),
      floatingActionButton: !_loading && _hasEntries
          ? FloatingActionButton.extended(
              onPressed: _openLogPeriodSheet,
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Log Period', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : !_hasEntries
                ? _buildQuickSetup()
                : RefreshIndicator(
                color: AppTheme.primaryColor,
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  children: [
                    FadeInDown(child: _buildSummaryCard()),
                    const SizedBox(height: 16),
                    FadeInUp(child: _buildLogSymptomsCard()),
                    const SizedBox(height: 12),
                    FadeInUp(delay: const Duration(milliseconds: 50), child: _buildWellnessInfoCard()),
                    const SizedBox(height: 20),
                    FadeInUp(child: _buildCalendarCard()),
                    const SizedBox(height: 20),
                    FadeInUp(delay: const Duration(milliseconds: 150), child: _buildLegend()),
                    const SizedBox(height: 24),
                    FadeInUp(
                      delay: const Duration(milliseconds: 250),
                      child: Text('History', style: Theme.of(context).textTheme.titleLarge),
                    ),
                    const SizedBox(height: 12),
                    ..._buildHistoryList(),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _pickQuickSetupStartDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      initialDate: _quickSetupStartDate ?? now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _quickSetupStartDate = date);
    }
  }

  Future<void> _submitQuickSetup() async {
    if (_quickSetupStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select when your last period started')),
      );
      return;
    }

    final periodDays = int.tryParse(_quickSetupDurationController.text.trim()) ?? 5;
    final avgCycleLength = int.tryParse(_quickSetupAvgCycleController.text.trim()) ?? 28;

    setState(() => _quickSetupSubmitting = true);

    final entry = CycleEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: _quickSetupStartDate!,
      endDate: _quickSetupStartDate!.add(Duration(days: periodDays > 0 ? periodDays - 1 : 0)),
      flowIntensity: 'medium',
    );

    await _service.addEntry(entry);
    await _service.saveManualCycleLength(avgCycleLength > 0 ? avgCycleLength : 28);

    if (!mounted) return;
    setState(() => _quickSetupSubmitting = false);
    await _load();
  }

  Widget _buildQuickSetup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Container(
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
                  const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Let\'s set up your cycle',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'A quick, one-time setup so we can predict your next period.',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'When did your last period start?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _pickQuickSetupStartDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryColor, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _quickSetupStartDate == null
                                ? 'Select a date'
                                : DateFormat('MMM d, yyyy').format(_quickSetupStartDate!),
                            style: TextStyle(
                              color: _quickSetupStartDate == null
                                  ? AppTheme.textSecondaryColor
                                  : AppTheme.textPrimaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'How many days does it last?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _quickSetupDurationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      suffixText: 'days',
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Average cycle length?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _quickSetupAvgCycleController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      suffixText: 'days',
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Save & Continue',
                    isLoading: _quickSetupSubmitting,
                    onPressed: _submitQuickSetup,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final daysUntilNext = _nextPeriod == null
        ? null
        : _nextPeriod!.difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            daysUntilNext == null
                ? 'Log your period to get predictions'
                : daysUntilNext >= 0
                    ? 'Next period in $daysUntilNext ${daysUntilNext == 1 ? 'day' : 'days'}'
                    : 'Period may be delayed',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (_nextPeriod != null) ...[
            const SizedBox(height: 6),
            Text(
              DateFormat('EEEE, MMM d, yyyy').format(_nextPeriod!),
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _summaryStat(Icons.repeat_rounded, 'Avg cycle', '$_averageCycleLength days'),
              ),
              Container(width: 1, height: 36, color: Colors.white.withOpacity(0.3)),
              Expanded(
                child: _summaryStat(
                  Icons.egg_alt_outlined,
                  'Ovulation',
                  _ovulationDate == null ? '--' : DateFormat('MMM d').format(_ovulationDate!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogSymptomsCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/symptom-tracker'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: ovulationColor.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mood_rounded, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Log Symptoms', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  SizedBox(height: 2),
                  Text(
                    'Track your mood, symptoms & energy',
                    style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessInfoCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/wellness-info'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: predictedColor.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu_book_rounded, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wellness Tips', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  SizedBox(height: 2),
                  Text(
                    'Learn about PCOS, PCOD & hormonal health',
                    style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondaryColor),
          ],
        ),
      ),
    );
  }

  Widget _summaryStat(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    final firstDayOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    // DateTime weekday: Monday=1..Sunday=7. Convert so grid starts on Sunday.
    final leadingBlanks = firstDayOfMonth.weekday % 7;

    final totalCells = leadingBlanks + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final cellCount = rows * 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => _changeMonth(-1),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_visibleMonth),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(color: AppTheme.textSecondaryColor, fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cellCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - leadingBlanks + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final day = DateTime(_visibleMonth.year, _visibleMonth.month, dayNumber);
              final isToday = _isSameDay(day, DateTime.now());
              final isLoggedPeriod = _isLoggedPeriodDay(day);
              final isPredictedPeriod = _isPredictedPeriodDay(day);
              final isOvulation = _isOvulationDay(day);

              Color? bgColor;
              Color textColor = AppTheme.textPrimaryColor;
              Border? border;

              if (isLoggedPeriod) {
                bgColor = periodColor;
                textColor = Colors.white;
              } else if (isOvulation) {
                bgColor = ovulationColor.withOpacity(0.35);
                textColor = AppTheme.textPrimaryColor;
              } else if (isPredictedPeriod) {
                bgColor = predictedColor;
                textColor = AppTheme.textPrimaryColor;
              }

              if (isToday) {
                border = Border.all(color: AppTheme.primaryColor, width: 1.5);
              }

              return Padding(
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: border,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: isToday || isLoggedPeriod ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _legendItem(periodColor, 'Period'),
        _legendItem(predictedColor, 'Predicted period'),
        _legendItem(ovulationColor.withOpacity(0.35), 'Ovulation window'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12)),
      ],
    );
  }

  List<Widget> _buildHistoryList() {
    if (_entries.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              'No periods logged yet.\nTap "Log Period" to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
        ),
      ];
    }

    return _entries.map((entry) {
      final endDate = entry.endDate;
      final durationLabel = endDate != null
          ? '${DateFormat('MMM d').format(entry.startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}'
          : DateFormat('MMM d, yyyy').format(entry.startDate);

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
                  color: periodColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.water_drop_rounded, color: periodColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(durationLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      'Flow: ${entry.flowIntensity[0].toUpperCase()}${entry.flowIntensity.substring(1)}',
                      style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textSecondaryColor),
                onPressed: () async {
                  await _service.deleteEntry(entry.id);
                  await _load();
                },
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
