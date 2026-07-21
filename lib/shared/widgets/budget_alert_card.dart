import 'package:flutter/material.dart';

import 'package:expensex/core/services/budget_alert_service.dart';

class BudgetAlertCard extends StatelessWidget {
  const BudgetAlertCard({super.key, required this.alert});

  final BudgetAlert alert;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (icon, color) = switch (alert.level) {
      BudgetAlertLevel.healthy => (Icons.check_circle, Colors.green),
      BudgetAlertLevel.warning => (Icons.warning_amber_rounded, Colors.orange),
      BudgetAlertLevel.critical => (Icons.error_outline, Colors.deepOrange),
      BudgetAlertLevel.exceeded => (Icons.cancel, scheme.error),
    };

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alert.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(alert.message),

            const SizedBox(height: 16),

            LinearProgressIndicator(
              value: alert.progress.clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(alert.progress * 100).toStringAsFixed(0)}%'),
                Text('Remaining: ৳${alert.remaining.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
