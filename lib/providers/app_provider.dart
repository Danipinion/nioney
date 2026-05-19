import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import '../models/budget.dart';

class AppProvider with ChangeNotifier {
  static const String _prefTransactionsKey = 'nioney_transactions';
  static const String _prefWalletsKey = 'nioney_wallets';
  static const String _prefBudgetsKey = 'nioney_budgets';
  static const String _prefThemeModeKey = 'nioney_theme_mode';
  static const String _prefPaletteKey = 'nioney_palette';
  static const String _prefCurrencyKey = 'nioney_currency';

  final _uuid = const Uuid();

  List<Category> _categories = Category.defaultCategories;
  List<Wallet> _wallets = [];
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];

  ThemeMode _themeMode = ThemeMode.dark;
  String _currentPalette = 'Obsidian Mint';
  String _currencySymbol = 'Rp';

  // Getters
  List<Category> get categories => _categories;
  List<Wallet> get wallets => _wallets;
  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
  ThemeMode get themeMode => _themeMode;
  String get currentPalette => _currentPalette;
  String get currencySymbol => _currencySymbol;

  AppProvider() {
    _loadData();
  }

  // Load persistent data from SharedPreferences or set defaults
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load Theme Mode
    final themeStr = prefs.getString(_prefThemeModeKey);
    if (themeStr != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeStr,
        orElse: () => ThemeMode.dark,
      );
    }

    // 2. Load Color Palette
    _currentPalette = prefs.getString(_prefPaletteKey) ?? 'Obsidian Mint';

    // 3. Load Currency Symbol
    _currencySymbol = prefs.getString(_prefCurrencyKey) ?? 'Rp';

    // 4. Load Wallets
    final walletsJson = prefs.getString(_prefWalletsKey);
    if (walletsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(walletsJson);
        _wallets = decoded.map((w) => _walletFromJson(w)).toList();
      } catch (e) {
        _wallets = Wallet.defaultWallets;
      }
    } else {
      _wallets = Wallet.defaultWallets;
    }

    // 5. Load Transactions
    final txJson = prefs.getString(_prefTransactionsKey);
    if (txJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(txJson);
        _transactions = decoded.map((t) => _transactionFromJson(t)).toList();
      } catch (e) {
        _loadMockTransactions();
      }
    } else {
      _loadMockTransactions();
    }

    // 6. Load Budgets
    final budgetsJson = prefs.getString(_prefBudgetsKey);
    if (budgetsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(budgetsJson);
        _budgets = decoded.map((b) => _budgetFromJson(b)).toList();
      } catch (e) {
        _loadMockBudgets();
      }
    } else {
      _loadMockBudgets();
    }

    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> _saveWallets() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encoded = _wallets
        .map((w) => _walletToJson(w))
        .toList();
    await prefs.setString(_prefWalletsKey, jsonEncode(encoded));
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encoded = _transactions
        .map((t) => _transactionToJson(t))
        .toList();
    await prefs.setString(_prefTransactionsKey, jsonEncode(encoded));
  }

  Future<void> _saveBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encoded = _budgets
        .map((b) => _budgetToJson(b))
        .toList();
    await prefs.setString(_prefBudgetsKey, jsonEncode(encoded));
  }

  // Setters & Actions
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefThemeModeKey, mode.toString());
  }

  Future<void> setPalette(String name) async {
    _currentPalette = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefPaletteKey, name);
  }

  Future<void> setCurrency(String symbol) async {
    _currencySymbol = symbol;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefCurrencyKey, symbol);
  }

  // Transaction Operations
  Future<void> addTransaction({
    required String title,
    required double amount,
    required bool isExpense,
    required String categoryId,
    required String walletId,
    required DateTime date,
    String note = '',
  }) async {
    final tx = Transaction(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      isExpense: isExpense,
      categoryId: categoryId,
      walletId: walletId,
      date: date,
      note: note,
    );

    _transactions.insert(0, tx);

    // Update Wallet Balance
    _updateWalletBalance(walletId, isExpense ? -amount : amount);

    await _saveTransactions();
    await _saveWallets();
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index != -1) {
      final tx = _transactions[index];
      // Reverse Wallet Balance Update
      _updateWalletBalance(tx.walletId, tx.isExpense ? tx.amount : -tx.amount);
      _transactions.removeAt(index);

      await _saveTransactions();
      await _saveWallets();
      notifyListeners();
    }
  }

  // Wallet Operations
  Future<void> addWallet({
    required String name,
    required String type,
    required double initialBalance,
    required Color color,
    required IconData icon,
  }) async {
    final w = Wallet(
      id: 'wallet_${_uuid.v4()}',
      name: name,
      balance: initialBalance,
      type: type,
      color: color,
      icon: icon,
    );
    _wallets.add(w);
    await _saveWallets();
    notifyListeners();
  }

  Future<void> updateWallet(Wallet updated) async {
    final index = _wallets.indexWhere((w) => w.id == updated.id);
    if (index != -1) {
      _wallets[index] = updated;
      await _saveWallets();
      notifyListeners();
    }
  }

  Future<void> deleteWallet(String id) async {
    _wallets.removeWhere((w) => w.id == id);
    // Delete transactions associated with this wallet
    _transactions.removeWhere((tx) => tx.walletId == id);

    await _saveWallets();
    await _saveTransactions();
    notifyListeners();
  }

  // Budget Operations
  Future<void> addBudget({
    required String categoryId,
    required double limitAmount,
    String period = 'Monthly',
  }) async {
    final b = Budget(
      id: 'budget_${_uuid.v4()}',
      categoryId: categoryId,
      limitAmount: limitAmount,
      period: period,
    );
    _budgets.add(b);
    await _saveBudgets();
    notifyListeners();
  }

  Future<void> updateBudget(Budget updated) async {
    final index = _budgets.indexWhere((b) => b.id == updated.id);
    if (index != -1) {
      _budgets[index] = updated;
      await _saveBudgets();
      notifyListeners();
    }
  }

  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    await _saveBudgets();
    notifyListeners();
  }

  // Utility Calculations
  void _updateWalletBalance(String walletId, double difference) {
    final index = _wallets.indexWhere((w) => w.id == walletId);
    if (index != -1) {
      final w = _wallets[index];
      _wallets[index] = w.copyWith(balance: w.balance + difference);
    }
  }

  // Dynamic values
  double get totalBalance {
    double total = 0.0;
    for (var w in _wallets) {
      total += w.balance;
    }
    return total;
  }

  double get monthlyIncome {
    final now = DateTime.now();
    double total = 0.0;
    for (var tx in _transactions) {
      if (!tx.isExpense &&
          tx.date.month == now.month &&
          tx.date.year == now.year) {
        total += tx.amount;
      }
    }
    return total;
  }

  double get monthlyExpense {
    final now = DateTime.now();
    double total = 0.0;
    for (var tx in _transactions) {
      if (tx.isExpense &&
          tx.date.month == now.month &&
          tx.date.year == now.year) {
        total += tx.amount;
      }
    }
    return total;
  }

  // Dynamic budget spent derivation
  double getSpentForCategory(String categoryId) {
    final now = DateTime.now();
    double total = 0.0;
    for (var tx in _transactions) {
      if (tx.isExpense &&
          tx.categoryId == categoryId &&
          tx.date.month == now.month &&
          tx.date.year == now.year) {
        total += tx.amount;
      }
    }
    return total;
  }

  // Categories spending breakdown (for pie charts)
  Map<Category, double> getCategorySpendingBreakdown() {
    final Map<Category, double> breakdown = {};
    final now = DateTime.now();

    for (var tx in _transactions) {
      if (tx.isExpense &&
          tx.date.month == now.month &&
          tx.date.year == now.year) {
        final cat = _categories.firstWhere(
          (c) => c.id == tx.categoryId,
          orElse: () => _categories.last, // 'Others'
        );
        breakdown[cat] = (breakdown[cat] ?? 0.0) + tx.amount;
      }
    }
    return breakdown;
  }

  IconData _getIconFromCodePoint(int codePoint) {
    if (codePoint == Icons.payments_rounded.codePoint)
      return Icons.payments_rounded;
    if (codePoint == Icons.account_balance_rounded.codePoint)
      return Icons.account_balance_rounded;
    if (codePoint == Icons.phone_android_rounded.codePoint)
      return Icons.phone_android_rounded;
    if (codePoint == Icons.credit_card_rounded.codePoint)
      return Icons.credit_card_rounded;
    if (codePoint == Icons.account_balance_wallet_rounded.codePoint)
      return Icons.account_balance_wallet_rounded;
    if (codePoint == Icons.savings_rounded.codePoint)
      return Icons.savings_rounded;
    if (codePoint == Icons.shopping_bag_rounded.codePoint)
      return Icons.shopping_bag_rounded;
    if (codePoint == Icons.directions_car_rounded.codePoint)
      return Icons.directions_car_rounded;
    return Icons.account_balance_wallet_rounded;
  }

  // Helpers: JSON Serialization
  Wallet _walletFromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      name: json['name'],
      balance: (json['balance'] as num).toDouble(),
      type: json['type'],
      color: Color(json['color'] as int),
      icon: _getIconFromCodePoint(json['icon'] as int),
    );
  }

  Map<String, dynamic> _walletToJson(Wallet w) {
    return {
      'id': w.id,
      'name': w.name,
      'balance': w.balance,
      'type': w.type,
      'color': w.color.value,
      'icon': w.icon.codePoint,
    };
  }

  Transaction _transactionFromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      isExpense: json['isExpense'],
      categoryId: json['categoryId'],
      walletId: json['walletId'],
      date: DateTime.parse(json['date']),
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> _transactionToJson(Transaction t) {
    return {
      'id': t.id,
      'title': t.title,
      'amount': t.amount,
      'isExpense': t.isExpense,
      'categoryId': t.categoryId,
      'walletId': t.walletId,
      'date': t.date.toIso8601String(),
      'note': t.note,
    };
  }

  Budget _budgetFromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      categoryId: json['categoryId'],
      limitAmount: (json['limitAmount'] as num).toDouble(),
      period: json['period'] ?? 'Monthly',
    );
  }

  Map<String, dynamic> _budgetToJson(Budget b) {
    return {
      'id': b.id,
      'categoryId': b.categoryId,
      'limitAmount': b.limitAmount,
      'period': b.period,
    };
  }

  // Initializing mock data if database is fresh
  void _loadMockTransactions() {
    final now = DateTime.now();
    _transactions = [
      Transaction(
        id: 'tx_1',
        title: 'Monthly Salary',
        amount: 8500000.0,
        isExpense: false,
        categoryId: 'salary',
        walletId: 'wallet_bank',
        date: now.subtract(const Duration(days: 3)),
        note: 'Main income source',
      ),
      Transaction(
        id: 'tx_2',
        title: 'Starbucks Coffee',
        amount: 58000.0,
        isExpense: true,
        categoryId: 'food',
        walletId: 'wallet_cash',
        date: now.subtract(const Duration(hours: 4)),
        note: 'Caramel Macchiato',
      ),
      Transaction(
        id: 'tx_3',
        title: 'Sushi Dinner',
        amount: 230000.0,
        isExpense: true,
        categoryId: 'food',
        walletId: 'wallet_gopay',
        date: now.subtract(const Duration(days: 1)),
        note: 'Dinner with friends',
      ),
      Transaction(
        id: 'tx_4',
        title: 'Cinema Tickets',
        amount: 90000.0,
        isExpense: true,
        categoryId: 'entertainment',
        walletId: 'wallet_credit',
        date: now.subtract(const Duration(days: 2)),
        note: 'Doctor Strange 2 tickets',
      ),
      Transaction(
        id: 'tx_5',
        title: 'Indomaret Groceries',
        amount: 320000.0,
        isExpense: true,
        categoryId: 'shopping',
        walletId: 'wallet_bank',
        date: now.subtract(const Duration(days: 4)),
        note: 'Weekly essential items',
      ),
      Transaction(
        id: 'tx_6',
        title: 'Gojek Ride',
        amount: 25000.0,
        isExpense: true,
        categoryId: 'transport',
        walletId: 'wallet_gopay',
        date: now.subtract(const Duration(days: 1, hours: 2)),
        note: 'Commute to office',
      ),
      Transaction(
        id: 'tx_7',
        title: 'Home WiFi Bill',
        amount: 380000.0,
        isExpense: true,
        categoryId: 'bills',
        walletId: 'wallet_bank',
        date: now.subtract(const Duration(days: 5)),
        note: 'Biznet monthly subscription',
      ),
    ];
  }

  void _loadMockBudgets() {
    _budgets = [
      const Budget(id: 'budget_1', categoryId: 'food', limitAmount: 2000000.0),
      const Budget(
        id: 'budget_2',
        categoryId: 'shopping',
        limitAmount: 1500000.0,
      ),
      const Budget(id: 'budget_3', categoryId: 'bills', limitAmount: 1000000.0),
    ];
  }
}
