import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../main.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedTabIndex = 0;
  int _weeklyTouchedIndex = -1;
  int _monthlyTouchedIndex = -1;
  int _yearlyTouchedIndex = -1;

  // Weekly States
  DateTime _weeklyStartDate = _startOfWeek(DateTime.now());
  bool _weeklyIsExpense = true;
  bool _weeklyComparisonIsBarChart = true;
  String? _weeklyFilterCategoryId;
  int _weeklyTopLimit = 5;

  // Monthly States
  DateTime _monthlyStartDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  bool _monthlyIsExpense = true;
  bool _monthlyComparisonIsBarChart = true;
  String? _monthlyFilterCategoryId;
  int _monthlyTopLimit = 5;

  // Yearly States
  DateTime _yearlyStartDate = DateTime(DateTime.now().year, 1, 1);
  bool _yearlyIsExpense = true;
  bool _yearlyComparisonIsBarChart = true;
  String? _yearlyFilterCategoryId;
  final int _yearlyTopLimit = 5;

  static DateTime _startOfWeek(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: date.weekday - 1));
  }

  // --- Transactions Query Helpers ---

  List<Transaction> _getWeeklyTransactions(List<Transaction> allTxs) {
    final end = _weeklyStartDate.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
    return allTxs
        .where(
          (tx) =>
              tx.date.isAfter(
                _weeklyStartDate.subtract(const Duration(seconds: 1)),
              ) &&
              tx.date.isBefore(end) &&
              tx.categoryId != 'sys_saving_target',
        )
        .toList();
  }

  List<Transaction> _getMonthlyTransactions(List<Transaction> allTxs) {
    final end = DateTime(
      _monthlyStartDate.year,
      _monthlyStartDate.month + 1,
      0,
      23,
      59,
      59,
    );
    return allTxs
        .where(
          (tx) =>
              tx.date.isAfter(
                _monthlyStartDate.subtract(const Duration(seconds: 1)),
              ) &&
              tx.date.isBefore(end) &&
              tx.categoryId != 'sys_saving_target',
        )
        .toList();
  }

  List<Transaction> _getYearlyTransactions(List<Transaction> allTxs) {
    final end = DateTime(_yearlyStartDate.year, 12, 31, 23, 59, 59);
    return allTxs
        .where(
          (tx) =>
              tx.date.isAfter(
                _yearlyStartDate.subtract(const Duration(seconds: 1)),
              ) &&
              tx.date.isBefore(end) &&
              tx.categoryId != 'sys_saving_target',
        )
        .toList();
  }

  Map<Category, double> _getCategoryBreakdown(
    List<Transaction> txs,
    List<Category> categories,
    bool isExpense,
  ) {
    final Map<Category, double> breakdown = {};
    final filtered = txs.where((tx) => tx.isExpense == isExpense).toList();

    for (var tx in filtered) {
      final cat = categories.firstWhere(
        (c) => c.id == tx.categoryId,
        orElse: () => Category(
          id: tx.categoryId,
          name: tx.categoryId == 'sys_saving_target'
              ? 'Target Tabungan'
              : 'Lainnya',
          icon: tx.categoryId == 'sys_saving_target'
              ? Icons.track_changes_rounded
              : Icons.more_horiz_rounded,
          color: tx.categoryId == 'sys_saving_target'
              ? const Color(0xFF00D179)
              : Colors.grey,
          isExpense: isExpense,
        ),
      );
      breakdown[cat] = (breakdown[cat] ?? 0.0) + tx.amount;
    }
    return breakdown;
  }

  // --- Details Bottom Sheet ---

  void _showTransactionsBottomSheet(
    BuildContext context,
    String title,
    List<Transaction> txs,
    List<Wallet> wallets,
  ) {
    final isDarkVal = isDark(context);
    final mainTextColor = isDarkVal ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkVal
        ? Colors.white.withValues(alpha: 0.45)
        : const Color(0xFF64748B);
    final provider = Provider.of<AppProvider>(context, listen: false);
    final currency = provider.currencySymbol;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDarkVal ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkVal ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: mainTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: txs.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada transaksi',
                          style: TextStyle(color: subTextColor, fontSize: 13),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: txs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, idx) {
                          final tx = txs[idx];
                          final w = wallets.firstWhere(
                            (wallet) => wallet.id == tx.walletId,
                            orElse: () => Wallet(
                              id: '',
                              name: 'Dompet Terhapus',
                              balance: 0,
                              type: '',
                              color: Colors.grey,
                              icon: Icons.help_outline,
                            ),
                          );

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDarkVal
                                  ? Colors.white.withValues(alpha: 0.02)
                                  : Colors.black.withValues(alpha: 0.015),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkVal
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : Colors.black.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.title,
                                        style: TextStyle(
                                          color: mainTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${DateFormat('dd MMM yyyy').format(tx.date)} • ${w.name}',
                                        style: TextStyle(
                                          color: subTextColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${tx.isExpense ? "-" : "+"} ${AppLocale.formatCurrency(tx.amount, '$currency ')}',
                                  style: TextStyle(
                                    color: tx.isExpense
                                        ? Colors.redAccent
                                        : const Color(0xFF00D179),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomTabItem(
    int index,
    String title,
    bool isDarkVal,
    Color mainTextColor,
    Color subTextColor,
    ThemeData theme,
  ) {
    final isActive = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(
                    0xFF1E293B,
                  ) // Premium dark slate capsule for active
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : subTextColor,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isDarkVal = isDark(context);
    final mainTextColor = isDarkVal ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkVal
        ? Colors.white.withValues(alpha: 0.45)
        : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Statistik & Analisis',
          style: TextStyle(
            color: mainTextColor,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            fontFamily: 'Outfit',
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Custom Capsule Tab Switcher
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDarkVal
                      ? Colors.white.withValues(alpha: 0.02)
                      : Colors.black.withValues(alpha: 0.015),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDarkVal
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCustomTabItem(
                      0,
                      'Mingguan',
                      isDarkVal,
                      mainTextColor,
                      subTextColor,
                      theme,
                    ),
                    _buildCustomTabItem(
                      1,
                      'Bulanan',
                      isDarkVal,
                      mainTextColor,
                      subTextColor,
                      theme,
                    ),
                    _buildCustomTabItem(
                      2,
                      'Tahunan',
                      isDarkVal,
                      mainTextColor,
                      subTextColor,
                      theme,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  _buildWeeklyTab(
                    context,
                    provider,
                    isDarkVal,
                    mainTextColor,
                    subTextColor,
                    theme,
                  ),
                  _buildMonthlyTab(
                    context,
                    provider,
                    isDarkVal,
                    mainTextColor,
                    subTextColor,
                    theme,
                  ),
                  _buildYearlyTab(
                    context,
                    provider,
                    isDarkVal,
                    mainTextColor,
                    subTextColor,
                    theme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Yearly Tab Builder & Sub-widgets ---

  Widget _buildYearlyTab(
    BuildContext context,
    AppProvider provider,
    bool isDarkVal,
    Color mainTextColor,
    Color subTextColor,
    ThemeData theme,
  ) {
    final currency = provider.currencySymbol;
    final borderColor = isDarkVal
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.05);
    final cardBgColor = isDarkVal
        ? theme.cardColor.withValues(alpha: 0.3)
        : Colors.white;

    final yearlyTxs = _getYearlyTransactions(provider.transactions);
    final breakdown = _getCategoryBreakdown(
      yearlyTxs,
      provider.categories,
      _yearlyIsExpense,
    );
    final double totalAmount = breakdown.values.fold(
      0.0,
      (sum, val) => sum + val,
    );

    final isLeap =
        (_yearlyStartDate.year % 4 == 0) &&
        (_yearlyStartDate.year % 100 != 0 || _yearlyStartDate.year % 400 == 0);
    final daysInYear = isLeap ? 366 : 365;

    final double yearlyIn = yearlyTxs
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final double yearlyOut = yearlyTxs
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final double avgIn = yearlyIn / daysInYear;
    final double avgOut = yearlyOut / daysInYear;

    final Map<String, double> yearlyGroups = {};
    final filteredYearly = yearlyTxs.where((tx) {
      if (!tx.isExpense) return false;
      if (_yearlyFilterCategoryId != null &&
          tx.categoryId != _yearlyFilterCategoryId) {
        return false;
      }
      return true;
    }).toList();

    for (var tx in filteredYearly) {
      final key = '${tx.categoryId}|${tx.subCategory}';
      yearlyGroups[key] = (yearlyGroups[key] ?? 0.0) + tx.amount;
    }

    final List<GroupedExpense> finalTopGrouped = [];
    yearlyGroups.forEach((key, amt) {
      final parts = key.split('|');
      finalTopGrouped.add(
        GroupedExpense(
          categoryId: parts[0],
          subCategory: parts[1],
          amount: amt,
        ),
      );
    });

    finalTopGrouped.sort((a, b) => b.amount.compareTo(a.amount));
    final topLimit = _yearlyTopLimit == 5 ? 5 : 10;
    final yearlyTopExpenses = finalTopGrouped.take(topLimit).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Pagination
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: theme.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _yearlyStartDate = DateTime(
                        _yearlyStartDate.year - 1,
                        1,
                        1,
                      );
                    });
                  },
                ),
                Text(
                  '${_yearlyStartDate.year}',
                  style: TextStyle(
                    color: mainTextColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    fontFamily: 'Outfit',
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: theme.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _yearlyStartDate = DateTime(
                        _yearlyStartDate.year + 1,
                        1,
                        1,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Tab Pemasukan / Pengeluaran
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _yearlyIsExpense = true),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _yearlyIsExpense
                          ? Colors.redAccent.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _yearlyIsExpense
                            ? Colors.redAccent
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Pengeluaran',
                      style: TextStyle(
                        color: _yearlyIsExpense
                            ? Colors.redAccent
                            : subTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _yearlyIsExpense = false),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_yearlyIsExpense
                          ? const Color(0xFF00D179).withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: !_yearlyIsExpense
                            ? const Color(0xFF00D179)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Pemasukan',
                      style: TextStyle(
                        color: !_yearlyIsExpense
                            ? const Color(0xFF00D179)
                            : subTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Chart Donut
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROPORSI ${(_yearlyIsExpense ? "PENGELUARAN" : "PEMASUKAN").toUpperCase()}',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                if (breakdown.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'Tidak ada data transaksi',
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          height: 150,
                          child: Stack(
                            children: [
                              PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(
                                    touchCallback:
                                        (FlTouchEvent event, pieTouchResponse) {
                                          setState(() {
                                            if (!event
                                                    .isInterestedForInteractions ||
                                                pieTouchResponse == null ||
                                                pieTouchResponse
                                                        .touchedSection ==
                                                    null) {
                                              _yearlyTouchedIndex = -1;
                                              return;
                                            }
                                            _yearlyTouchedIndex =
                                                pieTouchResponse
                                                    .touchedSection!
                                                    .touchedSectionIndex;
                                          });
                                        },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 3,
                                  centerSpaceRadius: 45,
                                  sections: _buildYearlyPieSections(
                                    breakdown,
                                    totalAmount,
                                  ),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppLocale.formatCurrency(
                                        totalAmount,
                                        '$currency\n',
                                      ),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: mainTextColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'Outfit',
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: breakdown.entries.map((entry) {
                            final pct = (entry.value / totalAmount) * 100;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: entry.key.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      entry.key.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: mainTextColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${pct.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      color: subTextColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Card list of category details
          if (breakdown.isNotEmpty) ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: breakdown.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = breakdown.entries.elementAt(index);
                final cat = entry.key;
                final amt = entry.value;
                final pct = (amt / totalAmount) * 100;
                final catTxs = yearlyTxs
                    .where(
                      (tx) =>
                          tx.categoryId == cat.id &&
                          tx.isExpense == _yearlyIsExpense,
                    )
                    .toList();

                return GestureDetector(
                  onTap: () {
                    _showTransactionsBottomSheet(
                      context,
                      'Detail Kategori: ${cat.name}',
                      catTxs,
                      provider.wallets,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(cat.icon, color: cat.color, size: 14),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.name,
                                style: TextStyle(
                                  color: mainTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${catTxs.length} transaksi (${pct.toStringAsFixed(1)}%)',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          AppLocale.formatCurrency(
                            amt,
                            '${_yearlyIsExpense ? "-" : "+"} $currency ',
                          ),
                          style: TextStyle(
                            color: _yearlyIsExpense
                                ? Colors.redAccent
                                : const Color(0xFF00D179),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          // 5. Ringkasan Tahunan & Rata-rata bar chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RINGKASAN TAHUNAN',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'Pemasukan',
                      yearlyIn,
                      const Color(0xFF00D179),
                      currency,
                      mainTextColor,
                      subTextColor,
                    ),
                    _buildSummaryItem(
                      'Pengeluaran',
                      yearlyOut,
                      Colors.redAccent,
                      currency,
                      mainTextColor,
                      subTextColor,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'RATA-RATA HARIAN',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAverageLabel(
                              'IN',
                              avgIn,
                              const Color(0xFF00D179),
                              currency,
                              mainTextColor,
                              subTextColor,
                            ),
                            const SizedBox(height: 6),
                            _buildAverageLabel(
                              'OUT',
                              avgOut,
                              Colors.redAccent,
                              currency,
                              mainTextColor,
                              subTextColor,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: BarChart(
                          BarChartData(
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: avgIn,
                                    color: const Color(0xFF00D179),
                                    width: 14,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: avgOut,
                                    color: Colors.redAccent,
                                    width: 14,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, _) {
                                    switch (val.toInt()) {
                                      case 0:
                                        return Text(
                                          'IN',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: subTextColor,
                                          ),
                                        );
                                      case 1:
                                        return Text(
                                          'OUT',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: subTextColor,
                                          ),
                                        );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 6. Perbandingan Tahunan (Current vs Previous Year)
          _buildYearlyComparisonCard(
            context,
            provider,
            cardBgColor,
            borderColor,
            mainTextColor,
            subTextColor,
            theme,
          ),
          const SizedBox(height: 16),

          // 7. Tren Saldo Bersih Tahunan
          _buildYearlyNetTrendCard(
            context,
            provider,
            cardBgColor,
            borderColor,
            mainTextColor,
            subTextColor,
            theme,
            yearlyTxs,
          ),
          const SizedBox(height: 16),

          // 8. Rata-rata Harian Pengeluaran (Teks Pendek)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  color: Colors.redAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rata-rata Pengeluaran Harian',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocale.formatCurrency(avgOut, '$currency '),
                        style: TextStyle(
                          color: mainTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 9. Peta Aktivitas (Weekly Activity Heatmap)
          _buildYearlyActivityHeatmap(
            context,
            provider,
            cardBgColor,
            borderColor,
            mainTextColor,
            subTextColor,
            theme,
            yearlyTxs,
          ),
          const SizedBox(height: 16),

          // 10. Pengeluaran Terbesar Card & Filters
          _buildWeeklyTopExpensesCard(
            context,
            provider,
            cardBgColor,
            borderColor,
            mainTextColor,
            subTextColor,
            theme,
            yearlyTopExpenses,
          ),
          const SizedBox(height: 16),

          // 11. Log Transaksi Tahunan
          _buildWeeklyTransactionLogCard(
            context,
            provider,
            cardBgColor,
            borderColor,
            mainTextColor,
            subTextColor,
            theme,
            yearlyTxs,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildYearlyPieSections(
    Map<Category, double> breakdown,
    double total,
  ) {
    final List<PieChartSectionData> sections = [];
    int i = 0;
    final sortedBreakdown = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedBreakdown) {
      final cat = entry.key;
      final val = entry.value;
      final isTouched = i == _yearlyTouchedIndex;
      final double radius = isTouched ? 20.0 : 15.0;

      sections.add(
        PieChartSectionData(
          color: cat.color,
          value: val,
          radius: radius,
          showTitle: false,
          badgeWidget: isTouched
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: cat.color, width: 1),
                  ),
                  child: Text(
                    '${((val / total) * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: cat.color,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          badgePositionPercentageOffset: 0.98,
        ),
      );
      i++;
    }
    return sections;
  }

  Widget _buildYearlyComparisonCard(
    BuildContext context,
    AppProvider provider,
    Color cardBg,
    Color borderCol,
    Color mainTextColor,
    Color subTextColor,
    ThemeData theme,
  ) {
    final currentTxs = _getYearlyTransactions(provider.transactions);
    final prevYearStartDate = DateTime(_yearlyStartDate.year - 1, 1, 1);
    final prevYearEndDate = DateTime(
      _yearlyStartDate.year - 1,
      12,
      31,
      23,
      59,
      59,
    );
    final prevTxs = provider.transactions
        .where(
          (tx) =>
              tx.date.isAfter(
                prevYearStartDate.subtract(const Duration(seconds: 1)),
              ) &&
              tx.date.isBefore(prevYearEndDate) &&
              tx.categoryId != 'sys_saving_target',
        )
        .toList();

    List<double> currentMonths = List.filled(12, 0.0);
    List<double> prevMonths = List.filled(12, 0.0);

    for (var tx in currentTxs) {
      if (tx.isExpense == _yearlyIsExpense) {
        int mIdx = tx.date.month - 1;
        if (mIdx >= 0 && mIdx < 12) {
          currentMonths[mIdx] += tx.amount;
        }
      }
    }
    for (var tx in prevTxs) {
      if (tx.isExpense == _yearlyIsExpense) {
        int mIdx = tx.date.month - 1;
        if (mIdx >= 0 && mIdx < 12) {
          prevMonths[mIdx] += tx.amount;
        }
      }
    }

    final double maxVal = [
      ...currentMonths,
      ...prevMonths,
    ].fold(0.0, (max, val) => val > max ? val : max);
    final double chartMax = maxVal > 0 ? maxVal * 1.15 : 100000.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PERBANDINGAN TAHUNAN',
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.bar_chart_rounded,
                      color: _yearlyComparisonIsBarChart
                          ? theme.primaryColor
                          : subTextColor,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _yearlyComparisonIsBarChart = true),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.show_chart_rounded,
                      color: !_yearlyComparisonIsBarChart
                          ? theme.primaryColor
                          : subTextColor,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _yearlyComparisonIsBarChart = false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tahun ini vs Tahun lalu',
            style: TextStyle(color: subTextColor, fontSize: 10),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: _yearlyComparisonIsBarChart
                ? BarChart(
                    BarChartData(
                      maxY: chartMax,
                      barGroups: List.generate(12, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: currentMonths[i],
                              color: theme.primaryColor,
                              width: 6,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            BarChartRodData(
                              toY: prevMonths[i],
                              color: subTextColor.withValues(alpha: 0.25),
                              width: 6,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ],
                        );
                      }),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, _) {
                              final months = [
                                'J',
                                'F',
                                'M',
                                'A',
                                'M',
                                'J',
                                'J',
                                'A',
                                'S',
                                'O',
                                'N',
                                'D',
                              ];
                              int idx = val.toInt();
                              if (idx >= 0 && idx < 12) {
                                return Text(
                                  months[idx],
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: subTextColor,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      maxY: chartMax,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            12,
                            (i) => FlSpot(i.toDouble(), currentMonths[i]),
                          ),
                          isCurved: true,
                          color: theme.primaryColor,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: List.generate(
                            12,
                            (i) => FlSpot(i.toDouble(), prevMonths[i]),
                          ),
                          isCurved: true,
                          color: subTextColor.withValues(alpha: 0.25),
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, _) {
                              final months = [
                                'J',
                                'F',
                                'M',
                                'A',
                                'M',
                                'J',
                                'J',
                                'A',
                                'S',
                                'O',
                                'N',
                                'D',
                              ];
                              int idx = val.toInt();
                              if (idx >= 0 && idx < 12) {
                                return Text(
                                  months[idx],
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: subTextColor,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyNetTrendCard(
    BuildContext context,
    AppProvider provider,
    Color cardBg,
    Color borderCol,
    Color mainTextColor,
    Color subTextColor,
    ThemeData theme,
    List<Transaction> yearlyTxs,
  ) {
    List<double> monthlyNet = List.filled(12, 0.0);

    for (var tx in yearlyTxs) {
      int mIdx = tx.date.month - 1;
      if (mIdx >= 0 && mIdx < 12) {
        monthlyNet[mIdx] += tx.isExpense ? -tx.amount : tx.amount;
      }
    }

    List<double> cumulativeNet = List.filled(12, 0.0);
    double running = 0.0;
    for (int i = 0; i < 12; i++) {
      running += monthlyNet[i];
      cumulativeNet[i] = running;
    }

    final double minVal = cumulativeNet.fold(
      0.0,
      (min, val) => val < min ? val : min,
    );
    final double maxVal = cumulativeNet.fold(
      0.0,
      (max, val) => val > max ? val : max,
    );
    final double chartMax = maxVal > 0 ? maxVal * 1.15 : 50000.0;
    final double chartMin = minVal < 0 ? minVal * 1.15 : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TREN SALDO BERSIH KUALITATIF',
            style: TextStyle(
              color: subTextColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Akumulasi pertumbuhan saldo tahun ini',
            style: TextStyle(color: subTextColor, fontSize: 10),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                minY: chartMin,
                maxY: chartMax,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      12,
                      (i) => FlSpot(i.toDouble() + 1, cumulativeNet[i]),
                    ),
                    isCurved: true,
                    color: const Color(0xFF00D179),
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF00D179).withValues(alpha: 0.1),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        final months = [
                          'J',
                          'F',
                          'M',
                          'A',
                          'M',
                          'J',
                          'J',
                          'A',
                          'S',
                          'O',
                          'N',
                          'D',
                        ];
                        int idx = val.toInt() - 1;
                        if (idx >= 0 && idx < 12) {
                          return Text(
                            months[idx],
                            style: TextStyle(fontSize: 8, color: subTextColor),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyActivityHeatmap(
    BuildContext context,
    AppProvider provider,
    Color cardBg,
    Color borderCol,
    Color mainTextColor,
    Color subTextColor,
    ThemeData theme,
    List<Transaction> yearlyTxs,
  ) {
    final List<Widget> gridCells = [];

    for (int w = 1; w <= 52; w++) {
      final DateTime wkStart = DateTime(
        _yearlyStartDate.year,
        1,
        1,
      ).add(Duration(days: (w - 1) * 7));
      final DateTime wkEnd = wkStart.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );

      final wTxs = yearlyTxs
          .where(
            (tx) =>
                tx.date.isAfter(wkStart.subtract(const Duration(seconds: 1))) &&
                tx.date.isBefore(wkEnd) &&
                tx.isExpense,
          )
          .toList();
      final expenseCount = wTxs.length;

      Color cellColor = Colors.transparent;
      Color textCol = mainTextColor;

      if (expenseCount > 0) {
        if (expenseCount <= 3) {
          cellColor = theme.primaryColor.withValues(alpha: 0.12);
        } else {
          cellColor = theme.primaryColor;
          textCol = Colors.white;
        }
      }

      gridCells.add(
        GestureDetector(
          onTap: () {
            final String formattedRange =
                "${DateFormat('dd MMM').format(wkStart)} - ${DateFormat('dd MMM yyyy').format(wkEnd)}";
            _showTransactionsBottomSheet(
              context,
              'Minggu $w ($formattedRange)',
              wTxs,
              provider.wallets,
            );
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: cellColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderCol),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'W$w',
                  style: TextStyle(
                    color: textCol,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (expenseCount > 0)
                  Text(
                    '$expenseCount tx',
                    style: TextStyle(
                      color: textCol.withValues(alpha: 0.7),
                      fontSize: 6,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PETA AKTIVITAS TAHUN INI',
            style: TextStyle(
              color: subTextColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Frekuensi transaksi pengeluaran mingguan',
            style: TextStyle(color: subTextColor, fontSize: 10),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            children: gridCells,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Sedikit',
                style: TextStyle(color: subTextColor, fontSize: 8),
              ),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Banyak',
                style: TextStyle(color: subTextColor, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Weekly Tab Builder ---

  Widget _buildWeeklyTab(
    BuildContext context,
    AppProvider provider,
    bool isDarkVal,
    Color mainTextColor,
    Color subTextColor,
    ThemeData theme,
  ) {
    final currency = provider.currencySymbol;
    final borderColor = isDarkVal
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.05);
    final cardBgColor = isDarkVal
        ? theme.cardColor.withValues(alpha: 0.3)
        : Colors.white;

    final weeklyTxs = _getWeeklyTransactions(provider.transactions);
    final breakdown = _getCategoryBreakdown(
      weeklyTxs,
      provider.categories,
      _weeklyIsExpense,
    );
    final double totalAmount = breakdown.values.fold(
      0.0,
      (sum, val) => sum + val,
    );

    final endOfWeek = _weeklyStartDate.add(const Duration(days: 6));

    // Averages and summaries
    final double weeklyIn = weeklyTxs
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final double weeklyOut = weeklyTxs
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final double avgIn = weeklyIn / 7;
    final double avgOut = weeklyOut / 7;

    // Filter & Group Top Expenses
    final Map<String, double> weeklyGroups = {};
    final filteredWeekly = weeklyTxs.where((tx) {
      if (!tx.isExpense) return false;
      if (_weeklyFilterCategoryId != null &&
          tx.categoryId != _weeklyFilterCategoryId) {
        return false;
      }
      return true;
    }).toList();

    for (var tx in filteredWeekly) {
      final key = '${tx.categoryId}|${tx.subCategory}';
      weeklyGroups[key] = (weeklyGroups[key] ?? 0.0) + tx.amount;
    }

    final List<GroupedExpense> finalTopGrouped = [];
    weeklyGroups.forEach((key, amt) {
      final parts = key.split('|');
      finalTopGrouped.add(
        GroupedExpense(
          categoryId: parts[0],
          subCategory: parts[1],
          amount: amt,
        ),
      );
    });

    finalTopGrouped.sort((a, b) => b.amount.compareTo(a.amount));
    final topLimit = _weeklyTopLimit == 5 ? 5 : 10;
    final weeklyTopExpenses = finalTopGrouped.take(topLimit).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Pagination
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: theme.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _weeklyStartDate = _weeklyStartDate.subtract(
                        const Duration(days: 7),
                      );
                    });
                  },
                ),
                Text(
                  '${DateFormat('dd MMM').format(_weeklyStartDate)} - ${DateFormat('dd MMM yyyy').format(endOfWeek)}',
                  style: TextStyle(
                    color: mainTextColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    fontFamily: 'Outfit',
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: theme.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _weeklyStartDate = _weeklyStartDate.add(
                        const Duration(days: 7),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Tab Pemasukan / Pengeluaran
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _weeklyIsExpense = true),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _weeklyIsExpense
                          ? Colors.redAccent.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _weeklyIsExpense
                            ? Colors.redAccent
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Pengeluaran',
                      style: TextStyle(
                        color: _weeklyIsExpense
                            ? Colors.redAccent
                            : subTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _weeklyIsExpense = false),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_weeklyIsExpense
                          ? const Color(0xFF00D179).withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: !_weeklyIsExpense
                            ? const Color(0xFF00D179)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Pemasukan',
                      style: TextStyle(
                        color: !_weeklyIsExpense
                            ? const Color(0xFF00D179)
                            : subTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Chart Donut
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROPORSI ${(_weeklyIsExpense ? "PENGELUARAN" : "PEMASUKAN").toUpperCase()}',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                if (breakdown.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'Tidak ada data transaksi',
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          height: 150,
                          child: Stack(
                            children: [
                              PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(
                                    touchCallback:
                                        (FlTouchEvent event, pieTouchResponse) {
                                          setState(() {
                                            if (!event
                                                    .isInterestedForInteractions ||
                                                pieTouchResponse == null ||
                                                pieTouchResponse
                                                        .touchedSection ==
                                                    null) {
                                              _weeklyTouchedIndex = -1;
                                              return;
                                            }
                                            _weeklyTouchedIndex =
                                                pieTouchResponse
                                                    .touchedSection!
                                                    .touchedSectionIndex;
                                          });
                                        },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 3,
                                  centerSpaceRadius: 45,
                                  sections: _buildWeeklyPieSections(
                                    breakdown,
                                    totalAmount,
                                  ),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      AppLocale.formatCurrency(
                                        totalAmount,
                                        '$currency ',
                                      ),
                                      style: TextStyle(
                                        color: mainTextColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: breakdown.entries.map((entry) {
                              final percent = totalAmount > 0
                                  ? (entry.value / totalAmount) * 100
                                  : 0.0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3.0,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: entry.key.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        entry.key.name,
                                        style: TextStyle(
                                          color: mainTextColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${percent.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Card list of category breakdown
          if (breakdown.isNotEmpty) ...[
            Text(
              'Daftar Kategori',
              style: TextStyle(
                color: mainTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: breakdown.length,
              itemBuilder: (context, index) {
                final sortedList = breakdown.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final entry = sortedList[index];
                final cat = entry.key;
                final amt = entry.value;
                final percent = totalAmount > 0 ? (amt / totalAmount) : 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        final catTxs = weeklyTxs
                            .where(
                              (tx) =>
                                  tx.categoryId == cat.id &&
                                  tx.isExpense == _weeklyIsExpense,
                            )
                            .toList();
                        _showTransactionsBottomSheet(
                          context,
                          'Detail Kategori: ${cat.name}',
                          catTxs,
                          provider.wallets,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: cat.color.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    cat.icon,
                                    color: cat.color,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cat.name,
                                        style: TextStyle(
                                          color: mainTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '${(percent * 100).toStringAsFixed(1)}% dari total',
                                        style: TextStyle(
                                          color: subTextColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  AppLocale.formatCurrency(amt, '$currency '),
                                  style: TextStyle(
                                    color: mainTextColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percent,
                                backgroundColor: isDarkVal
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : Colors.black.withValues(alpha: 0.04),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  cat.color,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],

          // 5. Ringkasan Mingguan & Rata-rata bar chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RINGKASAN MINGGUAN',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'Pemasukan',
                      weeklyIn,
                      const Color(0xFF00D179),
                      currency,
                      mainTextColor,
                      subTextColor,
                    ),
                    _buildSummaryItem(
                      'Pengeluaran',
                      weeklyOut,
                      Colors.redAccent,
                      currency,
                      mainTextColor,
                      subTextColor,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'RATA-RATA HARIAN',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAverageLabel(
                              'IN',
                              avgIn,
                              const Color(0xFF00D179),
                              currency,
                              mainTextColor,
                              subTextColor,
                            ),
                            const SizedBox(height: 6),
                            _buildAverageLabel(
                              'OUT',
                              avgOut,
                              Colors.redAccent,
                              currency,
                              mainTextColor,
                              subTextColor,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: BarChart(
                          BarChartData(
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: avgIn,
                                    color: const Color(0xFF00D179),
                                    width: 14,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: avgOut,
                                    color: Colors.redAccent,
                                    width: 14,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, _) {
                                    switch (val.toInt()) {
                                      case 0:
                                        return Text(
                                          'IN',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: subTextColor,
                                          ),
                                        );
                                      case 1:
                                        return Text(
                                          'OUT',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: subTextColor,
                                          ),
                                        );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 6. Perbandingan Mingguan (Current vs Previous Week)
          _buildWeeklyComparisonCard(
            context,
            provider,
            cardBgColor,
            borderColor,
            mainTextColor,
            subTextColor,
            theme,
          ),
          const SizedBox(height: 16),

          // 7. Pengeluaran Terbesar Card & Filters
          _buildWeeklyTopExpensesCard(
            context,
            provider,
            cardBgColor,
            borderColor,
            mainTextColor,
            subTextColor,
            theme,
            weeklyTopExpenses,
          ),
          const SizedBox(height: 16),

          // 8. Log Transaksi Mingguan
          _buildWeeklyTransactionLogCard(
            context,
            provider,
            cardBgColor,
            borderColor,
            mainTextColor,
            subTextColor,
            theme,
            weeklyTxs,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- Monthly Tab Builder ---

  Widget _buildMonthlyTab(
    BuildContext context,
    AppProvider provider,
    bool isDarkVal,
    Color mainTextColor,
    Color subTextColor,
    ThemeData theme,
  ) {
    final currency = provider.currencySymbol;
    final borderColor = isDarkVal
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.05);
    final cardBgColor = isDarkVal
        ? theme.cardColor.withValues(alpha: 0.3)
        : Colors.white;

    final monthlyTxs = _getMonthlyTransactions(provider.transactions);
    final breakdown = _getCategoryBreakdown(
      monthlyTxs,
      provider.categories,
      _monthlyIsExpense,
    );
    final double totalAmount = breakdown.values.fold(
      0.0,
      (sum, val) => sum + val,
    );

    final daysInMonth = DateTime(
      _monthlyStartDate.year,
      _monthlyStartDate.month + 1,
      0,
    ).day;

    // Monthly Averages
    final double monthlyIn = monthlyTxs
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final double monthlyOut = monthlyTxs
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final double avgIn = monthlyIn / daysInMonth;
    final double avgOut = monthlyOut / daysInMonth;

    // Filter & Group Top Expenses
    final Map<String, double> monthlyGroups = {};
    final filteredMonthly = monthlyTxs.where((tx) {
      if (!tx.isExpense) return false;
      if (_monthlyFilterCategoryId != null &&
          tx.categoryId != _monthlyFilterCategoryId) {
        return false;
      }
      return true;
    }).toList();

    for (var tx in filteredMonthly) {
      final key = '${tx.categoryId}|${tx.subCategory}';
      monthlyGroups[key] = (monthlyGroups[key] ?? 0.0) + tx.amount;
    }

    final List<GroupedExpense> finalTopGrouped = [];
    monthlyGroups.forEach((key, amt) {
      final parts = key.split('|');
      finalTopGrouped.add(
        GroupedExpense(
          categoryId: parts[0],
          subCategory: parts[1],
          amount: amt,
        ),
      );
    });

    finalTopGrouped.sort((a, b) => b.amount.compareTo(a.amount));
    final topLimit = _monthlyTopLimit == 5 ? 5 : 10;
    final monthlyTopExpenses = finalTopGrouped.take(topLimit).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Pagination
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: theme.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _monthlyStartDate = DateTime(
                        _monthlyStartDate.year,
                        _monthlyStartDate.month - 1,
                        1,
                      );
                    });
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_monthlyStartDate),
                  style: TextStyle(
                    color: mainTextColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    fontFamily: 'Outfit',
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: theme.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _monthlyStartDate = DateTime(
                        _monthlyStartDate.year,
                        _monthlyStartDate.month + 1,
                        1,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Tab Pemasukan / Pengeluaran
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _monthlyIsExpense = true),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _monthlyIsExpense
                          ? Colors.redAccent.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _monthlyIsExpense
                            ? Colors.redAccent
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Pengeluaran',
                      style: TextStyle(
                        color: _monthlyIsExpense
                            ? Colors.redAccent
                            : subTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _monthlyIsExpense = false),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_monthlyIsExpense
                          ? const Color(0xFF00D179).withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: !_monthlyIsExpense
                            ? const Color(0xFF00D179)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Pemasukan',
                      style: TextStyle(
                        color: !_monthlyIsExpense
                            ? const Color(0xFF00D179)
                            : subTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Chart Donut
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROPORSI ${(_monthlyIsExpense ? "PENGELUARAN" : "PEMASUKAN").toUpperCase()}',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                if (breakdown.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'Tidak ada data transaksi',
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          height: 150,
                          child: Stack(
                            children: [
                              PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(
                                    touchCallback:
                                        (FlTouchEvent event, pieTouchResponse) {
                                          setState(() {
                                            if (!event
                                                    .isInterestedForInteractions ||
                                                pieTouchResponse == null ||
                                                pieTouchResponse
                                                        .touchedSection ==
                                                    null) {
                                              _monthlyTouchedIndex = -1;
                                              return;
                                            }
                                            _monthlyTouchedIndex =
                                                pieTouchResponse
                                                    .touchedSection!
                                                    .touchedSectionIndex;
                                          });
                                        },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 3,
                                  centerSpaceRadius: 45,
                                  sections: _buildMonthlyPieSections(
                                    breakdown,
                                    totalAmount,
                                  ),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      AppLocale.formatCurrency(
                                        totalAmount,
                                        '$currency ',
                                      ),
                                      style: TextStyle(
                                        color: mainTextColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: breakdown.entries.map((entry) {
                              final percent = totalAmount > 0
                                  ? (entry.value / totalAmount) * 100
                                  : 0.0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3.0,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: entry.key.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        entry.key.name,
                                        style: TextStyle(
                                          color: mainTextColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${percent.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Card list of category breakdown
          if (breakdown.isNotEmpty) ...[
            Text(
              'Daftar Kategori',
              style: TextStyle(
                color: mainTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: breakdown.length,
              itemBuilder: (context, index) {
                final sortedList = breakdown.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final entry = sortedList[index];
                final cat = entry.key;
                final amt = entry.value;
                final percent = totalAmount > 0 ? (amt / totalAmount) : 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        final catTxs = monthlyTxs
                            .where(
                              (tx) =>
                                  tx.categoryId == cat.id &&
                                  tx.isExpense == _monthlyIsExpense,
                            )
                            .toList();
                        _showTransactionsBottomSheet(
                          context,
                          'Detail Kategori: ${cat.name}',
                          catTxs,
                          provider.wallets,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: cat.color.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    cat.icon,
                                    color: cat.color,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cat.name,
                                        style: TextStyle(
                                          color: mainTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '${(percent * 100).toStringAsFixed(1)}% dari total',
                                        style: TextStyle(
                                          color: subTextColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  AppLocale.formatCurrency(amt, '$currency '),
                                  style: TextStyle(
                                    color: mainTextColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percent,
                                backgroundColor: isDarkVal
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : Colors.black.withValues(alpha: 0.04),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  cat.color,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],

          // 5. Ringkasan Bulanan & Rata-rata bar chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RINGKASAN BULANAN',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'Pemasukan',
                      monthlyIn,
                      const Color(0xFF00D179),
                      currency,
                      mainTextColor,
                      subTextColor,
                    ),
                    _buildSummaryItem(
                      'Pengeluaran',
                      monthlyOut,
                      Colors.redAccent,
                      currency,
                      mainTextColor,
                      subTextColor,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'RATA-RATA HARIAN',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAverageLabel(
                              'IN',
                              avgIn,
                              const Color(0xFF00D179),
                              currency,
                              mainTextColor,
                              subTextColor,
                            ),
                            const SizedBox(height: 6),
                            _buildAverageLabel(
                              'OUT',
                              avgOut,
                              Colors.redAccent,
                              currency,
                              mainTextColor,
                              subTextColor,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: BarChart(
                          BarChartData(
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: avgIn,
                                    color: const Color(0xFF00D179),
                                    width: 14,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: avgOut,
                                    color: Colors.redAccent,
                                    width: 14,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, _) {
                                    switch (val.toInt()) {
                                      case 0:
                                        return Text(
                                          'IN',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: subTextColor,
                                          ),
                                        );
                                      case 1:
                                        return Text(
                                          'OUT',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: subTextColor,
                                          ),
                                        );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 6. Perbandingan Bulanan (Current vs Previous Month)
          _buildMonthlyComparisonCard(
            context,
            provider,
            cardBgColor,
            borderColor,
            mainTextColor,
            subTextColor,
            theme,
          ),
          const SizedBox(height: 16),

          // 7. Tren Saldo Bersih
          _buildMonthlyNetTrendCard(
            context,
            provider,
            cardBgColor,
            borderColor,
            mainTextColor,
            subTextColor,
            theme,
            monthlyTxs,
            daysInMonth,
          ),
          const SizedBox(height: 16),

          // 8. Rata-rata Harian Pengeluaran (Teks Pendek)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  color: Colors.redAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rata-rata Pengeluaran Harian',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocale.formatCurrency(avgOut, '$currency '),
                        style: TextStyle(
                          color: mainTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 9. Peta Aktivitas (Activity Heatmap format Kalender)
          _buildMonthlyActivityHeatmap(
            context,
            provider,
            cardBgColor,
            borderColor,
            mainTextColor,
            subTextColor,
            theme,
            monthlyTxs,
          ),
          const SizedBox(height: 16),

          // 10. Pengeluaran Terbesar Card & Filters
          _buildMonthlyTopExpensesCard(
            context,
            provider,
            cardBgColor,
            borderColor,
            mainTextColor,
            subTextColor,
            theme,
            monthlyTopExpenses,
          ),
          const SizedBox(height: 16),

          // 11. Log Transaksi Bulanan
          _buildMonthlyTransactionLogCard(
            context,
            provider,
            cardBgColor,
            borderColor,
            mainTextColor,
            subTextColor,
            theme,
            monthlyTxs,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- Sub-widgets & Shared Chart Renderers ---

  Widget _buildSummaryItem(
    String label,
    double amount,
    Color color,
    String currency,
    Color mainTextColor,
    Color subTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: subTextColor,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          AppLocale.formatCurrency(amount, '$currency '),
          style: TextStyle(
            color: mainTextColor,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }

  Widget _buildAverageLabel(
    String label,
    double amount,
    Color color,
    String currency,
    Color mainTextColor,
    Color subTextColor,
  ) {
    return Row(
      children: [
        Container(
          width: 24,
          padding: const EdgeInsets.symmetric(vertical: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          AppLocale.formatCurrency(amount, '$currency '),
          style: TextStyle(
            color: mainTextColor,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }

  // --- Weekly Comparison Chart ---

  Widget _buildWeeklyComparisonCard(
    BuildContext context,
    AppProvider provider,
    Color cardBg,
    Color borderCol,
    Color mainTextColor,
    Color subTextColor,
    ThemeData theme,
  ) {
    final currentTxs = _getWeeklyTransactions(provider.transactions);
    final prevStartDate = _weeklyStartDate.subtract(const Duration(days: 7));
    final prevEndDate = prevStartDate.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
    final prevTxs = provider.transactions
        .where(
          (tx) =>
              tx.date.isAfter(
                prevStartDate.subtract(const Duration(seconds: 1)),
              ) &&
              tx.date.isBefore(prevEndDate),
        )
        .toList();

    List<double> currentValues = List.filled(7, 0.0);
    List<double> prevValues = List.filled(7, 0.0);

    for (var tx in currentTxs) {
      if (tx.isExpense == _weeklyIsExpense) {
        currentValues[tx.date.weekday - 1] += tx.amount;
      }
    }
    for (var tx in prevTxs) {
      if (tx.isExpense == _weeklyIsExpense) {
        prevValues[tx.date.weekday - 1] += tx.amount;
      }
    }

    final double maxVal = [
      ...currentValues,
      ...prevValues,
    ].fold(0.0, (max, val) => val > max ? val : max);
    final double chartMax = maxVal > 0 ? maxVal * 1.15 : 100000.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PERBANDINGAN MINGGUAN',
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.bar_chart_rounded,
                      color: _weeklyComparisonIsBarChart
                          ? theme.primaryColor
                          : subTextColor,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _weeklyComparisonIsBarChart = true),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.show_chart_rounded,
                      color: !_weeklyComparisonIsBarChart
                          ? theme.primaryColor
                          : subTextColor,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _weeklyComparisonIsBarChart = false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Minggu ini vs Minggu lalu',
            style: TextStyle(color: subTextColor, fontSize: 10),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: _weeklyComparisonIsBarChart
                ? BarChart(
                    BarChartData(
                      maxY: chartMax,
                      barGroups: List.generate(7, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: currentValues[i],
                              color: theme.primaryColor,
                              width: 6,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            BarChartRodData(
                              toY: prevValues[i],
                              color: subTextColor.withValues(alpha: 0.25),
                              width: 6,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ],
                        );
                      }),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, _) {
                              switch (val.toInt()) {
                                case 0:
                                  return Text(
                                    'Sen',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 1:
                                  return Text(
                                    'Sel',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 2:
                                  return Text(
                                    'Rab',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 3:
                                  return Text(
                                    'Kam',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 4:
                                  return Text(
                                    'Jum',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 5:
                                  return Text(
                                    'Sab',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 6:
                                  return Text(
                                    'Min',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      maxY: chartMax,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            7,
                            (i) => FlSpot(i.toDouble(), currentValues[i]),
                          ),
                          isCurved: true,
                          color: theme.primaryColor,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: List.generate(
                            7,
                            (i) => FlSpot(i.toDouble(), prevValues[i]),
                          ),
                          isCurved: true,
                          color: subTextColor.withValues(alpha: 0.35),
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          dashArray: [4, 4],
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, _) {
                              switch (val.toInt()) {
                                case 0:
                                  return Text(
                                    'Sen',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 1:
                                  return Text(
                                    'Sel',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 2:
                                  return Text(
                                    'Rab',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 3:
                                  return Text(
                                    'Kam',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 4:
                                  return Text(
                                    'Jum',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 5:
                                  return Text(
                                    'Sab',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 6:
                                  return Text(
                                    'Min',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Minggu Ini',
                style: TextStyle(
                  color: mainTextColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: subTextColor.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Minggu Lalu',
                style: TextStyle(color: subTextColor, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Monthly Comparison Chart ---

  Widget _buildMonthlyComparisonCard(
    BuildContext context,
    AppProvider provider,
    Color cardBg,
    Color borderCol,
    Color mainTextColor,
    Color subTextColor,
    ThemeData theme,
  ) {
    final currentTxs = _getMonthlyTransactions(provider.transactions);
    final prevMonthDate = DateTime(
      _monthlyStartDate.year,
      _monthlyStartDate.month - 1,
      1,
    );
    final prevMonthEndDate = DateTime(
      _monthlyStartDate.year,
      _monthlyStartDate.month,
      0,
      23,
      59,
      59,
    );
    final prevTxs = provider.transactions
        .where(
          (tx) =>
              tx.date.isAfter(
                prevMonthDate.subtract(const Duration(seconds: 1)),
              ) &&
              tx.date.isBefore(prevMonthEndDate),
        )
        .toList();

    List<double> currentWeeks = List.filled(5, 0.0);
    List<double> prevWeeks = List.filled(5, 0.0);

    for (var tx in currentTxs) {
      if (tx.isExpense == _monthlyIsExpense) {
        int day = tx.date.day;
        int wk = day <= 7
            ? 0
            : day <= 14
            ? 1
            : day <= 21
            ? 2
            : day <= 28
            ? 3
            : 4;
        currentWeeks[wk] += tx.amount;
      }
    }
    for (var tx in prevTxs) {
      if (tx.isExpense == _monthlyIsExpense) {
        int day = tx.date.day;
        int wk = day <= 7
            ? 0
            : day <= 14
            ? 1
            : day <= 21
            ? 2
            : day <= 28
            ? 3
            : 4;
        prevWeeks[wk] += tx.amount;
      }
    }

    final double maxVal = [
      ...currentWeeks,
      ...prevWeeks,
    ].fold(0.0, (max, val) => val > max ? val : max);
    final double chartMax = maxVal > 0 ? maxVal * 1.15 : 100000.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PERBANDINGAN BULANAN',
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.bar_chart_rounded,
                      color: _monthlyComparisonIsBarChart
                          ? theme.primaryColor
                          : subTextColor,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _monthlyComparisonIsBarChart = true),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.show_chart_rounded,
                      color: !_monthlyComparisonIsBarChart
                          ? theme.primaryColor
                          : subTextColor,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _monthlyComparisonIsBarChart = false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Bulan ini vs Bulan lalu',
            style: TextStyle(color: subTextColor, fontSize: 10),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: _monthlyComparisonIsBarChart
                ? BarChart(
                    BarChartData(
                      maxY: chartMax,
                      barGroups: List.generate(5, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: currentWeeks[i],
                              color: theme.primaryColor,
                              width: 8,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            BarChartRodData(
                              toY: prevWeeks[i],
                              color: subTextColor.withValues(alpha: 0.25),
                              width: 8,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ],
                        );
                      }),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, _) {
                              switch (val.toInt()) {
                                case 0:
                                  return Text(
                                    'M1',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 1:
                                  return Text(
                                    'M2',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 2:
                                  return Text(
                                    'M3',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 3:
                                  return Text(
                                    'M4',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 4:
                                  return Text(
                                    'M5',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      maxY: chartMax,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            5,
                            (i) => FlSpot(i.toDouble(), currentWeeks[i]),
                          ),
                          isCurved: true,
                          color: theme.primaryColor,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: List.generate(
                            5,
                            (i) => FlSpot(i.toDouble(), prevWeeks[i]),
                          ),
                          isCurved: true,
                          color: subTextColor.withValues(alpha: 0.35),
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          dashArray: [4, 4],
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, _) {
                              switch (val.toInt()) {
                                case 0:
                                  return Text(
                                    'Minggu 1',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 1:
                                  return Text(
                                    'Minggu 2',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 2:
                                  return Text(
                                    'Minggu 3',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 3:
                                  return Text(
                                    'Minggu 4',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                                case 4:
                                  return Text(
                                    'Minggu 5',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: subTextColor,
                                    ),
                                  );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Bulan Ini',
                style: TextStyle(
                  color: mainTextColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: subTextColor.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Bulan Lalu',
                style: TextStyle(color: subTextColor, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Monthly Net Balance Trend Line ---

  Widget _buildMonthlyNetTrendCard(
    BuildContext context,
    AppProvider provider,
    Color cardBg,
    Color borderCol,
    Color mainTextColor,
    Color subTextColor,
    ThemeData theme,
    List<Transaction> monthlyTxs,
    int daysInMonth,
  ) {
    List<double> dailyNet = List.filled(daysInMonth, 0.0);

    for (var tx in monthlyTxs) {
      int dayIdx = tx.date.day - 1;
      if (dayIdx >= 0 && dayIdx < daysInMonth) {
        dailyNet[dayIdx] += tx.isExpense ? -tx.amount : tx.amount;
      }
    }

    List<double> cumulativeNet = List.filled(daysInMonth, 0.0);
    double running = 0.0;
    for (int i = 0; i < daysInMonth; i++) {
      running += dailyNet[i];
      cumulativeNet[i] = running;
    }

    final double minVal = cumulativeNet.fold(
      0.0,
      (min, val) => val < min ? val : min,
    );
    final double maxVal = cumulativeNet.fold(
      0.0,
      (max, val) => val > max ? val : max,
    );
    final double chartMax = maxVal > 0 ? maxVal * 1.15 : 50000.0;
    final double chartMin = minVal < 0 ? minVal * 1.15 : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TREN SALDO BERSIH KUALITATIF',
            style: TextStyle(
              color: subTextColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Akumulasi pertumbuhan saldo bulan ini',
            style: TextStyle(color: subTextColor, fontSize: 10),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                minY: chartMin,
                maxY: chartMax,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      daysInMonth,
                      (i) => FlSpot(i.toDouble() + 1, cumulativeNet[i]),
                    ),
                    isCurved: true,
                    color: const Color(0xFF00D179),
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF00D179).withValues(alpha: 0.1),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (daysInMonth / 4).round().toDouble(),
                      getTitlesWidget: (val, _) {
                        return Text(
                          'H-${val.toInt()}',
                          style: TextStyle(fontSize: 8, color: subTextColor),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Monthly Activity Heatmap (format Kalender) ---

  Widget _buildMonthlyActivityHeatmap(
    BuildContext context,
    AppProvider provider,
    Color cardBg,
    Color borderCol,
    Color mainTextColor,
    Color subTextColor,
    ThemeData theme,
    List<Transaction> monthlyTxs,
  ) {
    final int daysInMonth = DateTime(
      _monthlyStartDate.year,
      _monthlyStartDate.month + 1,
      0,
    ).day;
    final int firstWeekday = DateTime(
      _monthlyStartDate.year,
      _monthlyStartDate.month,
      1,
    ).weekday; // Monday = 1, Sunday = 7

    final List<Widget> gridCells = [];

    // Header Mon-Sun
    final daysHeader = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    for (var dh in daysHeader) {
      gridCells.add(
        Center(
          child: Text(
            dh,
            style: TextStyle(
              color: subTextColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Empty spaces before day 1
    for (int i = 1; i < firstWeekday; i++) {
      gridCells.add(const SizedBox());
    }

    // Fill days
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(
        _monthlyStartDate.year,
        _monthlyStartDate.month,
        day,
      );
      final dayTxs = monthlyTxs
          .where(
            (tx) =>
                tx.date.year == date.year &&
                tx.date.month == date.month &&
                tx.date.day == date.day &&
                tx.isExpense,
          )
          .toList();
      final expenseCount = dayTxs.length;

      Color cellColor = Colors.transparent;
      Color textCol = mainTextColor;

      if (expenseCount > 0) {
        if (expenseCount <= 2) {
          cellColor = theme.primaryColor.withValues(alpha: 0.12);
        } else {
          cellColor = theme.primaryColor;
          textCol = Colors.white;
        }
      }

      gridCells.add(
        GestureDetector(
          onTap: () {
            final String formattedDate = DateFormat(
              'dd MMMM yyyy',
            ).format(date);
            _showTransactionsBottomSheet(
              context,
              'Transaksi: $formattedDate',
              dayTxs,
              provider.wallets,
            );
          },
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: cellColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderCol),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: textCol,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (expenseCount > 0)
                  Text(
                    '$expenseCount tx',
                    style: TextStyle(
                      color: textCol.withValues(alpha: 0.7),
                      fontSize: 7,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PETA AKTIVITAS BULAN INI',
            style: TextStyle(
              color: subTextColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Frekuensi transaksi pengeluaran harian',
            style: TextStyle(color: subTextColor, fontSize: 10),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            children: gridCells,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Sedikit',
                style: TextStyle(color: subTextColor, fontSize: 8),
              ),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Banyak',
                style: TextStyle(color: subTextColor, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Top Expenses Filters & Lists (Weekly & Monthly) ---

  Widget _buildWeeklyTopExpensesCard(
    BuildContext context,
    AppProvider provider,
    Color cardBg,
    Color borderCol,
    Color mainTextColor,
    Color subTextColor,
    ThemeData theme,
    List<GroupedExpense> topExpenses,
  ) {
    final currency = provider.currencySymbol;
    final isDarkVal = isDark(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PENGELUARAN TERBESAR',
            style: TextStyle(
              color: subTextColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 14),

          // Filters row: Only Category and Top 5 / 10
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _weeklyFilterCategoryId,
                  dropdownColor: isDarkVal
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  style: TextStyle(color: mainTextColor, fontSize: 11),
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: TextStyle(color: subTextColor, fontSize: 10),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Semua', style: TextStyle(fontSize: 11)),
                    ),
                    ...provider.categories.where((c) => c.isExpense).map((c) {
                      return DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(
                          c.name,
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) =>
                      setState(() => _weeklyFilterCategoryId = val),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderCol),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _weeklyTopLimit = 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _weeklyTopLimit == 5
                              ? theme.primaryColor
                              : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(7),
                          ),
                        ),
                        child: Text(
                          'Top 5',
                          style: TextStyle(
                            color: _weeklyTopLimit == 5
                                ? Colors.white
                                : subTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _weeklyTopLimit = 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _weeklyTopLimit == 10
                              ? theme.primaryColor
                              : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(7),
                          ),
                        ),
                        child: Text(
                          'Top 10',
                          style: TextStyle(
                            color: _weeklyTopLimit == 10
                                ? Colors.white
                                : subTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Expenses List
          if (topExpenses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Tidak ada pengeluaran yang sesuai filter',
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topExpenses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = topExpenses[index];
                final cat = provider.categories.firstWhere(
                  (c) => c.id == item.categoryId,
                  orElse: () => Category.defaultCategories.first,
                );
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkVal
                        ? Colors.white.withValues(alpha: 0.02)
                        : Colors.black.withValues(alpha: 0.015),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderCol),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cat.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(cat.icon, color: cat.color, size: 14),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              style: TextStyle(
                                color: mainTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Sub: ${item.subCategory.isNotEmpty ? item.subCategory : "-"}',
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppLocale.formatCurrency(item.amount, '- $currency '),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTopExpensesCard(
    BuildContext context,
    AppProvider provider,
    Color cardBg,
    Color borderCol,
    Color mainTextColor,
    Color subTextColor,
    ThemeData theme,
    List<GroupedExpense> topExpenses,
  ) {
    final currency = provider.currencySymbol;
    final isDarkVal = isDark(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PENGELUARAN TERBESAR',
            style: TextStyle(
              color: subTextColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 14),

          // Filters row: Only Category and Top 5 / 10
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _monthlyFilterCategoryId,
                  dropdownColor: isDarkVal
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  style: TextStyle(color: mainTextColor, fontSize: 11),
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: TextStyle(color: subTextColor, fontSize: 10),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Semua', style: TextStyle(fontSize: 11)),
                    ),
                    ...provider.categories.where((c) => c.isExpense).map((c) {
                      return DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(
                          c.name,
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) =>
                      setState(() => _monthlyFilterCategoryId = val),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderCol),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _monthlyTopLimit = 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _monthlyTopLimit == 5
                              ? theme.primaryColor
                              : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(7),
                          ),
                        ),
                        child: Text(
                          'Top 5',
                          style: TextStyle(
                            color: _monthlyTopLimit == 5
                                ? Colors.white
                                : subTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _monthlyTopLimit = 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _monthlyTopLimit == 10
                              ? theme.primaryColor
                              : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(7),
                          ),
                        ),
                        child: Text(
                          'Top 10',
                          style: TextStyle(
                            color: _monthlyTopLimit == 10
                                ? Colors.white
                                : subTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Expenses List
          if (topExpenses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Tidak ada pengeluaran yang sesuai filter',
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topExpenses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = topExpenses[index];
                final cat = provider.categories.firstWhere(
                  (c) => c.id == item.categoryId,
                  orElse: () => Category.defaultCategories.first,
                );
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkVal
                        ? Colors.white.withValues(alpha: 0.02)
                        : Colors.black.withValues(alpha: 0.015),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderCol),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cat.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(cat.icon, color: cat.color, size: 14),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              style: TextStyle(
                                color: mainTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Sub: ${item.subCategory.isNotEmpty ? item.subCategory : "-"}',
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppLocale.formatCurrency(item.amount, '- $currency '),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // --- Transaction Logs Cards ---

  Widget _buildWeeklyTransactionLogCard(
    BuildContext context,
    AppProvider provider,
    Color cardBg,
    Color borderCol,
    Color mainTextColor,
    Color subTextColor,
    ThemeData theme,
    List<Transaction> weeklyTxs,
  ) {
    final currency = provider.currencySymbol;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LOG TRANSAKSI MINGGU INI',
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                '${weeklyTxs.length} Transaksi',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (weeklyTxs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Tidak ada log transaksi',
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weeklyTxs.length > 5 ? 5 : weeklyTxs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final tx = weeklyTxs[index];
                final cat = provider.categories.firstWhere(
                  (c) => c.id == tx.categoryId,
                  orElse: () => Category(
                    id: tx.categoryId,
                    name: 'Lainnya',
                    icon: Icons.more_horiz_rounded,
                    color: Colors.grey,
                    isExpense: tx.isExpense,
                  ),
                );
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cat.icon, color: cat.color, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.title,
                            style: TextStyle(
                              color: mainTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${DateFormat('dd MMM HH:mm').format(tx.date)} • ${cat.name}',
                            style: TextStyle(color: subTextColor, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${tx.isExpense ? "-" : "+"} ${AppLocale.formatCurrency(tx.amount, '$currency ')}',
                      style: TextStyle(
                        color: tx.isExpense
                            ? Colors.redAccent
                            : const Color(0xFF00D179),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                );
              },
            ),
          if (weeklyTxs.length > 5) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => _showTransactionsBottomSheet(
                  context,
                  'Semua Transaksi Minggu Ini',
                  weeklyTxs,
                  provider.wallets,
                ),
                child: Text(
                  'Lihat Semua Transaksi',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthlyTransactionLogCard(
    BuildContext context,
    AppProvider provider,
    Color cardBg,
    Color borderCol,
    Color mainTextColor,
    Color subTextColor,
    ThemeData theme,
    List<Transaction> monthlyTxs,
  ) {
    final currency = provider.currencySymbol;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LOG TRANSAKSI BULAN INI',
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                '${monthlyTxs.length} Transaksi',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (monthlyTxs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Tidak ada log transaksi',
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: monthlyTxs.length > 5 ? 5 : monthlyTxs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final tx = monthlyTxs[index];
                final cat = provider.categories.firstWhere(
                  (c) => c.id == tx.categoryId,
                  orElse: () => Category(
                    id: tx.categoryId,
                    name: 'Lainnya',
                    icon: Icons.more_horiz_rounded,
                    color: Colors.grey,
                    isExpense: tx.isExpense,
                  ),
                );
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cat.icon, color: cat.color, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.title,
                            style: TextStyle(
                              color: mainTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${DateFormat('dd MMM HH:mm').format(tx.date)} • ${cat.name}',
                            style: TextStyle(color: subTextColor, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${tx.isExpense ? "-" : "+"} ${AppLocale.formatCurrency(tx.amount, '$currency ')}',
                      style: TextStyle(
                        color: tx.isExpense
                            ? Colors.redAccent
                            : const Color(0xFF00D179),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                );
              },
            ),
          if (monthlyTxs.length > 5) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => _showTransactionsBottomSheet(
                  context,
                  'Semua Transaksi Bulan Ini',
                  monthlyTxs,
                  provider.wallets,
                ),
                child: Text(
                  'Lihat Semua Transaksi',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Pie Chart Builders ---

  List<PieChartSectionData> _buildWeeklyPieSections(
    Map<Category, double> breakdown,
    double total,
  ) {
    final List<PieChartSectionData> sections = [];
    int i = 0;
    final sortedBreakdown = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedBreakdown) {
      final cat = entry.key;
      final val = entry.value;
      final isTouched = i == _weeklyTouchedIndex;
      final double radius = isTouched ? 20.0 : 15.0;

      sections.add(
        PieChartSectionData(
          color: cat.color,
          value: val,
          radius: radius,
          showTitle: false,
          badgeWidget: isTouched
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: cat.color, width: 1),
                  ),
                  child: Text(
                    '${((val / total) * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: cat.color,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          badgePositionPercentageOffset: 0.98,
        ),
      );
      i++;
    }
    return sections;
  }

  List<PieChartSectionData> _buildMonthlyPieSections(
    Map<Category, double> breakdown,
    double total,
  ) {
    final List<PieChartSectionData> sections = [];
    int i = 0;
    final sortedBreakdown = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedBreakdown) {
      final cat = entry.key;
      final val = entry.value;
      final isTouched = i == _monthlyTouchedIndex;
      final double radius = isTouched ? 20.0 : 15.0;

      sections.add(
        PieChartSectionData(
          color: cat.color,
          value: val,
          radius: radius,
          showTitle: false,
          badgeWidget: isTouched
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: cat.color, width: 1),
                  ),
                  child: Text(
                    '${((val / total) * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: cat.color,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          badgePositionPercentageOffset: 0.98,
        ),
      );
      i++;
    }
    return sections;
  }

  bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}

class GroupedExpense {
  final String categoryId;
  final String subCategory;
  final double amount;

  GroupedExpense({
    required this.categoryId,
    required this.subCategory,
    required this.amount,
  });
}
