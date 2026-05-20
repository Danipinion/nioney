class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isExpense;
  final String categoryId;
  final String subCategory;
  final String walletId;
  final DateTime date;
  final String note;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.categoryId,
    this.subCategory = '',
    required this.walletId,
    required this.date,
    this.note = '',
  });

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    bool? isExpense,
    String? categoryId,
    String? subCategory,
    String? walletId,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isExpense: isExpense ?? this.isExpense,
      categoryId: categoryId ?? this.categoryId,
      subCategory: subCategory ?? this.subCategory,
      walletId: walletId ?? this.walletId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
