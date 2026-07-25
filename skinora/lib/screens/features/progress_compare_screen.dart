import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/progress_entry.dart';

class ProgressCompareScreen extends StatelessWidget {
  final ProgressEntry before;
  final ProgressEntry after;

  const ProgressCompareScreen({super.key, required this.before, required this.after});

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final daysApart = after.date.difference(before.date).inDays;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Before & After'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timeline_rounded, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      '$daysApart days apart',
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _photoColumn(context, 'Before', before)),
                    const SizedBox(width: 12),
                    Expanded(child: _photoColumn(context, 'After', after)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoColumn(BuildContext context, String label, ProgressEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(entry.date),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              color: AppTheme.surfaceColor,
              child: Image.file(
                File(entry.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image_outlined, color: Colors.grey),
              ),
            ),
          ),
        ),
        if (entry.note.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            entry.note,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }
}