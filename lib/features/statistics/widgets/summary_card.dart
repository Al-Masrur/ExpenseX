import 'package:flutter/material.dart';
import 'package:expensex/core/utils/currency_helper.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),

            const SizedBox(height: 18),

            Text(title, style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 8),

            Text(
              context.currency(amount),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
