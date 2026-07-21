import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import 'package:animate_do/animate_do.dart';

import '../features/routine_screen.dart';
import '../features/progress_screen.dart';
import '../features/profile_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeContent(),
    const RoutineScreen(),
    const ProgressScreen(),
    const Center(child: Text("AI Assistant (Coming Soon)")),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.checklist_rtl_rounded), label: 'Routine'),
          BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_rounded), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildAIInsight(context),
          const SizedBox(height: 24),
          _buildSkinScore(context),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          _buildTodayRoutine(context),
          const SizedBox(height: 24),
          _buildDailyStats(context),
          const SizedBox(height: 48), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FadeInDown(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.secondaryColor,
                child: Text('P', style: TextStyle(color: AppTheme.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning,',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Pratiksha',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded, color: AppTheme.textPrimaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsight(BuildContext context) {
    return FadeInRight(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Remember to apply sunscreen today. UV level is high.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkinScore(BuildContext context) {
    return FadeInLeft(
      delay: const Duration(milliseconds: 100),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, Color(0xFFC4B5FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Skin Score',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Good', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '85',
                  style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                  child: Text(
                    '/100',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ),
                const Spacer(),
                Icon(Icons.trending_up, color: Colors.white.withOpacity(0.8), size: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickActionItem(icon: Icons.camera_alt_rounded, label: 'Assessment', color: Colors.orange.shade100, iconColor: Colors.orange),
              _QuickActionItem(icon: Icons.water_drop_rounded, label: 'Water', color: Colors.blue.shade100, iconColor: Colors.blue),
              _QuickActionItem(icon: Icons.face_retouching_natural, label: 'Hair Care', color: Colors.pink.shade100, iconColor: Colors.pink),
              _QuickActionItem(icon: Icons.smart_toy_rounded, label: 'AI Chat', color: AppTheme.secondaryColor, iconColor: AppTheme.primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayRoutine(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today\'s Routine', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _RoutineProgress(label: 'Morning', progress: 1.0, isCompleted: true, icon: Icons.wb_sunny_rounded),
                ),
                Container(height: 40, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 16)),
                Expanded(
                  child: _RoutineProgress(label: 'Night', progress: 0.0, isCompleted: false, icon: Icons.nights_stay_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStats(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Stats', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _StatCard(title: 'Water', value: '4/8', unit: 'Glasses', icon: Icons.water_drop, color: Colors.blue),
              _StatCard(title: 'Sleep', value: '7.5', unit: 'Hours', icon: Icons.bedtime, color: Colors.indigo),
              _StatCard(title: 'UV Index', value: '6', unit: 'High', icon: Icons.wb_sunny, color: Colors.orange),
              _StatCard(title: 'Streak', value: '12', unit: 'Days', icon: Icons.local_fire_department, color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;

  const _QuickActionItem({required this.icon, required this.label, required this.color, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _RoutineProgress extends StatelessWidget {
  final String label;
  final double progress;
  final bool isCompleted;
  final IconData icon;

  const _RoutineProgress({required this.label, required this.progress, required this.isCompleted, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: isCompleted ? Colors.amber : Colors.indigo.shade300, size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(isCompleted ? 'Completed' : 'Pending', style: TextStyle(fontSize: 12, color: isCompleted ? Colors.green : Colors.grey)),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.unit, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(unit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
