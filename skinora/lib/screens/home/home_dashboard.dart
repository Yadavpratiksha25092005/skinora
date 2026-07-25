import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';

import '../../services/api_service.dart';
import '../features/routine_screen.dart';
import '../features/progress_screen.dart';
import '../features/profile_screen.dart';
import '../features/community_screen.dart';
import '../features/notifications_screen.dart';
import '../features/doctor_list_screen.dart';
import '../features/water_tracker_screen.dart';
import '../assessment/assessment_intro_screen.dart';
import '../wellness/cycle_calendar_screen.dart';
import '../ai_assistant/ai_assistant_home_screen.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../services/routine_progress_service.dart';
import '../../services/water_service.dart';
import '../../services/sleep_service.dart';
import '../features/skin_scan_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    _HomeContent(onNavigateToTab: _switchToTab),
    const RoutineScreen(),
    const ProgressScreen(),
    const CommunityScreen(),
    const AiAssistantHomeScreen(),
    const ProfileScreen(),
  ];

  void _switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
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
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.checklist_rtl_rounded), label: 'Routine'),
            BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'Progress'),
            BottomNavigationBarItem(icon: Icon(Icons.groups_rounded), label: 'Community'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_rounded), label: 'AI'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final ValueChanged<int> onNavigateToTab;

  const _HomeContent({required this.onNavigateToTab});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final RoutineProgressService _routineService = RoutineProgressService();
  final ApiService _apiService = ApiService();
  final WaterService _waterService = WaterService();
  final SleepService _sleepService = SleepService();
  String _userName = '';
  bool _loadingName = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _routineService.addListener(_onDataChanged);
    _waterService.addListener(_onDataChanged);
    _sleepService.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _routineService.removeListener(_onDataChanged);
    _waterService.removeListener(_onDataChanged);
    _sleepService.removeListener(_onDataChanged);
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final name = await _apiService.getSavedUserName();
    if (!mounted) return;
    setState(() {
      _userName = name;
      _loadingName = false;
    });
  }

  String get _firstName {
    if (_userName.trim().isEmpty) return 'there';
    return _userName.trim().split(' ').first;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildUvBanner(context),
          const SizedBox(height: 20),
          _buildSkinScoreCard(context),
          const SizedBox(height: 24),
          _buildQuickAccess(context),
          const SizedBox(height: 24),
          _buildTodayRoutine(context),
          const SizedBox(height: 24),
          _buildGlance(context),
          const SizedBox(height: 20),
          _buildAiInsight(context),
          const SizedBox(height: 48),
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
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.secondaryColor,
                child: _loadingName
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                      )
                    : Text(
                        _firstName.isNotEmpty ? _firstName[0].toUpperCase() : '?',
                        style: const TextStyle(color: AppTheme.primaryColor, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_greeting, style: Theme.of(context).textTheme.bodyMedium),
                  Row(
                    children: [
                      Text(
                        _loadingName ? 'Loading...' : _firstName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 21),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.auto_awesome, size: 16, color: Colors.pinkAccent),
                    ],
                  ),
                  const Text("Let's glow together", style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondaryColor)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _circleIconButton(
                icon: Icons.search_rounded,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _circleIconButton(
                icon: Icons.notifications_none_rounded,
                showDot: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({required IconData icon, required VoidCallback onTap, bool showDot = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppTheme.cardShadow,
            ),
            child: Icon(icon, color: AppTheme.textPrimaryColor, size: 20),
          ),
          if (showDot)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUvBanner(BuildContext context) {
    return FadeInRight(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFCEBEB),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.wb_sunny_rounded, color: Colors.deepOrange, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('UV index is high today',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF791F1F))),
                  const SizedBox(height: 2),
                  Text("Don't forget to apply sunscreen.",
                      style: TextStyle(fontSize: 11.5, color: const Color(0xFF791F1F).withOpacity(0.75))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View UV', style: TextStyle(color: Color(0xFF791F1F), fontWeight: FontWeight.w600, fontSize: 12)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF791F1F)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkinScoreCard(BuildContext context) {
    return FadeInLeft(
      delay: const Duration(milliseconds: 100),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, Color(0xFFB9A6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: AppTheme.raisedShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Skin Score',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(width: 6),
                Icon(Icons.info_outline_rounded, color: Colors.white.withOpacity(0.7), size: 15),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('85', style: TextStyle(color: Colors.white, fontSize: 46, fontWeight: FontWeight.bold, height: 1)),
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                            child: Text('/100', style: TextStyle(color: Colors.white70, fontSize: 15)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.circle, size: 8, color: Colors.white),
                            SizedBox(width: 6),
                            Text('Good', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward_rounded, color: Colors.greenAccent, size: 14),
                          const SizedBox(width: 3),
                          Text('6% from yesterday',
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11.5)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 110,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: CircularProgressIndicator(
                          value: 0.85,
                          strokeWidth: 9,
                          backgroundColor: Colors.white.withOpacity(0.25),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        child: const Icon(Icons.spa_rounded, color: Colors.white, size: 30),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Access', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickAccessItem(
                  icon: IconsaxPlusBold.scan,
                  label: 'Skin Scan',
                  subtitle: 'Analyze skin',
                  bg: const Color(0xFFEDEAFB),
                  iconColor: AppTheme.primaryColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SkinScanScreen()),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _QuickAccessItem(
                  icon: IconsaxPlusBold.drop,
                  label: 'Water',
                  subtitle: 'Track intake',
                  bg: const Color(0xFFE1EFFC),
                  iconColor: const Color(0xFF378ADD),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const WaterTrackerScreen()),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _QuickAccessItem(
                  icon: IconsaxPlusBold.magic_star,
                  label: 'Routine',
                  subtitle: 'My routine',
                  bg: const Color(0xFFFDEAF1),
                  iconColor: const Color(0xFFD4537E),
                  onTap: () => widget.onNavigateToTab(1),
                ),
                const SizedBox(width: 12),
                _QuickAccessItem(
                  icon: IconsaxPlusBold.health,
                  label: 'Doctor',
                  subtitle: 'Consult now',
                  bg: const Color(0xFFE1F5EA),
                  iconColor: const Color(0xFF2E9E5B),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const DoctorListScreen()),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _QuickAccessItem(
                  icon: IconsaxPlusBold.heart,
                  label: 'Cycle',
                  subtitle: 'Track cycle',
                  bg: const Color(0xFFFCE9DC),
                  iconColor: const Color(0xFFE07B39),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const CycleCalendarScreen()),
                    );
                  },
                ),
              ],
            ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Today's Routine", style: Theme.of(context).textTheme.titleLarge),
              const Text('View routine', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _RoutineBlock(
                    icon: Icons.wb_sunny_rounded,
                    iconColor: Colors.orange,
                    title: 'Morning Routine',
                    statusText: _routineService.isMorningDone ? 'Completed' : 'Pending',
                    statusColor: _routineService.isMorningDone ? Colors.green : Colors.orange,
                    doneCount: _routineService.morningDoneCount,
                    totalCount: _routineService.morningTotalCount,
                    isDone: _routineService.isMorningDone,
                  ),
                ),
                Container(height: 90, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 14)),
                Expanded(
                  child: _RoutineBlock(
                    icon: Icons.nights_stay_rounded,
                    iconColor: AppTheme.primaryColor,
                    title: 'Night Routine',
                    statusText: _routineService.isNightDone ? 'Completed' : 'Pending',
                    statusColor: _routineService.isNightDone ? Colors.green : Colors.orange,
                    doneCount: _routineService.nightDoneCount,
                    totalCount: _routineService.nightTotalCount,
                    isDone: _routineService.isNightDone,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlance(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today at a Glance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _GlanceCard(
                  icon: Icons.water_drop_rounded,
                  iconColor: const Color(0xFF378ADD),
                  bg: const Color(0xFFE6F1FB),
                  label: 'Water',
                  value: '${_waterService.currentCount}/${WaterService.goal}',
                  unit: 'Glasses',
                  percent: _waterService.currentCount / WaterService.goal,
                  barColor: const Color(0xFF378ADD),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GlanceCard(
                  icon: Icons.bedtime_rounded,
                  iconColor: AppTheme.primaryColor,
                  bg: const Color(0xFFEEEDFE),
                  label: 'Sleep',
                  value: _sleepService.lastNightHours.toStringAsFixed(1),
                  unit: 'Hours',
                  percent: (_sleepService.lastNightHours / 8).clamp(0.0, 1.0),
                  barColor: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GlanceCard(
                  icon: Icons.wb_sunny_rounded,
                  iconColor: Colors.deepOrange,
                  bg: const Color(0xFFFAEEDA),
                  label: 'UV Index',
                  value: 'High',
                  unit: 'SPF 50+',
                  percent: 0.8,
                  barColor: Colors.deepOrange,
                  badgeTooltip: 'Live weather data coming soon — this is a placeholder estimate.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsight(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3DE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.eco_rounded, color: Color(0xFF27500A), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text('AI Skin Insight',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF173404))),
                      SizedBox(width: 4),
                      Icon(Icons.auto_awesome, size: 13, color: Color(0xFF173404)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your skin hydration has improved. Keep following your routine consistently for the best results.',
                    style: TextStyle(fontSize: 11.5, color: const Color(0xFF173404).withOpacity(0.8), height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFF27500A), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color bg;
  final Color iconColor;
  final VoidCallback? onTap;

  const _QuickAccessItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.bg,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 116,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondaryColor)),
          ],
        ),
      ),
    );
  }
}

class _RoutineBlock extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String statusText;
  final Color statusColor;
  final int doneCount;
  final int totalCount;
  final bool isDone;

  const _RoutineBlock({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.statusText,
    required this.statusColor,
    required this.doneCount,
    required this.totalCount,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                  Text(statusText, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppTheme.primaryColor : Colors.transparent,
            border: isDone ? null : Border.all(color: Colors.grey.shade400, width: 1.5),
          ),
          child: isDone
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : Text('$doneCount/$totalCount', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (int i = 0; i < 3; i++)
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Icon(Icons.local_florist_outlined, size: 12, color: AppTheme.textSecondaryColor),
              ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('+2', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.textSecondaryColor)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GlanceCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bg;
  final String label;
  final String value;
  final String unit;
  final double percent;
  final Color barColor;
  final String? badgeTooltip;

  const _GlanceCard({
    required this.icon,
    required this.iconColor,
    required this.bg,
    required this.label,
    required this.value,
    required this.unit,
    required this.percent,
    required this.barColor,
    this.badgeTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 10.5, color: AppTheme.textSecondaryColor)),
              if (badgeTooltip != null) ...[
                const SizedBox(width: 4),
                Tooltip(
                  message: badgeTooltip!,
                  child: Icon(Icons.info_outline_rounded, size: 11, color: AppTheme.textSecondaryColor.withOpacity(0.7)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(unit, style: const TextStyle(fontSize: 9.5, color: AppTheme.textSecondaryColor)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 4,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}