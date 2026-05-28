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
  final DateTime? endDate;
  final DateTime? lastProcessedDate;

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
    this.endDate,
    this.lastProcessedDate,
  });

  RecurringTransaction copyWith({
    String? id,
    String? title,
    double? amount,
    bool? isExpense,
    String? period,
    String? categoryId,
    String? subCategory,
    String? walletId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastProcessedDate,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isExpense: isExpense ?? this.isExpense,
      period: period ?? this.period,
      categoryId: categoryId ?? this.categoryId,
      subCategory: subCategory ?? this.subCategory,
      walletId: walletId ?? this.walletId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastProcessedDate: lastProcessedDate ?? this.lastProcessedDate,
    );
  }

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
      'endDate': endDate?.toIso8601String(),
      'lastProcessedDate': lastProcessedDate?.toIso8601String(),
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
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      lastProcessedDate: json['lastProcessedDate'] != null ? DateTime.parse(json['lastProcessedDate']) : null,
    );
  }
}
