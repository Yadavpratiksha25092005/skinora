import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/doctor_models.dart';
import '../../services/doctor_service.dart';
import 'consultation_chat_screen.dart';
import 'consultation_call_screen.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  final DoctorService _service = DoctorService();
  List<Appointment> _appointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final appointments = await _service.getAllAppointments();
    if (!mounted) return;
    setState(() {
      _appointments = appointments;
      _loading = false;
    });
  }

  Future<void> _accept(Appointment appointment) async {
    await _service.acceptAppointment(appointment.id);
    _load();
  }

  Future<void> _reject(Appointment appointment) async {
    await _service.rejectAppointment(appointment.id);
    _load();
  }

  void _startConsultation(Appointment appointment) {
    if (appointment.mode == ConsultationMode.chat) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ConsultationChatScreen(appointment: appointment)),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ConsultationCallScreen(appointment: appointment)),
      );
    }
  }

  Color _statusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return const Color(0xFFE8A85B);
      case AppointmentStatus.accepted:
        return const Color(0xFF4CAF83);
      case AppointmentStatus.rejected:
        return const Color(0xFFE86C6C);
      case AppointmentStatus.completed:
        return Colors.grey;
    }
  }

  String _statusLabel(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.accepted:
        return 'Accepted';
      case AppointmentStatus.rejected:
        return 'Rejected';
      case AppointmentStatus.completed:
        return 'Completed';
    }
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Appointments'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : _appointments.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text('No appointments yet', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            'Booked patient appointments will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _appointments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
                                  child: Text(
                                    appointment.patientName.isNotEmpty ? appointment.patientName[0].toUpperCase() : '?',
                                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(appointment.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_formatDate(appointment.date)} · ${appointment.timeSlot}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(appointment.status).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    _statusLabel(appointment.status),
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor(appointment.status)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  appointment.mode == ConsultationMode.chat ? Icons.chat_bubble_outline_rounded : Icons.call_outlined,
                                  size: 15,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  appointment.mode == ConsultationMode.chat ? 'Chat consultation' : 'Audio consultation',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (appointment.status == AppointmentStatus.pending)
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _reject(appointment),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.redAccent),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Reject', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _accept(appointment),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              )
                            else if (appointment.status == AppointmentStatus.accepted)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _startConsultation(appointment),
                                  icon: Icon(
                                    appointment.mode == ConsultationMode.chat ? Icons.chat_bubble_rounded : Icons.call_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    appointment.mode == ConsultationMode.chat ? 'Start Chat' : 'Start Call',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF83),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}