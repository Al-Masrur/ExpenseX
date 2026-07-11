class Budget {
  const Budget({
    this.id,
    required this.month,
    required this.year,
    required this.amount,
  });

  final int? id;
  final int month;
  final int year;
  final double amount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'year': year,
      'amount': amount,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      month: map['month'] as int,
      year: map['year'] as int,
      amount: (map['amount'] as num).toDouble(),
    );
  }
}