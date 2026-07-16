class Income {
  const Income({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  final int? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }

  Income copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return Income(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
