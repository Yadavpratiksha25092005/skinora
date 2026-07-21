import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Map<String, bool> _settings = {
    'Morning Routine': true,
    'Night Routine': true,
    'Water Reminder': false,
    'Hair Reminder': true,
    'Sleep Reminder': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notifications'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Text('Reminder Settings', style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: _settings.keys.map((key) {
                      return SwitchListTile(
                        title: Text(key, style: const TextStyle(fontWeight: FontWeight.w600)),
                        activeColor: AppTheme.primaryColor,
                        value: _settings[key]!,
                        onChanged: (val) {
                          setState(() {
                            _settings[key] = val;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
