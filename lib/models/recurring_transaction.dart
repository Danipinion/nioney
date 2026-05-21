class RecurringTransaction {
  final String id;
  final String title;
  final double amount;
  final bool isExpense;
  final String period; // 'MONTHLY', 'WEEKLY', 'YEARLY'
  final String categoryId;
  final String subCategory;
  final String walletId;
  final DateTime startDate;

  const RecurringTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.period,
    required this.categoryId,
    this.subCategory = '',
    required this.walletId,
    required this.startDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isExpense': isExpense,
      'period': period,
      'categoryId': categoryId,
      'subCategory': subCategory,
      'walletId': walletId,
      'startDate': startDate.toIso8601String(),
    };
  }

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      isExpense: json['isExpense'],
      period: json['period'],
      categoryId: json['categoryId'],
      subCategory: json['subCategory'] ?? '',
      walletId: json['walletId'],
      startDate: DateTime.parse(json['startDate']),
    );
  }
}
