class DashboardSummary {
  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
  });

  final double totalIncome;
  final double totalExpense;

  double get balance => totalIncome - totalExpense;

  bool get isProfit => balance >= 0;
}
