import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../models/doctor_models.dart';
import '../../services/doctor_service.dart';
import 'appointments_list_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final DoctorService _service = DoctorService();

  int _todayCount = 0;
  int _pendingCount = 0;
  int _totalPatients = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final all = await _service.getAllAppointments();
    final today = await _service.getTodayAppointments();
    final pending = await _service.getPendingAppointments();

    final uniquePatients = all.map((a) => a.patientName).toSet().length;

    if (!mounted) return;
    setState(() {
      _todayCount = today.length;
      _pendingCount = pending.length;
      _totalPatients = uniquePatients;
      _loading = false;
    });
  }

  void _openAppointments() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AppointmentsListScreen()),
    );
    _loadStats(); // refresh stats after coming back (in case of accept/reject)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: _loadStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome, Doctor', style: Theme.of(context).textTheme.displaySmall),
                          const SizedBox(height: 4),
                          Text(
                            'Here is your consultation overview',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryColor),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                        child: const Icon(Icons.medical_services_outlined, color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          'Today',
                          _loading ? '-' : '$_todayCount',
                          'Consultations',
                          Icons.calendar_today_outlined,
                          AppTheme.primaryColor,
                          onTap: _openAppointments,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _statCard(
                          'Pending',
                          _loading ? '-' : '$_pendingCount',
                          'Requests',
                          Icons.pending_actions_outlined,
                          const Color(0xFFE8A0A0),
                          onTap: _openAppointments,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  child: Row(
                    children: [
                      Expanded(
                        child: _statCard('Rating', '4.8', 'Avg. rating', Icons.star_outline_rounded, const Color(0xFFE8C06A)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _statCard(
                          'Total',
                          _loading ? '-' : '$_totalPatients',
                          'Patients seen',
                          Icons.people_outline_rounded,
                          const Color(0xFF7ABFC7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),

                FadeInUp(
                  delay: const Duration(milliseconds: 250),
                  child: Column(
                    children: [
                      _actionTile(
                        Icons.calendar_month_outlined,
                        'Appointments',
                        _pendingCount > 0 ? '$_pendingCount pending request${_pendingCount > 1 ? 's' : ''}' : 'View and manage your schedule',
                        onTap: _openAppointments,
                      ),
                      _actionTile(
                        Icons.chat_bubble_outline_rounded,
                        'Consultations',
                        'Accepted chats and calls',
                        onTap: _openAppointments,
                      ),
                     _actionTile(
                        Icons.person_outline_rounded,
                        'My Profile',
                        'Update your professional details',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const DoctorProfileScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, String subtitle, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(IconData icon, String title, String subtitle, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}