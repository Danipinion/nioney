import 'package:flutter/material.dart';

class SavingsTarget {
  final String id;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final DateTime? targetDate;
  final Color color;
  final IconData icon;

  const SavingsTarget({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    this.targetDate,
    required this.color,
    required this.icon,
  });

  SavingsTarget copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? savedAmount,
    DateTime? targetDate,
    Color? color,
    IconData? icon,
  }) {
    return SavingsTarget(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  bool get isAchieved => savedAmount >= targetAmount;
}
