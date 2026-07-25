import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/doctor_models.dart';
import 'rating_stars.dart';
/// One doctor row in the Doctor List — tapping opens the profile/booking
/// bottom sheet.
class DoctorCard extends StatelessWidget {
final Doctor doctor;
final VoidCallback onTap;
const DoctorCard({super.key, required this.doctor, required this.onTap});
@override
Widget build(BuildContext context) {
return GestureDetector(
onTap: onTap,
child: Container(
margin: const EdgeInsets.only(bottom: 14),
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: AppTheme.surfaceColor,
borderRadius: BorderRadius.circular(18),
),
child: Row(
children: [
CircleAvatar(
radius: 30,
backgroundColor: AppTheme.secondaryColor,
child: Text(
doctor.name.replaceFirst('Dr. ', '')[0],
style: const TextStyle(
color: AppTheme.primaryColor,
fontSize: 22,
fontWeight: FontWeight.bold,
),
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(doctor.name,
style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
const SizedBox(height: 2),
Text(doctor.specialization,
style: const TextStyle(
fontSize: 12, color: AppTheme.textSecondaryColor)),
const SizedBox(height: 6),
Row(
children: [
RatingStars(rating: doctor.rating),
const SizedBox(width: 10),
Text('${doctor.experienceYears} yrs exp',
style: const TextStyle(
fontSize: 12, color: AppTheme.textSecondaryColor)),
],
),
],
),
),
const Icon(Icons.chevron_right_rounded, color: Colors.grey),
],
),
),
);
}
}