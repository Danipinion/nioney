class Bill {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String categoryId;
  final String subCategory;
  final String? walletId; // Preselected or used wallet
  final DateTime? paidDate;
  final String? paymentTransactionId;

  const Bill({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
    this.categoryId = 'bills',
    this.subCategory = 'Tagihan',
    this.walletId,
    this.paidDate,
    this.paymentTransactionId,
  });

  Bill copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? dueDate,
    bool? isPaid,
    String? categoryId,
    String? subCategory,
    String? walletId,
    DateTime? paidDate,
    String? paymentTransactionId,
  }) {
    return Bill(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      categoryId: categoryId ?? this.categoryId,
      subCategory: subCategory ?? this.subCategory,
      walletId: walletId ?? this.walletId,
      paidDate: paidDate ?? this.paidDate,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'isPaid': isPaid,
      'categoryId': categoryId,
      'subCategory': subCategory,
      'walletId': walletId,
      'paidDate': paidDate?.toIso8601String(),
      'paymentTransactionId': paymentTransactionId,
    };
  }

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      isPaid: json['isPaid'],
      categoryId: json['categoryId'] ?? 'bills',
      subCategory: json['subCategory'] ?? 'Tagihan',
      walletId: json['walletId'],
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      paymentTransactionId: json['paymentTransactionId'],
    );
  }
}
