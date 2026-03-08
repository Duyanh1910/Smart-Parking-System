import 'package:flutter/material.dart';

class ControlInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color? contentColor;

  const ControlInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    this.iconBackgroundColor = const Color(0xFFE0E0E0),
    this.iconColor = Colors.black,
    this.contentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: contentColor ?? Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
