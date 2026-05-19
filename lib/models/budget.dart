class Budget {
  final String id;
  final String categoryId;
  final double limitAmount;
  final double spentAmount;
  final String period; // 'Weekly', 'Monthly'

  const Budget({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    this.spentAmount = 0.0,
    this.period = 'Monthly',
  });

  Budget copyWith({
    String? id,
    String? categoryId,
    double? limitAmount,
    double? spentAmount,
    String? period,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      period: period ?? this.period,
    );
  }

  double get progress => limitAmount > 0 ? (spentAmount / limitAmount).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => spentAmount > limitAmount;
}
