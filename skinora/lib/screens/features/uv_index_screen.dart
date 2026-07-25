import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';

class UvIndexScreen extends StatelessWidget {
  const UvIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('UV Index'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeInDown(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFEC6FA6), AppTheme.primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.wb_sunny, color: Colors.white, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        '6',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 80),
                      ),
                      const Text(
                        'High Risk',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text('Recommendations', style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: _buildRecTile(Icons.medical_services_rounded, 'SPF 50+ Required', 'Apply every 2 hours outdoors.'),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildRecTile(Icons.watch_later_rounded, 'Best Time to Go Out', 'Before 10 AM or After 4 PM'),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: _buildRecTile(Icons.shield_rounded, 'Protection', 'Wear a hat and sunglasses.'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
