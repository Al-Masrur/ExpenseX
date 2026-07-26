import 'package:flutter/material.dart';

import 'package:expensex/shared/widgets/app_card.dart';

class BalanceCard extends StatelessWidget {
  final String balance;
  final int transactionCount;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Balance', style: TextStyle(fontSize: 16)),

          const SizedBox(height: 10),

          Text(
            balance,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            '$transactionCount Total Transactions',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
