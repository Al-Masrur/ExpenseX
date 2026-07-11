import 'package:flutter/material.dart';

class TopCategoryCard extends StatelessWidget {
  const TopCategoryCard({
    super.key,
    required this.category,
    required this.amount,
  });

  final String category;
  final double amount;

  String currency(double value) => '৳ ${value.toStringAsFixed(2)}';

  IconData getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;

      case 'transport':
        return Icons.directions_car;

      case 'shopping':
        return Icons.shopping_bag;

      case 'health':
        return Icons.local_hospital;

      case 'education':
        return Icons.school;

      case 'travel':
        return Icons.flight;

      case 'bills':
        return Icons.receipt_long;

      case 'entertainment':
        return Icons.movie;

      default:
        return Icons.payments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Icon(
                getCategoryIcon(),
                size: 28,
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Spending Category',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    currency(amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}