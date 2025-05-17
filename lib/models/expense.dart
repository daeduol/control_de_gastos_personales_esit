class Expense {
  final int? id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;

  const Expense({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });

  Expense copyWith({
    int? id,
    String? title,
    String? category,
    double? amount,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      category: (map['category'] ?? '') as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, title: $title,category: $category, amount: $amount, date: $date)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Expense &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              title == other.title &&
              category == other.category &&
              amount == other.amount &&
              date == other.date;

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ category.hashCode ^ amount.hashCode ^ date.hashCode;
}