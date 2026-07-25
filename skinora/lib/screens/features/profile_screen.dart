import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../wellness/cycle_calendar_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  String _fullName = '';
  String _role = 'user';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await _apiService.getSavedUserName();
    final role = await _apiService.getSavedRole();
    if (!mounted) return;
    setState(() {
      _fullName = name;
      _role = role;
      _loading = false;
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _apiService.logout();
      if (!mounted) return;
      context.go('/login');
    }
  }

  void _openComingSoon(String title, IconData icon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ComingSoonPage(title: title, icon: icon),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('About Skinora'),
        content: const Text(
          'Skinora - AI Powered Skin, Hair & Wellness Companion.\n\nVersion 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text('Profile', style: Theme.of(context).textTheme.displaySmall),
          ),
          const SizedBox(height: 24),

          // ---------- User info card ----------
          FadeInUp(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFFF7A8C4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _fullName.isNotEmpty ? _fullName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _loading ? 'Loading...' : (_fullName.isEmpty ? 'User' : _fullName),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            _role == 'doctor' ? 'Doctor' : 'User',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Text('Account', style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Column(
              children: [
                _settingsTile(
                  Icons.person_outline_rounded,
                  'Edit Profile',
                  () => _openComingSoon('Edit Profile', Icons.person_outline_rounded),
                ),
                _settingsTile(
                  Icons.face_retouching_natural_outlined,
                  'Skin & Hair Assessment',
                  () => context.push('/assessment-intro'),
                ),
                _settingsTile(
                  Icons.bookmark_border_rounded,
                  'Saved Remedies',
                  () => _openComingSoon('Saved Remedies', Icons.bookmark_border_rounded),
                ),
                _settingsTile(
                  Icons.favorite_border_rounded,
                  'Women\'s Wellness',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const CycleCalendarScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          FadeInUp(
            delay: const Duration(milliseconds: 150),
            child: Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 150),
            child: Column(
              children: [
                _settingsTile(
                  Icons.notifications_none_rounded,
                  'Notification Settings',
                  () => _openComingSoon('Notification Settings', Icons.notifications_none_rounded),
                ),
                _settingsTile(
                  Icons.lock_outline_rounded,
                  'Privacy & Security',
                  () => _openComingSoon('Privacy & Security', Icons.lock_outline_rounded),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text('Support', style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Column(
              children: [
                _settingsTile(
                  Icons.help_outline_rounded,
                  'Help & FAQ',
                  () => _openComingSoon('Help & FAQ', Icons.help_outline_rounded),
                ),
                _settingsTile(
                  Icons.info_outline_rounded,
                  'About Skinora',
                  _showAboutDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          FadeInUp(
            delay: const Duration(milliseconds: 250),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: const Text('Log out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: AppTheme.primaryColor, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
      ),
    );
  }
}

/// Simple placeholder page for settings items that don't have a real
/// screen yet. Once a real screen is built, just swap the call to
/// _openComingSoon() with a push to the real screen — nothing else changes.
class _ComingSoonPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ComingSoonPage({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppTheme.secondaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 20),
              Text(
                '$title is coming soon',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'We\'re working on this feature. Check back soon!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}   