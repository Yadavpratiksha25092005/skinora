import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
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
                        Text(
                          'Welcome, Doctor',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Here is your consultation overview',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
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

              // ---------- Stat cards ----------
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Row(
                  children: [
                    Expanded(child: _statCard('Today', '0', 'Consultations', Icons.calendar_today_outlined, AppTheme.primaryColor)),
                    const SizedBox(width: 14),
                    Expanded(child: _statCard('Pending', '0', 'Requests', Icons.pending_actions_outlined, const Color(0xFFE8A0A0))),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              FadeInUp(
                delay: const Duration(milliseconds: 150),
                child: Row(
                  children: [
                    Expanded(child: _statCard('Rating', '0.0', 'Avg. rating', Icons.star_outline_rounded, const Color(0xFFE8C06A))),
                    const SizedBox(width: 14),
                    Expanded(child: _statCard('Total', '0', 'Patients seen', Icons.people_outline_rounded, const Color(0xFF7ABFC7))),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ---------- Verification notice ----------
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF1E4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFFB07A2E)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your account is pending verification. You will be notified once approved by our team.',
                          style: TextStyle(fontSize: 13, color: Colors.brown.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),

              FadeInUp(
                delay: const Duration(milliseconds: 250),
                child: Column(
                  children: [
                    _actionTile(Icons.calendar_month_outlined, 'Appointments', 'View and manage your schedule'),
                    _actionTile(Icons.chat_bubble_outline_rounded, 'Consultations', 'Chat and audio sessions'),
                    _actionTile(Icons.person_outline_rounded, 'My Profile', 'Update your professional details'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, String subtitle, IconData icon, Color color) {
    return Container(
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
    );
  }

  Widget _actionTile(IconData icon, String title, String subtitle) {
    return Container(
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
    );
  }
}