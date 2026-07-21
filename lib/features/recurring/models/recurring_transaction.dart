enum RecurringType { income, expense }

enum RecurringFrequency { daily, weekly, monthly, yearly }

class RecurringTransaction {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final RecurringType type;
  final RecurringFrequency frequency;
  final DateTime nextDate;
  final String? note;
  final bool isActive;

  const RecurringTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.frequency,
    required this.nextDate,
    this.note,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type.name,
      'frequency': frequency.name,
      'next_date': nextDate.millisecondsSinceEpoch,
      'note': note,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory RecurringTransaction.fromMap(Map<String, dynamic> map) {
    return RecurringTransaction(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      type: RecurringType.values.firstWhere((item) => item.name == map['type']),
      frequency: RecurringFrequency.values.firstWhere(
        (item) => item.name == map['frequency'],
      ),
      nextDate: DateTime.fromMillisecondsSinceEpoch(map['next_date'] as int),
      note: map['note'] as String?,
      isActive: map['is_active'] == 1,
    );
  }

  RecurringTransaction copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    RecurringType? type,
    RecurringFrequency? frequency,
    DateTime? nextDate,
    String? note,
    bool? isActive,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      nextDate: nextDate ?? this.nextDate,
      note: note ?? this.note,
      isActive: isActive ?? this.isActive,
    );
  }
}
