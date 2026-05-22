import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/recurring_transaction.dart';
import '../models/savings_target.dart';
import '../models/bill.dart';

class AppProvider with ChangeNotifier {
  static const String _prefTransactionsKey = 'nioney_transactions';
  static const String _prefWalletsKey = 'nioney_wallets';
  static const String _prefBudgetsKey = 'nioney_budgets';
  static const String _prefRecurringKey = 'nioney_recurring';
  static const String _prefThemeModeKey = 'nioney_theme_mode';
  static const String _prefPaletteKey = 'nioney_palette';
  static const String _prefCurrencyKey = 'nioney_currency';
  static const String _prefCategoriesKey = 'nioney_categories';
  static const String _prefSubCategoriesKey = 'nioney_subcategories';
  static const String _prefSavingsTargetsKey = 'nioney_savings_targets';
  static const String _prefBillsKey = 'nioney_bills';

  final _uuid = const Uuid();

  List<Category> _categories = [];
  Map<String, List<String>> _subCategories = {};
  List<Wallet> _wallets = [];
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  List<RecurringTransaction> _recurringTransactions = [];
  List<SavingsTarget> _savingsTargets = [];
  List<Bill> _bills = [];

  ThemeMode _themeMode = ThemeMode.dark;
  String _currentPalette = 'Deep Sapphire';
  String _currencySymbol = 'Rp';

  // Getters
  List<Category> get categories => _categories;
  Map<String, List<String>> get subCategories => _subCategories;
  List<Wallet> get wallets => _wallets;
  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
  List<RecurringTransaction> get recurringTransactions => _recurringTransactions;
  List<SavingsTarget> get savingsTargets => _savingsTargets;
  List<Bill> get bills => _bills;
  ThemeMode get themeMode => _themeMode;
  String get currentPalette => _currentPalette;
  String get currencySymbol => _currencySymbol;

  List<String> getSubCategoriesForCategory(String categoryId) {
    return _subCategories[categoryId] ?? [];
  }

  AppProvider() {
    _loadData();
  }

  List<Category> _getDefaultCategoriesList() {
    return [
      const Category(id: 'food', name: 'Makanan & Minuman', icon: Icons.fastfood_rounded, color: Color(0xFFFF7043), isExpense: true),
      const Category(id: 'transport', name: 'Transportasi', icon: Icons.directions_car_rounded, color: Color(0xFF42A5F5), isExpense: true),
      const Category(id: 'shopping', name: 'Belanja', icon: Icons.shopping_bag_rounded, color: Color(0xFFEC407A), isExpense: true),
      const Category(id: 'bills', name: 'Tempat Tinggal', icon: Icons.home_rounded, color: Color(0xFFFFCA28), isExpense: true),
      const Category(id: 'entertainment', name: 'Hiburan', icon: Icons.movie_creation_rounded, color: Color(0xFFAB47BC), isExpense: true),
      const Category(id: 'health', name: 'Kesehatan', icon: Icons.healing_rounded, color: Color(0xFF26A69A), isExpense: true),
      const Category(id: 'education', name: 'Pendidikan', icon: Icons.school_rounded, color: Color(0xFF8D6E63), isExpense: true),
      const Category(id: 'personal', name: 'Pribadi', icon: Icons.person_rounded, color: Color(0xFFBA68C8), isExpense: true),
      const Category(id: 'financial', name: 'Keuangan', icon: Icons.payments_rounded, color: Color(0xFF64748B), isExpense: true),
      const Category(id: 'social', name: 'Teman', icon: Icons.group_rounded, color: Color(0xFF26C6DA), isExpense: true),
      const Category(id: 'other_expense', name: 'Lain-lain', icon: Icons.more_horiz_rounded, color: Color(0xFF8D6E63), isExpense: true),
      const Category(id: 'salary', name: 'Gaji', icon: Icons.account_balance_wallet_rounded, color: Color(0xFF66BB6A), isExpense: false),
      const Category(id: 'business', name: 'Bisnis', icon: Icons.storefront_rounded, color: Color(0xFFFFA726), isExpense: false),
      const Category(id: 'investment', name: 'Investasi', icon: Icons.trending_up_rounded, color: Color(0xFF26C6DA), isExpense: false),
      const Category(id: 'gift', name: 'Hadiah', icon: Icons.card_giftcard_rounded, color: Color(0xFFEC407A), isExpense: false),
      const Category(id: 'other_income', name: 'Pemasukan Lain', icon: Icons.savings_rounded, color: Color(0xFF78909C), isExpense: false),
      const Category(id: 'sys_transfer', name: 'Transfer', icon: Icons.swap_horiz_rounded, color: Color(0xFF9E9E9E), isExpense: true),
      const Category(id: 'sys_saving_target', name: 'Target Tabungan', icon: Icons.track_changes_rounded, color: Color(0xFF00D179), isExpense: true),
      const Category(id: 'sys_debt', name: 'Hutang Piutang', icon: Icons.account_balance_wallet_rounded, color: Colors.deepOrange, isExpense: true),
      const Category(id: 'sys_reimburse', name: 'Reimburse', icon: Icons.handshake_rounded, color: Colors.orange, isExpense: true),
    ];
  }

  Map<String, List<String>> _getDefaultSubCategories() {
    return {
      'food': ['Sarapan', 'Makan Siang', 'Makan Malam', 'Tempat Makan', 'Camilan', 'Minuman', 'Sembako', 'Pesan Antar', 'Alkohol', 'Buah', 'Kopi', 'Jajanan'],
      'transport': ['Bus', 'Kereta', 'Taksi', 'Bensin', 'Parkir', 'Perawatan', 'Asuransi', 'Tol', 'Ojek Online', 'Pesawat'],
      'shopping': ['Pakaian', 'Elektronik', 'Rumah', 'Kecantikan', 'Hadiah', 'Perangkat Lunak', 'Peralatan', 'Sepatu', 'Online', 'Perawatan'],
      'bills': ['Sewa', 'KPR', 'Tagihan', 'Internet', 'Perawatan', 'Perabotan', 'Jasa', 'Laundry', 'Pulsa & Data', 'Listrik'],
      'entertainment': ['Bioskop', 'Game', 'Streaming', 'Acara', 'Hobi', 'Perjalanan', 'Musik'],
      'health': ['Dokter', 'Apotik', 'Gym', 'Asuransi', 'Kesehatan Mental', 'Olahraga'],
      'education': ['SPP', 'Buku', 'Kursus', 'Perlengkapan', 'Alat Tulis'],
      'personal': ['Potong Rambut', 'Spa', 'Kosmetik'],
      'financial': ['Pajak', 'Biaya Admin', 'Denda', 'Asuransi', 'Donasi/Sedekah', 'Zakat'],
      'social': ['Transfer', 'Traktir', 'Refund', 'Loan', 'Gift'],
      'other_expense': ['Donasi', 'Zakat', 'Biaya Admin', 'Denda', 'Kehilangan', 'Lain-lain'],
      'salary': ['Bulanan', 'Mingguan', 'Bonus', 'Lembur'],
      'business': ['Penjualan', 'Jasa', 'Keuntungan'],
      'investment': ['Dividen', 'Bunga', 'Kripto', 'Saham', 'Real Estate'],
      'gift': ['Ulang Tahun', 'Hari Raya', 'Uang Saku'],
      'other_income': ['Pengembalian Dana', 'Hibah', 'Lotere', 'Penjualan Barang'],
    };
  }

  // Load persistent data from SharedPreferences or set defaults
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Categories
    final categoriesJson = prefs.getString(_prefCategoriesKey);
    bool needsForceDefaults = false;
    if (categoriesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(categoriesJson);
        _categories = decoded.map((c) => _categoryFromJson(c)).toList();
        if (!_categories.any((c) => c.id == 'social') || 
            !_categories.any((c) => c.id == 'financial') ||
            !_categories.any((c) => c.id == 'business') ||
            !_categories.any((c) => c.id == 'sys_transfer') ||
            !_categories.any((c) => c.id == 'sys_saving_target') ||
            !_categories.any((c) => c.id == 'gift')) {
          needsForceDefaults = true;
        }
      } catch (e) {
        needsForceDefaults = true;
      }
    } else {
      needsForceDefaults = true;
    }

    if (needsForceDefaults) {
      _categories = _getDefaultCategoriesList();
      _subCategories = _getDefaultSubCategories();
      await _saveCategories();
      await _saveSubCategories();
    } else {
      // Load Subcategories
      final subJson = prefs.getString(_prefSubCategoriesKey);
      if (subJson != null) {
        try {
          final Map<String, dynamic> decoded = jsonDecode(subJson);
          _subCategories = decoded.map((key, value) => MapEntry(key, List<String>.from(value)));
        } catch (e) {
          _subCategories = _getDefaultSubCategories();
        }
      } else {
        _subCategories = _getDefaultSubCategories();
      }
    }

    // 1. Load Theme Mode
    final themeStr = prefs.getString(_prefThemeModeKey);
    if (themeStr != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeStr,
        orElse: () => ThemeMode.dark,
      );
    }

    // 2. Load Color Palette
    _currentPalette = prefs.getString(_prefPaletteKey) ?? 'Deep Sapphire';

    // 3. Load Currency Symbol
    _currencySymbol = prefs.getString(_prefCurrencyKey) ?? 'Rp';

    // 4. Load Wallets
    final walletsJson = prefs.getString(_prefWalletsKey);
    if (walletsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(walletsJson);
        _wallets = decoded.map((w) => _walletFromJson(w)).toList();
      } catch (e) {
        _wallets = [];
      }
    } else {
      _wallets = [];
    }

    // 5. Load Transactions
    final txJson = prefs.getString(_prefTransactionsKey);
    if (txJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(txJson);
        _transactions = decoded.map((t) => _transactionFromJson(t)).toList();
      } catch (e) {
        _transactions = [];
      }
    } else {
      _transactions = [];
    }

    // 6. Load Budgets
    final budgetsJson = prefs.getString(_prefBudgetsKey);
    if (budgetsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(budgetsJson);
        _budgets = decoded.map((b) => _budgetFromJson(b)).toList();
      } catch (e) {
        _budgets = [];
      }
    } else {
      _budgets = [];
    }

    // 7. Load Recurring Transactions
    final recurringJson = prefs.getString(_prefRecurringKey);
    if (recurringJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(recurringJson);
        _recurringTransactions = decoded.map((r) => RecurringTransaction.fromJson(r)).toList();
      } catch (e) {
        _recurringTransactions = [];
      }
    } else {
      _recurringTransactions = [];
    }

    // 8. Load Savings Targets
    final savingsJson = prefs.getString(_prefSavingsTargetsKey);
    if (savingsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(savingsJson);
        _savingsTargets = decoded.map((s) => _savingsTargetFromJson(s)).toList();
      } catch (e) {
        _savingsTargets = [];
      }
    } else {
      _savingsTargets = [];
    }

    // 9. Load Bills
    final billsJson = prefs.getString(_prefBillsKey);
    if (billsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(billsJson);
        _bills = decoded.map((b) => Bill.fromJson(b)).toList();
      } catch (e) {
        _bills = [];
      }
    } else {
      _bills = [];
    }

    notifyListeners();
  }

  Future<void> _saveBills() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonStr = jsonEncode(_bills.map((b) => b.toJson()).toList());
    await prefs.setString(_prefBillsKey, jsonStr);
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

  Future<void> _saveRecurringTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encoded = _recurringTransactions
        .map((r) => r.toJson())
        .toList();
    await prefs.setString(_prefRecurringKey, jsonEncode(encoded));
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
    String subCategory = '',
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
      subCategory: subCategory,
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

  Future<void> updateTransaction(Transaction updated) async {
    final index = _transactions.indexWhere((tx) => tx.id == updated.id);
    if (index != -1) {
      final oldTx = _transactions[index];
      // Revert old transaction
      _updateWalletBalance(oldTx.walletId, oldTx.isExpense ? oldTx.amount : -oldTx.amount);
      
      // Apply new transaction
      _updateWalletBalance(updated.walletId, updated.isExpense ? -updated.amount : updated.amount);
      
      _transactions[index] = updated;
      
      await _saveTransactions();
      await _saveWallets();
      notifyListeners();
    }
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
    String subCategory = '',
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

  // Recurring Transaction Operations
  Future<void> addRecurringTransaction({
    required String title,
    required double amount,
    required bool isExpense,
    required String period,
    required String categoryId,
    String subCategory = '',
    required String walletId,
    required DateTime startDate,
  }) async {
    final r = RecurringTransaction(
      id: 'recurring_${_uuid.v4()}',
      title: title,
      amount: amount,
      isExpense: isExpense,
      period: period,
      categoryId: categoryId,
      subCategory: subCategory,
      walletId: walletId,
      startDate: startDate,
    );
    _recurringTransactions.add(r);
    await _saveRecurringTransactions();
    notifyListeners();
  }

  Future<void> updateRecurringTransaction(RecurringTransaction updated) async {
    final index = _recurringTransactions.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      _recurringTransactions[index] = updated;
      await _saveRecurringTransactions();
      notifyListeners();
    }
  }

  Future<void> deleteRecurringTransaction(String id) async {
    _recurringTransactions.removeWhere((r) => r.id == id);
    await _saveRecurringTransactions();
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
          tx.categoryId != 'sys_transfer' &&
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
          tx.categoryId != 'sys_transfer' &&
          tx.date.month == now.month &&
          tx.date.year == now.year) {
        total += tx.amount;
      }
    }
    return total;
  }

  // Dynamic budget spent derivation
  double getSpentForCategory(String categoryId, {DateTime? targetMonth}) {
    final month = targetMonth ?? DateTime.now();
    double total = 0.0;
    for (var tx in _transactions) {
      if (tx.isExpense &&
          tx.categoryId != 'sys_transfer' &&
          tx.categoryId == categoryId &&
          tx.date.month == month.month &&
          tx.date.year == month.year) {
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
          tx.categoryId != 'sys_transfer' &&
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
    if (codePoint == Icons.payments_rounded.codePoint) { return Icons.payments_rounded; }
    if (codePoint == Icons.account_balance_rounded.codePoint) { return Icons.account_balance_rounded; }
    if (codePoint == Icons.phone_android_rounded.codePoint) { return Icons.phone_android_rounded; }
    if (codePoint == Icons.credit_card_rounded.codePoint) { return Icons.credit_card_rounded; }
    if (codePoint == Icons.account_balance_wallet_rounded.codePoint) { return Icons.account_balance_wallet_rounded; }
    if (codePoint == Icons.savings_rounded.codePoint) { return Icons.savings_rounded; }
    if (codePoint == Icons.shopping_bag_rounded.codePoint) { return Icons.shopping_bag_rounded; }
    if (codePoint == Icons.directions_car_rounded.codePoint) { return Icons.directions_car_rounded; }
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
      'color': w.color.toARGB32(),
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
      subCategory: json['subCategory'] ?? '',
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
      'subCategory': t.subCategory,
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



  Future<void> addCategory({
    required String name,
    required IconData icon,
    required Color color,
    required bool isExpense,
  }) async {
    final newId = _uuid.v4();
    final cat = Category(
      id: newId,
      name: name,
      icon: icon,
      color: color,
      isExpense: isExpense,
    );
    _categories.add(cat);
    _subCategories[newId] = [];
    await _saveCategories();
    await _saveSubCategories();
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    _subCategories.remove(id);
    await _saveCategories();
    await _saveSubCategories();
    notifyListeners();
  }

  Future<void> addSubCategory(String categoryId, String name) async {
    if (_subCategories[categoryId] == null) {
      _subCategories[categoryId] = [];
    }
    _subCategories[categoryId]!.add(name);
    await _saveSubCategories();
    notifyListeners();
  }

  Future<void> deleteSubCategory(String categoryId, String name) async {
    if (_subCategories[categoryId] != null) {
      _subCategories[categoryId]!.remove(name);
      await _saveSubCategories();
      notifyListeners();
    }
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _categories.map((c) => _categoryToJson(c)).toList();
    await prefs.setString(_prefCategoriesKey, jsonEncode(encoded));
  }

  Future<void> _saveSubCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefSubCategoriesKey, jsonEncode(_subCategories));
  }

  Category _categoryFromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      isExpense: json['isExpense'] ?? true,
    );
  }

  Map<String, dynamic> _categoryToJson(Category c) {
    return {
      'id': c.id,
      'name': c.name,
      'icon': c.icon.codePoint,
      'color': c.color.toARGB32(),
      'isExpense': c.isExpense,
    };
  }

  // Savings Targets Methods
  Future<void> _saveSavingsTargets() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encoded = _savingsTargets
        .map((s) => _savingsTargetToJson(s))
        .toList();
    await prefs.setString(_prefSavingsTargetsKey, jsonEncode(encoded));
  }

  SavingsTarget _savingsTargetFromJson(Map<String, dynamic> json) {
    return SavingsTarget(
      id: json['id'],
      title: json['title'],
      targetAmount: (json['targetAmount'] as num).toDouble(),
      savedAmount: (json['savedAmount'] as num).toDouble(),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      color: Color(json['color'] as int),
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
    );
  }

  Map<String, dynamic> _savingsTargetToJson(SavingsTarget t) {
    return {
      'id': t.id,
      'title': t.title,
      'targetAmount': t.targetAmount,
      'savedAmount': t.savedAmount,
      'targetDate': t.targetDate?.toIso8601String(),
      'color': t.color.toARGB32(),
      'icon': t.icon.codePoint,
    };
  }

  Future<void> addSavingsTarget({
    required String title,
    required double targetAmount,
    DateTime? targetDate,
    required Color color,
    required IconData icon,
  }) async {
    final newTarget = SavingsTarget(
      id: _uuid.v4(),
      title: title,
      targetAmount: targetAmount,
      savedAmount: 0.0,
      targetDate: targetDate,
      color: color,
      icon: icon,
    );
    _savingsTargets.add(newTarget);
    notifyListeners();
    await _saveSavingsTargets();
  }

  Future<void> deleteSavingsTarget(String id) async {
    _savingsTargets.removeWhere((t) => t.id == id);
    notifyListeners();
    await _saveSavingsTargets();
  }

  Future<void> depositToSavingsTarget({
    required String targetId,
    required double amount,
    required String walletId,
  }) async {
    final targetIndex = _savingsTargets.indexWhere((t) => t.id == targetId);
    final walletIndex = _wallets.indexWhere((w) => w.id == walletId);
    if (targetIndex == -1 || walletIndex == -1) return;

    final target = _savingsTargets[targetIndex];
    final wallet = _wallets[walletIndex];

    // Deduct from wallet balance
    final updatedWallet = wallet.copyWith(balance: wallet.balance - amount);
    _wallets[walletIndex] = updatedWallet;

    // Add to savings target
    final updatedTarget = target.copyWith(savedAmount: target.savedAmount + amount);
    _savingsTargets[targetIndex] = updatedTarget;

    // Create a transaction
    final newTx = Transaction(
      id: _uuid.v4(),
      title: 'Setor: ${target.title}',
      amount: amount,
      isExpense: true,
      categoryId: 'sys_saving_target',
      subCategory: target.title,
      walletId: walletId,
      date: DateTime.now(),
      note: 'Menabung untuk target: ${target.title}',
    );
    _transactions.insert(0, newTx);

    notifyListeners();
    await _saveWallets();
    await _saveSavingsTargets();
    await _saveTransactions();
  }

  Future<void> withdrawFromSavingsTarget({
    required String targetId,
    required double amount,
    required String walletId,
  }) async {
    final targetIndex = _savingsTargets.indexWhere((t) => t.id == targetId);
    final walletIndex = _wallets.indexWhere((w) => w.id == walletId);
    if (targetIndex == -1 || walletIndex == -1) return;

    final target = _savingsTargets[targetIndex];
    final wallet = _wallets[walletIndex];

    // Withdraw amount cannot exceed saved amount
    final withdrawAmount = amount.clamp(0.0, target.savedAmount);
    if (withdrawAmount <= 0) return;

    // Add back to wallet balance
    final updatedWallet = wallet.copyWith(balance: wallet.balance + withdrawAmount);
    _wallets[walletIndex] = updatedWallet;

    // Deduct from savings target
    final updatedTarget = target.copyWith(savedAmount: target.savedAmount - withdrawAmount);
    _savingsTargets[targetIndex] = updatedTarget;

    // Create an income transaction
    final newTx = Transaction(
      id: _uuid.v4(),
      title: 'Tarik: ${target.title}',
      amount: withdrawAmount,
      isExpense: false,
      categoryId: 'sys_saving_target',
      subCategory: target.title,
      walletId: walletId,
      date: DateTime.now(),
      note: 'Penarikan dari target: ${target.title}',
    );
    _transactions.insert(0, newTx);

    notifyListeners();
    await _saveWallets();
    await _saveSavingsTargets();
    await _saveTransactions();
  }

  // Bills Management Methods
  Future<void> addBill({
    required String title,
    required double amount,
    required DateTime dueDate,
    required String categoryId,
    required String subCategory,
    String? walletId,
  }) async {
    final bill = Bill(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      dueDate: dueDate,
      isPaid: false,
      categoryId: categoryId,
      subCategory: subCategory,
      walletId: walletId,
    );
    _bills.add(bill);
    await _saveBills();
    notifyListeners();
  }

  Future<void> updateBill(Bill updatedBill) async {
    final idx = _bills.indexWhere((b) => b.id == updatedBill.id);
    if (idx != -1) {
      _bills[idx] = updatedBill;
      await _saveBills();
      notifyListeners();
    }
  }

  Future<void> payBill({
    required String billId,
    required String walletId,
    required DateTime paidDate,
  }) async {
    final idx = _bills.indexWhere((b) => b.id == billId);
    if (idx != -1) {
      final bill = _bills[idx];
      
      // 1. Create a transaction
      final txId = _uuid.v4();
      final tx = Transaction(
        id: txId,
        title: 'Pembayaran: ${bill.title}',
        amount: bill.amount,
        isExpense: true,
        categoryId: bill.categoryId,
        subCategory: bill.subCategory,
        walletId: walletId,
        date: paidDate,
        note: 'Dibayar dari menu Tagihan',
      );
      
      // 2. Add to transaction list and update wallet balance
      _transactions.insert(0, tx);
      await _saveTransactions();
      _updateWalletBalance(walletId, -bill.amount);
      await _saveWallets();

      // 3. Mark the bill as paid
      _bills[idx] = bill.copyWith(
        isPaid: true,
        paidDate: paidDate,
        paymentTransactionId: txId,
        walletId: walletId,
      );
      await _saveBills();
      notifyListeners();
    }
  }

  Future<void> deleteBill(String id) async {
    _bills.removeWhere((b) => b.id == id);
    await _saveBills();
    notifyListeners();
  }
}
