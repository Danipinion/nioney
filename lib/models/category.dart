import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isExpense;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isExpense,
  });

  // Predefined categories
  static List<Category> get defaultCategories => [
    const Category(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.fastfood_rounded,
      color: Color(0xFFFF7043), // Vibrant Coral
      isExpense: true,
    ),
    const Category(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFEC407A), // Hot Pink
      isExpense: true,
    ),
    const Category(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF42A5F5), // Bright Blue
      isExpense: true,
    ),
    const Category(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_creation_rounded,
      color: Color(0xFFAB47BC), // Royal Purple
      isExpense: true,
    ),
    const Category(
      id: 'bills',
      name: 'Bills & Utilities',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFFFFCA28), // Golden Amber
      isExpense: true,
    ),
    const Category(
      id: 'health',
      name: 'Health & Medical',
      icon: Icons.healing_rounded,
      color: Color(0xFF26A69A), // Teal/Green
      isExpense: true,
    ),
    const Category(
      id: 'salary',
      name: 'Salary',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF66BB6A), // Emerald Green
      isExpense: false,
    ),
    const Category(
      id: 'investment',
      name: 'Investments',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF26C6DA), // Cyber Cyan
      isExpense: false,
    ),
    const Category(
      id: 'other_income',
      name: 'Other Income',
      icon: Icons.savings_rounded,
      color: Color(0xFF78909C), // Slate Grey
      isExpense: false,
    ),
    const Category(
      id: 'other_expense',
      name: 'Others',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF8D6E63), // Cocoa Brown
      isExpense: true,
    ),
  ];
}
