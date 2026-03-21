class Transaction {
  const Transaction({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.isExpense,
    this.note = '',
  });

  final String id;
  final String categoryId;
  final double amount;
  final DateTime date;
  final bool isExpense;
  final String note;

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'amount': amount,
      'date': date.toUtc().millisecondsSinceEpoch,
      'isExpense': isExpense,
      'note': note,
    };
  }

  factory Transaction.fromMap(String id, Map<String, dynamic> map) {
    return Transaction(
      id: id,
      categoryId: map['categoryId'] as String? ?? '',
      amount: (map['amount'] as num? ?? 0).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(
        (map['date'] as num?)?.toInt() ?? 0,
        isUtc: true,
      ).toLocal(),
      isExpense: map['isExpense'] as bool? ?? true,
      note: map['note'] as String? ?? '',
    );
  }
}
