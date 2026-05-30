import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../main.dart';
import 'add_transaction_screen.dart';

class WalletDetailScreen extends StatefulWidget {
  final String walletId;

  const WalletDetailScreen({super.key, required this.walletId});

  @override
  State<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: Semua, 1: Pengeluaran, 2: Pemasukan, 3: Transfer
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper to get transaction icon
  IconData _getTransactionIcon(Transaction tx, List<Category> categories) {
    if (tx.categoryId == 'sys_transfer') {
      return Icons.swap_horiz_rounded;
    }
    final category = categories.firstWhere(
      (c) => c.id == tx.categoryId,
      orElse: () => Category(
        id: 'unknown',
        name: tx.subCategory.isNotEmpty ? tx.subCategory : 'Lainnya',
        icon: Icons.help_outline_rounded,
        color: Colors.grey,
        isExpense: tx.isExpense,
      ),
    );
    return category.icon;
  }

  Color _getTransactionColor(Transaction tx, List<Category> categories) {
    if (tx.categoryId == 'sys_transfer') {
      return const Color(0xFF64748B);
    }
    final category = categories.firstWhere(
      (c) => c.id == tx.categoryId,
      orElse: () => Category(
        id: 'unknown',
        name: tx.subCategory.isNotEmpty ? tx.subCategory : 'Lainnya',
        icon: Icons.help_outline_rounded,
        color: Colors.grey,
        isExpense: tx.isExpense,
      ),
    );
    return category.color;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final scaffoldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05);

    // Find the wallet
    final wallet = provider.wallets.firstWhere(
      (w) => w.id == widget.walletId,
      orElse: () => Wallet(
        id: 'unknown',
        name: 'Dompet Tidak Ditemukan',
        type: 'Cash',
        balance: 0.0,
        icon: Icons.help_outline_rounded,
        color: Colors.grey,
      ),
    );

    if (wallet.id == 'unknown') {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Dompet')),
        body: const Center(child: Text('Dompet tidak ditemukan')),
      );
    }

    final currency = provider.currencySymbol;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 2,
    );

    String formatVal(double value) {
      if (AppLocale.hideAllNominal) {
        return 'Rp***';
      }
      return formatter.format(value);
    }

    // Filter transactions for this wallet
    final allWalletTxs = provider.transactions.where((tx) => tx.walletId == wallet.id).toList();

    // Sort descending by date
    allWalletTxs.sort((a, b) => b.date.compareTo(a.date));

    // Compute monthly income & expenses for this wallet
    final now = DateTime.now();
    double monthlyIn = 0.0;
    double monthlyOut = 0.0;

    for (var tx in allWalletTxs) {
      if (tx.date.month == now.month && tx.date.year == now.year) {
        if (tx.categoryId == 'sys_transfer') {
          // If it's a transfer and this wallet is source, it's out. If it's dest, it's in.
          if (tx.isExpense) {
            monthlyOut += tx.amount;
          } else {
            monthlyIn += tx.amount;
          }
        } else {
          if (tx.isExpense) {
            monthlyOut += tx.amount;
          } else {
            monthlyIn += tx.amount;
          }
        }
      }
    }

    // Category breakdown specifically for this wallet
    final Map<String, double> categoryAmounts = {};
    final Map<String, Category> categoryMap = {};
    double totalSpent = 0.0;

    for (var tx in allWalletTxs) {
      if (tx.isExpense && tx.categoryId != 'sys_saving_target' && tx.categoryId != 'sys_transfer') {
        final cat = provider.categories.firstWhere(
          (c) => c.id == tx.categoryId,
          orElse: () => Category(
            id: tx.categoryId,
            name: tx.subCategory.isNotEmpty ? tx.subCategory : 'Lainnya',
            icon: Icons.category_rounded,
            color: Colors.blueGrey,
            isExpense: true,
          ),
        );
        categoryAmounts[cat.id] = (categoryAmounts[cat.id] ?? 0.0) + tx.amount;
        categoryMap[cat.id] = cat;
        totalSpent += tx.amount;
      }
    }

    final sortedCategories = categoryAmounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get trend data points (last 7 days balance trend)
    final List<FlSpot> balanceTrendSpots = [];
    final List<String> trendDates = [];
    if (allWalletTxs.isNotEmpty) {
      double runningBalance = wallet.balance;
      // Start with current balance at the last day (today)
      final List<MapEntry<DateTime, double>> history = [];
      history.add(MapEntry(DateTime.now(), runningBalance));

      // Go backwards in time to reconstruct history
      // Note: allWalletTxs is sorted descending (newest first)
      for (var tx in allWalletTxs) {
        if (tx.categoryId == 'sys_transfer') {
          if (tx.isExpense) {
            // Transfer out: balance was higher before this tx
            runningBalance += tx.amount;
          } else {
            // Transfer in: balance was lower before this tx
            runningBalance -= tx.amount;
          }
        } else {
          if (tx.isExpense) {
            runningBalance += tx.amount;
          } else {
            runningBalance -= tx.amount;
          }
        }
        history.add(MapEntry(tx.date, runningBalance));
      }

      // Reverse history to have chronological order
      final sortedHistory = history.reversed.toList();

      // Take a max of 7 points to show weekly overview
      final int pointsToShow = sortedHistory.length > 7 ? 7 : sortedHistory.length;
      final selectedHistory = sortedHistory.sublist(sortedHistory.length - pointsToShow);

      for (int i = 0; i < selectedHistory.length; i++) {
        balanceTrendSpots.add(FlSpot(i.toDouble(), selectedHistory[i].value));
        trendDates.add(DateFormat('dd/MM').format(selectedHistory[i].key));
      }
    }

    // Apply search and tab filter to the list
    final filteredTxs = allWalletTxs.where((tx) {
      // 1. Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = tx.title.toLowerCase().contains(query);
        final matchesNote = tx.note.toLowerCase().contains(query);
        final matchesCategory = tx.subCategory.toLowerCase().contains(query);
        if (!matchesTitle && !matchesNote && !matchesCategory) {
          return false;
        }
      }

      // 2. Type Filter
      if (_selectedFilterIndex == 1) {
        // Pengeluaran
        return tx.isExpense && tx.categoryId != 'sys_transfer';
      } else if (_selectedFilterIndex == 2) {
        // Pemasukan
        return tx.isExpense == false && tx.categoryId != 'sys_transfer';
      } else if (_selectedFilterIndex == 3) {
        // Transfer
        return tx.categoryId == 'sys_transfer';
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Dompet',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Outfit',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: textColor),
            onPressed: () {
              // Edit Wallet details (Future extension / placeholder)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur edit dompet dapat diakses dengan tekan lama di daftar dompet.'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Sleek Wallet Card Representation
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    wallet.color,
                    wallet.color.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: wallet.color.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(wallet.icon, color: Colors.white, size: 24),
                            ),
                            Text(
                              wallet.type.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Saldo Saat Ini',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatVal(wallet.balance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          wallet.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Action Buttons (Pemasukan, Pengeluaran, Transfer)
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.arrow_downward_rounded,
                    label: 'Pemasukan',
                    color: const Color(0xFF00D179),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => AddTransactionScreen(
                          initialWalletId: wallet.id,
                          initialTypeIndex: 1, // Income
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.arrow_upward_rounded,
                    label: 'Pengeluaran',
                    color: Colors.redAccent,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => AddTransactionScreen(
                          initialWalletId: wallet.id,
                          initialTypeIndex: 0, // Expense
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.swap_horiz_rounded,
                    label: 'Transfer',
                    color: const Color(0xFF1E293B),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => AddTransactionScreen(
                          initialWalletId: wallet.id,
                          initialTypeIndex: 2, // Transfer
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Mini Monthly Summary Row
            Row(
              children: [
                Expanded(
                  child: Container(
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D179).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.arrow_downward_rounded, color: Color(0xFF00D179), size: 14),
                            ),
                            const SizedBox(width: 8),
                            Text('Pemasukan Bulan Ini', style: TextStyle(color: subTextColor, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatVal(monthlyIn),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.arrow_upward_rounded, color: Colors.redAccent, size: 14),
                            ),
                            const SizedBox(width: 8),
                            Text('Pengeluaran Bulan Ini', style: TextStyle(color: subTextColor, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatVal(monthlyOut),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Trend Line Chart
            if (balanceTrendSpots.length >= 2) ...[
              Container(
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
                      'TREN SALDO DOMPET (7 TITIK TERAKHIR)',
                      style: TextStyle(color: subTextColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 150,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index >= 0 && index < trendDates.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Text(trendDates[index], style: TextStyle(color: subTextColor, fontSize: 8)),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: balanceTrendSpots,
                              isCurved: true,
                              color: wallet.color,
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 3,
                                    color: wallet.color,
                                    strokeWidth: 1,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: wallet.color.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 5. Category Breakdown for Expense
            if (sortedCategories.isNotEmpty) ...[
              Container(
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
                      'DISTRIBUSI PENGELUARAN DOMPET',
                      style: TextStyle(color: subTextColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedCategories.length > 5 ? 5 : sortedCategories.length,
                      itemBuilder: (context, index) {
                        final entry = sortedCategories[index];
                        final cat = categoryMap[entry.key]!;
                        final amt = entry.value;
                        final percent = (amt / totalSpent) * 100;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(cat.icon, color: cat.color, size: 14),
                                      const SizedBox(width: 8),
                                      Text(cat.name, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                  Text(
                                    '${formatVal(amt)} (${percent.toStringAsFixed(1)}%)',
                                    style: TextStyle(color: subTextColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: amt / totalSpent,
                                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                                  valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 6. Transaction Log Search & Filter Switchers
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderCol),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Cari transaksi...',
                        hintStyle: TextStyle(color: subTextColor.withValues(alpha: 0.6), fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, color: subTextColor, size: 18),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Horizontal Toggle Switcher for Transaction Types
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildTypeTabItem(0, 'Semua', isDark, textColor, subTextColor, theme),
                  const SizedBox(width: 8),
                  _buildTypeTabItem(1, 'Pengeluaran', isDark, textColor, subTextColor, theme),
                  const SizedBox(width: 8),
                  _buildTypeTabItem(2, 'Pemasukan', isDark, textColor, subTextColor, theme),
                  const SizedBox(width: 8),
                  _buildTypeTabItem(3, 'Transfer', isDark, textColor, subTextColor, theme),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 7. Transactions List
            Text(
              'RIWAYAT TRANSAKSI',
              style: TextStyle(color: subTextColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1),
            ),
            const SizedBox(height: 12),
            if (filteredTxs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_toggle_off_rounded, size: 48, color: subTextColor.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text('Tidak ada riwayat transaksi', style: TextStyle(color: subTextColor, fontSize: 13)),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredTxs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final tx = filteredTxs[index];
                  final txColor = _getTransactionColor(tx, provider.categories);
                  final txIcon = _getTransactionIcon(tx, provider.categories);

                  return Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          // Show edit transaction
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => AddTransactionScreen(editItem: tx),
                          );
                        },
                        onLongPress: () => _confirmDeleteTransaction(context, provider, tx),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: txColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(txIcon, color: txColor, size: 18),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx.title,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd MMM yyyy • HH:mm').format(tx.date),
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 10,
                                      ),
                                    ),
                                    if (tx.note.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        tx.note,
                                        style: TextStyle(
                                          color: subTextColor.withValues(alpha: 0.7),
                                          fontSize: 9,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                AppLocale.formatCurrency(
                                  tx.amount,
                                  tx.categoryId == 'sys_transfer'
                                      ? (tx.isExpense ? '- $currency ' : '+ $currency ')
                                      : (tx.isExpense ? '- $currency ' : '+ $currency '),
                                ),
                                style: TextStyle(
                                  color: tx.categoryId == 'sys_transfer'
                                      ? const Color(0xFF64748B)
                                      : (tx.isExpense ? Colors.redAccent : const Color(0xFF00D179)),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  fontFamily: 'Outfit',
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
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTabItem(
    int index,
    String title,
    bool isDarkVal,
    Color mainTextColor,
    Color subTextColor,
    ThemeData theme,
  ) {
    final isActive = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF1E293B) // Premium dark slate capsule for active
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : (isDarkVal ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08)),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : subTextColor,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _confirmDeleteTransaction(BuildContext context, AppProvider provider, Transaction tx) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Hapus Transaksi',
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus transaksi "${tx.title}"?',
          style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: theme.primaryColor)),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              navigator.pop();
              await provider.deleteTransaction(tx.id);
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Transaksi berhasil dihapus')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
