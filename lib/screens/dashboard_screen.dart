import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/wallet_card.dart';
import '../widgets/transaction_item.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final currency = provider.currencySymbol;

    final numberFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '$currency ',
      decimalDigits: 0,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header & Greeting
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      'Hey Dani! 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Consolidated Wealth Card
              GlassCard(
                padding: const EdgeInsets.all(24.0),
                borderRadius: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL BALANCE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
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
                    const SizedBox(height: 22),
                    // Monthly Breakdown Row
                    Row(
                      children: [
                        // Income
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF66BB6A,
                                  ).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_downward_rounded,
                                  color: Color(0xFF66BB6A),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              CrossFadeRow(
                                title: 'Income',
                                amount: numberFormat.format(
                                  provider.monthlyIncome,
                                ),
                                color: const Color(0xFF66BB6A),
                              ),
                            ],
                          ),
                        ),
                        // Expense
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFF7043,
                                  ).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_upward_rounded,
                                  color: Color(0xFFFF7043),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              CrossFadeRow(
                                title: 'Expenses',
                                amount: numberFormat.format(
                                  provider.monthlyExpense,
                                ),
                                color: const Color(0xFFFF7043),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Wallets Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Wallets',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to wallets screen via bottom bar or custom logic
                    },
                    child: Text(
                      'Manage',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Horizontal Wallets List
              SizedBox(
                height: 155,
                child: provider.wallets.isEmpty
                    ? Center(
                        child: Text(
                          'No wallets created yet.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: provider.wallets.length,
                        itemBuilder: (context, index) {
                          final wallet = provider.wallets[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: WalletCard(
                              wallet: wallet,
                              currencySymbol: currency,
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 28),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (provider.transactions.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // Action to see all
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Transactions List Feed
              provider.transactions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No transactions recorded yet.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.35),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.transactions.length > 5
                          ? 5
                          : provider.transactions.length,
                      itemBuilder: (context, index) {
                        final tx = provider.transactions[index];
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
              const SizedBox(
                height: 100,
              ), // Padding to avoid overlap with FAB/NavBar
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTransactionScreen(),
          );
        },
        backgroundColor: theme.primaryColor,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add_rounded, color: Colors.black, size: 32),
      ),
    );
  }
}

class CrossFadeRow extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  const CrossFadeRow({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                fontFamily: 'Outfit',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
