import 'package:flutter/material.dart';

/// A single educational Women's Wellness topic (PCOS/PCOD info, hormonal
/// health, diet, exercise, self-care, etc).
class WellnessTopic {
  final String title;
  final String category; // PCOS / PCOD / Hormonal Health / Diet / Exercise / Self-Care
  final String summary; // 1-2 line preview
  final String content; // full detailed text
  final IconData icon;

  /// Cycle phases this topic is most relevant to — 'Period', 'Follicular',
  /// 'Ovulation', 'Luteal'. Empty list = general topic, not phase-specific
  /// (won't appear in the "Recommended For You" section, only in the main list).
  final List<String> relevantPhases;

  const WellnessTopic({
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    required this.icon,
    this.relevantPhases = const [],
  });
}