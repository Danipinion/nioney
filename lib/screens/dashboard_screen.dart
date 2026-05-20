import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/wallet.dart';
import '../widgets/transaction_item.dart';
import 'add_transaction_screen.dart';
import 'budgets_screen.dart';
import 'recurring_screen.dart';
import 'savings_targets_screen.dart';
import 'bills_screen.dart';
import 'debts_screen.dart';
import 'wishlist_screen.dart';
import 'cards_screen.dart';
import 'notes_screen.dart';
import 'reimburse_screen.dart';
import 'assets_screen.dart';
import '../main.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedTab = 'Bulan';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final currency = provider.currencySymbol;
    final isDark = theme.brightness == Brightness.dark;

    // Theme-aware colors
    final mainTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : const Color(0xFF64748B);
    final cardBgColor = isDark ? theme.cardColor : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.03);

    // Number format config
    final numberFormat = AppLocale.isInitialized
        ? NumberFormat.currency(
            locale: 'id_ID',
            symbol: '$currency ',
            decimalDigits: 0,
          )
        : NumberFormat.currency(
            symbol: '$currency ',
            decimalDigits: 0,
          );

    // Dynamic Filter calculations based on _selectedTab
    final now = DateTime.now();
    List<dynamic> filteredTransactions = provider.transactions;

    if (_selectedTab == 'Hari') {
      filteredTransactions = provider.transactions.where((tx) {
        return tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.date.day == now.day;
      }).toList();
    } else if (_selectedTab == 'Minggu') {
      final todayMidnight = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final weekAgo = todayMidnight.subtract(const Duration(days: 7));
      filteredTransactions = provider.transactions.where((tx) {
        return tx.date.isAfter(weekAgo);
      }).toList();
    } else if (_selectedTab == 'Bulan') {
      filteredTransactions = provider.transactions.where((tx) {
        return tx.date.year == now.year && tx.date.month == now.month;
      }).toList();
    } else if (_selectedTab == 'Tahun') {
      filteredTransactions = provider.transactions.where((tx) {
        return tx.date.year == now.year;
      }).toList();
    } else if (_selectedTab == 'Semua') {
      filteredTransactions = provider.transactions;
    }

    // Dynamic Income / Expense sums
    double displayIncome = 0.0;
    double displayExpense = 0.0;

    for (var tx in filteredTransactions) {
      if (tx.categoryId == 'sys_transfer') continue; // Exclude Transfer
      if (tx.isExpense) {
        displayExpense += tx.amount;
      } else {
        displayIncome += tx.amount;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 1. Header Row (~ Hai, Danipinion! + Lvl 1 + Avatar)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '~ Hai, Danipinion!',
                    style: TextStyle(
                      color: mainTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  Row(
                    children: [
                      // Level Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFCA28), // Gold/Amber Star
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Lvl 1',
                              style: TextStyle(
                                color: mainTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Cute Green Avatar
                      Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D179), // Premium Green
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF00D179,
                              ).withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.sentiment_very_satisfied_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Filter Tab Row (Hari, Minggu, Bulan, Tahun, Semua)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFilterTab('Hari', mainTextColor, subTextColor),
                  _buildFilterTab('Minggu', mainTextColor, subTextColor),
                  _buildFilterTab('Bulan', mainTextColor, subTextColor),
                  _buildFilterTab('Tahun', mainTextColor, subTextColor),
                  _buildFilterTab('Semua', mainTextColor, subTextColor),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Consolidated Wealth Card (Flat Slate Color with luxurious design assets)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF1E293B,
                  ), // Ultra-premium deep slate flat color
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: -4,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative Circle top-right
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.035),
                        ),
                      ),
                    ),
                    // Decorative Circle bottom-left
                    Positioned(
                      bottom: -30,
                      left: -40,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.025),
                        ),
                      ),
                    ),

                    // Decorative Mock Visa/Mastercard circles in bottom-right
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: Opacity(
                        opacity: 0.12,
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-8, 0),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Decorative Mock NFC Card indicator in top-right
                    const Positioned(
                      top: 24,
                      right: 24,
                      child: Opacity(
                        opacity: 0.15,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_tethering_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.nfc_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Card Content
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Total Saldo (IDR)',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.visibility_rounded,
                                color: Colors.white.withValues(alpha: 0.75),
                                size: 14,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            numberFormat.format(provider.totalBalance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Pemasukan / Pengeluaran Row (Dynamically calculated based on selected tab)
                          Row(
                            children: [
                              // Pemasukan Box
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.white24,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.arrow_downward_rounded,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'Pemasukan',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        numberFormat.format(displayIncome),
                                        style: const TextStyle(
                                          color: Colors.white,
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
                              // Pengeluaran Box
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.white24,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.arrow_upward_rounded,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'Pengeluaran',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        numberFormat.format(displayExpense),
                                        style: const TextStyle(
                                          color: Colors.white,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. "Menu" Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: mainTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(Icons.more_vert_rounded, color: subTextColor, size: 20),
                ],
              ),
              const SizedBox(height: 12),

              // Menu Options Slider (Horizontal Scrollable Row)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildMenuItem(
                      context,
                      Icons.percent_rounded,
                      'Anggaran',
                      const Color(0xFFFFECE2),
                      const Color(0xFFFF7043),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BudgetsScreen(),
                          ),
                        );
                      },
                      subTextColor,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.cached_rounded,
                      'Berulang',
                      const Color(0xFFE3F2FD),
                      const Color(0xFF42A5F5),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecurringScreen(),
                          ),
                        );
                      },
                      subTextColor,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.savings_rounded,
                      'Target',
                      const Color(0xFFE8F5E9),
                      const Color(0xFF66BB6A),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SavingsTargetsScreen(),
                          ),
                        );
                      },
                      subTextColor,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.receipt_long_rounded,
                      'Tagihan',
                      const Color(0xFFFFEBEE),
                      const Color(0xFFEF5350),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BillsScreen(),
                          ),
                        );
                      },
                      subTextColor,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.payment_rounded,
                      'Utang',
                      const Color(0xFFF3E5F5),
                      const Color(0xFFAB47BC),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DebtsScreen(),
                          ),
                        );
                      },
                      subTextColor,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.favorite_rounded,
                      'Keinginan',
                      const Color(0xFFFFF8E1),
                      const Color(0xFFFFB300),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WishlistScreen(),
                          ),
                        );
                      },
                      subTextColor,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.credit_card_rounded,
                      'Kartu',
                      const Color(0xFFE0F7FA),
                      const Color(0xFF00ACC1),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CardsScreen(),
                          ),
                        );
                      },
                      subTextColor,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.edit_note_rounded,
                      'Catatan',
                      const Color(0xFFEFEBE9),
                      const Color(0xFF8D6E63),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotesScreen(),
                          ),
                        );
                      },
                      subTextColor,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.currency_exchange_rounded,
                      'Reimburse',
                      const Color(0xFFF1F8E9),
                      const Color(0xFF7CB342),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReimburseScreen(),
                          ),
                        );
                      },
                      subTextColor,
                    ),
                    _buildMenuItem(
                      context,
                      Icons.trending_up_rounded,
                      'Aset',
                      const Color(0xFFECEFF1),
                      const Color(0xFF607D8B),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AssetsScreen(),
                          ),
                        );
                      },
                      subTextColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. "Anggaran Bulanan" Box (Dynamic Total Only!)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BudgetsScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Anggaran Bulanan',
                            style: TextStyle(
                              color: mainTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: subTextColor,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      provider.budgets.isEmpty
                          ? Row(
                              children: [
                                Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: subTextColor.withValues(alpha: 0.6),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Belum ada anggaran. Ketuk untuk membuat!',
                                    style: TextStyle(
                                      color: subTextColor.withValues(alpha: 0.7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : () {
                              // Compute global aggregated budget details
                              final double totalLimit = provider.budgets.fold(0.0, (sum, b) => sum + b.limitAmount);
                              double totalSpent = 0.0;
                              for (var budget in provider.budgets) {
                                totalSpent += provider.getSpentForCategory(budget.categoryId);
                              }
                              final double remaining = totalLimit - totalSpent;
                              final double progress = totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFFECE2), // pastel orange
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.track_changes_rounded,
                                              color: Color(0xFFFF7043),
                                              size: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Total Anggaran',
                                            style: TextStyle(
                                              color: mainTextColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Sisa ${numberFormat.format(remaining < 0 ? 0.0 : remaining)}',
                                        style: TextStyle(
                                          color: remaining < 0 ? const Color(0xFFEF5350) : const Color(0xFF00D179),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Terpakai ${(progress * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          color: subTextColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${numberFormat.format(totalSpent)} / ${numberFormat.format(totalLimit)}',
                                        style: TextStyle(
                                          color: subTextColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: isDark
                                          ? Colors.white.withValues(alpha: 0.04)
                                          : Colors.black.withValues(alpha: 0.04),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        remaining < 0
                                            ? const Color(0xFFEF5350)
                                            : const Color(0xFF00D179), // beautiful premium green progress color
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              );
                            }(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // 7. "Dompet Saya" Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dompet Saya',
                    style: TextStyle(
                      color: mainTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(Icons.more_vert_rounded, color: subTextColor, size: 20),
                ],
              ),
              const SizedBox(height: 12),

              // Wallet dynamic cards (Cash and Emas styles)
              provider.wallets.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada dompet.',
                        style: TextStyle(color: subTextColor),
                      ),
                    )
                  : SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: provider.wallets.length,
                        itemBuilder: (context, index) {
                          final wallet = provider.wallets[index];
                          return Container(
                            width: 160,
                            margin: EdgeInsets.only(
                              right: index == provider.wallets.length - 1 ? 0 : 12,
                            ),
                            child: _buildCustomWalletCard(
                              context,
                              wallet,
                              cardBgColor,
                              borderColor,
                              mainTextColor,
                              subTextColor,
                              numberFormat,
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 24),

              // 8. "Transaksi Terakhir" Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaksi Terakhir',
                    style: TextStyle(
                      color: mainTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (filteredTransactions.isNotEmpty)
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Transaction Feed / Empty State based on selected tab
              filteredTransactions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              'Belum ada transaksi',
                              style: TextStyle(
                                color: mainTextColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                              ),
                              child: Text(
                                'Ayo mulai catat pengeluaran dan pemasukanmu agar keuangan lebih rapi!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Outlined Action Button (+ Tambah Transaksi)
                            OutlinedButton.icon(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) =>
                                      const AddTransactionScreen(),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: mainTextColor.withValues(alpha: 0.15),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              icon: Icon(
                                Icons.add_rounded,
                                color: mainTextColor,
                                size: 18,
                              ),
                              label: Text(
                                'Tambah Transaksi',
                                style: TextStyle(
                                  color: mainTextColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTransactions.length > 5
                          ? 5
                          : filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = filteredTransactions[index];
                        final category = provider.categories.firstWhere(
                          (c) => c.id == tx.categoryId,
                          orElse: () => provider.categories.last,
                        );
                        final wallet = provider.wallets.firstWhere(
                          (w) => w.id == tx.walletId,
                          orElse: () => provider.wallets.first,
                        );

                        return TransactionItem(
                          transaction: tx,
                          category: category,
                          wallet: wallet,
                          currencySymbol: currency,
                          onDelete: () => provider.deleteTransaction(tx.id),
                        );
                      },
                    ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // Filter Tab Builder (Now completely interactive!)
  Widget _buildFilterTab(String title, Color mainColor, Color subColor) {
    final isActive = _selectedTab == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF1E293B)
              : Colors.transparent, // Flat navy capsule for active
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : subColor,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Menu Button Builder
  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String label,
    Color bgCircleColor,
    Color iconColor,
    VoidCallback onTap,
    Color labelColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: bgCircleColor,
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 24)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: labelColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }



  // Custom Wallet Card for "Dompet Saya"
  Widget _buildCustomWalletCard(
    BuildContext context,
    Wallet wallet,
    Color cardBgColor,
    Color borderColor,
    Color mainTextColor,
    Color subTextColor,
    NumberFormat format,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(wallet.icon, color: wallet.color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  wallet.name,
                  style: TextStyle(
                    color: mainTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${wallet.type.toUpperCase()} • IDR',
                style: TextStyle(
                  color: subTextColor.withValues(alpha: 0.6),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                format.format(wallet.balance),
                style: TextStyle(
                  color: mainTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
