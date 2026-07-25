import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../models/doctor_models.dart';
import '../../services/doctor_service.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/rating_stars.dart';
import '../../services/api_service.dart';

class DoctorListScreen extends StatefulWidget {
  /// If set, the list opens pre-filtered to this specialization — used
  /// when the AI/assessment flow suggests doctors for a specific condition.
  final String? initialSpecialization;

  const DoctorListScreen({super.key, this.initialSpecialization});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final DoctorService _service = DoctorService();
  final TextEditingController _searchController = TextEditingController();

  List<Doctor> _doctors = [];
  List<String> _specializations = ['All'];
  String _selectedSpecialization = 'All';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedSpecialization = widget.initialSpecialization ?? 'All';
    _load();
  }

  Future<void> _load() async {
    final specs = await _service.getSpecializations();
    final results = await _service.search(
      query: _searchController.text,
      specialization: _selectedSpecialization,
    );
    if (!mounted) return;
    setState(() {
      _specializations = specs;
      _doctors = results;
      _loading = false;
    });
  }

  void _openDoctorSheet(Doctor doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DoctorBookingSheet(doctor: doctor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Consult a Doctor'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: FadeInDown(
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _load(),
                decoration: InputDecoration(
                  hintText: 'Search doctor or condition',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _specializations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final spec = _specializations[index];
                final isSelected = spec == _selectedSpecialization;
                return ChoiceChip(
                  label: Text(spec),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedSpecialization = spec);
                    _load();
                  },
                  selectedColor: AppTheme.primaryColor,
                  backgroundColor: AppTheme.surfaceColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide.none,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : _doctors.isEmpty
                    ? const Center(child: Text('No doctors found'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: _doctors.length,
                        itemBuilder: (context, index) {
                          final doctor = _doctors[index];
                          return FadeInUp(
                            delay: Duration(milliseconds: index * 60),
                            child: DoctorCard(
                              doctor: doctor,
                              onTap: () => _openDoctorSheet(doctor),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/// Combined doctor-profile + booking bottom sheet.
class _DoctorBookingSheet extends StatefulWidget {
  final Doctor doctor;
  const _DoctorBookingSheet({required this.doctor});

  @override
  State<_DoctorBookingSheet> createState() => _DoctorBookingSheetState();
}

class _DoctorBookingSheetState extends State<_DoctorBookingSheet> {
  final DoctorService _service = DoctorService();
  final ApiService _apiService = ApiService();

  late final List<DateTime> _availableDates;
  DateTime? _selectedDate;
  String? _selectedSlot;
  ConsultationMode _mode = ConsultationMode.chat;
  bool _booking = false;
  String _patientName = 'Patient';

  final List<String> _slots = ['10:00 AM', '11:30 AM', '2:00 PM', '4:30 PM', '6:00 PM'];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _availableDates = List.generate(7, (i) => DateTime(today.year, today.month, today.day + i));
    _selectedDate = _availableDates.first;
    _loadPatientName();
  }

  Future<void> _loadPatientName() async {
    final name = await _apiService.getSavedUserName();
    if (!mounted) return;
    setState(() => _patientName = name);
  }

  Future<void> _confirmBooking() async {
    if (_selectedDate == null || _selectedSlot == null) return;
    setState(() => _booking = true);
   await _service.bookAppointment(
      doctor: widget.doctor,
      date: _selectedDate!,
      timeSlot: _selectedSlot!,
      mode: _mode,
      patientName: _patientName,
    );
    if (!mounted) return;
    setState(() => _booking = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Appointment booked with ${widget.doctor.name} on '
          '${_selectedDate!.day}/${_selectedDate!.month} at $_selectedSlot',
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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

              // ---------- Profile ----------
              Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppTheme.secondaryColor,
                    child: Text(
                      doctor.name.replaceFirst('Dr. ', '')[0],
                      style: const TextStyle(
                          color: AppTheme.primaryColor, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doctor.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(doctor.qualification,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            RatingStars(rating: doctor.rating),
                            const SizedBox(width: 12),
                            Text('${doctor.experienceYears} yrs exp',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: doctor.languages
                    .map((lang) => Chip(
                          label: Text(lang, style: const TextStyle(fontSize: 11)),
                          backgroundColor: AppTheme.surfaceColor,
                          side: BorderSide.none,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text('About', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(doctor.about,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondaryColor, height: 1.5)),

              const Divider(height: 36),

              // ---------- Booking ----------
              Text('Select Date', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              SizedBox(
                height: 66,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableDates.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final date = _availableDates[index];
                    final isSelected = _selectedDate?.day == date.day &&
                        _selectedDate?.month == date.month;
                    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: Container(
                        width: 54,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(weekdays[date.weekday - 1],
                                style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? Colors.white70 : AppTheme.textSecondaryColor)),
                            const SizedBox(height: 4),
                            Text('${date.day}',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : AppTheme.textPrimaryColor)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              Text('Select Time', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _slots.map((slot) {
                  final isSelected = _selectedSlot == slot;
                  return ChoiceChip(
                    label: Text(slot),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedSlot = slot),
                    selectedColor: AppTheme.primaryColor,
                    backgroundColor: AppTheme.surfaceColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              Text('Consultation Mode', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ModeButton(
                      label: 'Chat',
                      icon: Icons.chat_bubble_outline_rounded,
                      isSelected: _mode == ConsultationMode.chat,
                      onTap: () => setState(() => _mode = ConsultationMode.chat),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ModeButton(
                      label: 'Audio',
                      icon: Icons.call_outlined,
                      isSelected: _mode == ConsultationMode.audio,
                      onTap: () => setState(() => _mode = ConsultationMode.audio),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedDate != null && _selectedSlot != null && !_booking)
                      ? _confirmBooking
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _booking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Confirm Appointment',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppTheme.textSecondaryColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}