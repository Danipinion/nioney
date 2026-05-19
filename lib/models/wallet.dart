import 'package:flutter/material.dart';

class Wallet {
  final String id;
  final String name;
  final double balance;
  final String type; // 'Cash', 'Bank', 'E-Wallet', 'Credit Card'
  final Color color;
  final IconData icon;

  const Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
    required this.color,
    required this.icon,
  });

  Wallet copyWith({
    String? id,
    String? name,
    double? balance,
    String? type,
    Color? color,
    IconData? icon,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  // Predefined wallets
  static List<Wallet> get defaultWallets => [
    const Wallet(
      id: 'wallet_cash',
      name: 'Cash Pocket',
      balance: 500000.0,
      type: 'Cash',
      color: Color(0xFF66BB6A), // Fresh Emerald
      icon: Icons.payments_rounded,
    ),
    const Wallet(
      id: 'wallet_bank',
      name: 'BCA Account',
      balance: 4500000.0,
      type: 'Bank',
      color: Color(0xFF42A5F5), // Electric Blue
      icon: Icons.account_balance_rounded,
    ),
    const Wallet(
      id: 'wallet_gopay',
      name: 'GoPay Wallet',
      balance: 1200000.0,
      type: 'E-Wallet',
      color: Color(0xFF26C6DA), // Tech Cyan
      icon: Icons.phone_android_rounded,
    ),
    const Wallet(
      id: 'wallet_credit',
      name: 'Visa Credit Card',
      balance: -750000.0, // Negative for credit liability
      type: 'Credit Card',
      color: Color(0xFFAB47BC), // Royal Violet
      icon: Icons.credit_card_rounded,
    ),
  ];
}
