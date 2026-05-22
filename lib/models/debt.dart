class Debt {
  final String id;
  final String name;
  final double amount;
  final double paidAmount;
  final bool isDebt; // true = Utang (we owe), false = Piutang (they owe us)
  final DateTime date;
  final DateTime? dueDate;
  final String note;
  final String? walletId; // Wallet used for initial borrowing/lending

  const Debt({
    required this.id,
    required this.name,
    required this.amount,
    required this.paidAmount,
    required this.isDebt,
    required this.date,
    this.dueDate,
    this.note = '',
    this.walletId,
  });

  bool get isSettled => paidAmount >= amount;
  double get remainingAmount => amount - paidAmount;

  Debt copyWith({
    String? id,
    String? name,
    double? amount,
    double? paidAmount,
    bool? isDebt,
    DateTime? date,
    DateTime? dueDate,
    String? note,
    String? walletId,
  }) {
    return Debt(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      isDebt: isDebt ?? this.isDebt,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      walletId: walletId ?? this.walletId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'paidAmount': paidAmount,
      'isDebt': isDebt,
      'date': date.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'note': note,
      'walletId': walletId,
    };
  }

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      name: json['name'],
      amount: json['amount'].toDouble(),
      paidAmount: json['paidAmount'].toDouble(),
      isDebt: json['isDebt'],
      date: DateTime.parse(json['date']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      note: json['note'] ?? '',
      walletId: json['walletId'],
    );
  }
}
