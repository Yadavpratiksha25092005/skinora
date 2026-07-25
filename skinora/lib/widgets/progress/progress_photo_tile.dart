import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/progress_entry.dart';

class ProgressPhotoTile extends StatelessWidget {
  final ProgressEntry entry;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ProgressPhotoTile({
    super.key,
    required this.entry,
    required this.onTap,
    this.selected = false,
    this.onLongPress,
  });

  String get _dayLabel => '${entry.date.day}/${entry.date.month}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: AppTheme.surfaceColor,
                child: Image.file(
                  File(entry.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          if (selected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryColor, width: 3),
                  color: AppTheme.primaryColor.withOpacity(0.15),
                ),
                child: const Center(
                  child: Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor, size: 28),
                ),
              ),
            ),
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _dayLabel,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: entry.category == 'Skin'
                    ? AppTheme.primaryColor.withOpacity(0.85)
                    : const Color(0xFFE0A5C7).withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                entry.category,
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}