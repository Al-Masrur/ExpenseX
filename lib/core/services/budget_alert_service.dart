class BudgetAlert {
  const BudgetAlert({
    required this.level,
    required this.title,
    required this.message,
    required this.progress,
    required this.remaining,
    required this.overAmount,
  });

  final BudgetAlertLevel level;
  final String title;
  final String message;

  /// Value between 0.0 and 1.0+
  final double progress;

  /// Remaining budget.
  /// Will be 0 if budget has been exceeded.
  final double remaining;

  /// Amount over budget.
  /// Will be 0 unless exceeded.
  final double overAmount;

  bool get isExceeded => level == BudgetAlertLevel.exceeded;
}

enum BudgetAlertLevel { healthy, warning, critical, exceeded }

class BudgetAlertService {
  const BudgetAlertService();

  BudgetAlert evaluate({required double budget, required double spent}) {
    if (budget <= 0) {
      return const BudgetAlert(
        level: BudgetAlertLevel.healthy,
        title: 'No Budget Set',
        message: 'Create a monthly budget to start tracking your spending.',
        progress: 0,
        remaining: 0,
        overAmount: 0,
      );
    }

    final progress = spent / budget;
    final remaining = (budget - spent).clamp(0.0, double.infinity);
    final overAmount = (spent - budget).clamp(0.0, double.infinity);

    if (progress >= 1.0) {
      return BudgetAlert(
        level: BudgetAlertLevel.exceeded,
        title: 'Budget Exceeded',
        message:
            'You have exceeded your monthly budget by ৳${overAmount.toStringAsFixed(2)}.',
        progress: progress,
        remaining: 0,
        overAmount: overAmount,
      );
    }

    if (progress >= 0.90) {
      return BudgetAlert(
        level: BudgetAlertLevel.critical,
        title: 'Budget Almost Reached',
        message:
            'You have used ${(progress * 100).toStringAsFixed(0)}% of your monthly budget.',
        progress: progress,
        remaining: remaining,
        overAmount: 0,
      );
    }

    if (progress >= 0.75) {
      return BudgetAlert(
        level: BudgetAlertLevel.warning,
        title: 'Budget Warning',
        message:
            'You have used ${(progress * 100).toStringAsFixed(0)}% of your monthly budget.',
        progress: progress,
        remaining: remaining,
        overAmount: 0,
      );
    }

    return BudgetAlert(
      level: BudgetAlertLevel.healthy,
      title: 'Budget Healthy',
      message:
          'You still have ৳${remaining.toStringAsFixed(2)} remaining this month.',
      progress: progress,
      remaining: remaining,
      overAmount: 0,
    );
  }
}
