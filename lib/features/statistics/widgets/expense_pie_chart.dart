import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({super.key, required this.categoryTotals});

  final Map<String, double> categoryTotals;

  List<Color> get _colors => [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No expense data available')),
        ),
      );
    }

    final total = categoryTotals.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );

    final entries = categoryTotals.entries.toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense by Category',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 240,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 45,
                  sections: List.generate(entries.length, (index) {
                    final entry = entries[index];
                    final percentage = (entry.value / total) * 100;

                    return PieChartSectionData(
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(0)}%',
                      radius: 85,
                      color: _colors[index % _colors.length],
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: List.generate(entries.length, (index) {
                final entry = entries[index];

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _colors[index % _colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(entry.key),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
