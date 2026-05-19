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
  static const String _prefCategoriesKey = 'nioney_categories';
  static const String _prefSubCategoriesKey = 'nioney_subcategories';

  final _uuid = const Uuid();

  List<Category> _categories = [];
  Map<String, List<String>> _subCategories = {};
  List<Wallet> _wallets = [];
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];

  ThemeMode _themeMode = ThemeMode.dark;
  String _currentPalette = 'Obsidian Mint';
  String _currencySymbol = 'Rp';

  // Getters
  List<Category> get categories => _categories;
  Map<String, List<String>> get subCategories => _subCategories;
  List<Wallet> get wallets => _wallets;
  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
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
      'color': c.color.value,
      'isExpense': c.isExpense,
    };
  }
}
