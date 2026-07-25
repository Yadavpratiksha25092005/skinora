import 'package:flutter/material.dart';
/// Small star-rating display (e.g. "H 4.8").
class RatingStars extends StatelessWidget {
final double rating;
final double size;
const RatingStars({super.key, required this.rating, this.size = 14});
@override
Widget build(BuildContext context) {
return Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(Icons.star_rounded, color: Colors.amber, size: size),
const SizedBox(width: 2),
Text(
rating.toStringAsFixed(1),
style: TextStyle(fontSize: size - 1, fontWeight: FontWeight.w600),
),
],
);
}
}