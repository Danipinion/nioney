import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../widgets/transaction_item.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFrequency = 'Bulan'; // Hari, Minggu, Bulan, Tahun, Semua
  String _selectedCategoryId = 'all'; // 'all' means all categories
  String _transactionType = 'all'; // 'all', 'income', 'expense'
  String _selectedSubCategory = 'all';

  List<Transaction> _getFilteredTransactions(AppProvider provider) {
    final now = DateTime.now();
    List<Transaction> filtered = provider.transactions;

    // Filter by Type
    if (_transactionType == 'income') {
      filtered = filtered.where((tx) => !tx.isExpense && tx.categoryId != 'sys_transfer').toList();
    } else if (_transactionType == 'expense') {
      filtered = filtered.where((tx) => tx.isExpense && tx.categoryId != 'sys_transfer').toList();
    }

    // Filter by Category
    if (_selectedCategoryId != 'all') {
      filtered = filtered.where((tx) => tx.categoryId == _selectedCategoryId).toList();
    }
    
    // Filter by Subcategory
    if (_selectedSubCategory != 'all') {
      filtered = filtered.where((tx) => tx.subCategory == _selectedSubCategory).toList();
    }

    // Filter by Frequency
    if (_selectedFrequency == 'Hari') {
      filtered = filtered.where((tx) {
        return tx.date.year == now.year && tx.date.month == now.month && tx.date.day == now.day;
      }).toList();
    } else if (_selectedFrequency == 'Minggu') {
      final todayMidnight = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final weekAgo = todayMidnight.subtract(const Duration(days: 7));
      filtered = filtered.where((tx) {
        return tx.date.isAfter(weekAgo);
      }).toList();
    } else if (_selectedFrequency == 'Bulan') {
      filtered = filtered.where((tx) {
        return tx.date.year == now.year && tx.date.month == now.month;
      }).toList();
    } else if (_selectedFrequency == 'Tahun') {
      filtered = filtered.where((tx) {
        return tx.date.year == now.year;
      }).toList();
    }

    return filtered;
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? Colors.white : const Color(0xFF0F172A))
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Colors.transparent 
                : (isDark ? Colors.white24 : Colors.black12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                : (isDark ? Colors.white70 : const Color(0xFF64748B)),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final inputBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04);
    
    final provider = Provider.of<AppProvider>(context);
    final filteredTransactions = _getFilteredTransactions(provider);

    // Currency Formatter
    final currency = provider.wallets.isNotEmpty ? 'IDR' : 'IDR'; // fallback
    final numberFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '$currency ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Semua Transaksi',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            fontFamily: 'Outfit',
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: mainTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: theme.appBarTheme.backgroundColor,
              border: Border(
                bottom: BorderSide(color: borderCol, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Frequency
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip('Hari', _selectedFrequency == 'Hari', () => setState(() => _selectedFrequency = 'Hari'), theme, isDark),
                      _buildFilterChip('Minggu', _selectedFrequency == 'Minggu', () => setState(() => _selectedFrequency = 'Minggu'), theme, isDark),
                      _buildFilterChip('Bulan', _selectedFrequency == 'Bulan', () => setState(() => _selectedFrequency = 'Bulan'), theme, isDark),
                      _buildFilterChip('Tahun', _selectedFrequency == 'Tahun', () => setState(() => _selectedFrequency = 'Tahun'), theme, isDark),
                      _buildFilterChip('Semua', _selectedFrequency == 'Semua', () => setState(() => _selectedFrequency = 'Semua'), theme, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Type & Category
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderCol),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _transactionType,
                            dropdownColor: theme.cardColor,
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: subTextColor, size: 20),
                            items: const <DropdownMenuItem<String>>[
                              DropdownMenuItem<String>(value: 'all', child: Text('Semua Tipe', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                              DropdownMenuItem<String>(value: 'income', child: Text('Pemasukan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                              DropdownMenuItem<String>(value: 'expense', child: Text('Pengeluaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _transactionType = val);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderCol),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategoryId,
                            dropdownColor: theme.cardColor,
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: subTextColor, size: 20),
                            items: <DropdownMenuItem<String>>[
                              const DropdownMenuItem<String>(value: 'all', child: Text('Semua Kategori', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                              ...provider.categories.where((c) => !c.id.startsWith('sys_')).map<DropdownMenuItem<String>>((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat.id,
                                  child: Row(
                                    children: [
                                      Icon(cat.icon, color: cat.color, size: 14),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          cat.name,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCategoryId = val;
                                  _selectedSubCategory = 'all'; // Reset subcategory when category changes
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Sub Category
                if (_selectedCategoryId != 'all')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSubCategory,
                        dropdownColor: theme.cardColor,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: subTextColor, size: 20),
                        items: <DropdownMenuItem<String>>[
                          const DropdownMenuItem<String>(value: 'all', child: Text('Semua Sub Kategori', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                          ...provider.getSubCategoriesForCategory(_selectedCategoryId)
                              .where((s) => s != null)
                              .map<DropdownMenuItem<String>>((subName) {
                            return DropdownMenuItem<String>(
                              value: subName.toString(),
                              child: Row(
                                children: [
                                  Icon(Icons.subdirectory_arrow_right_rounded, color: subTextColor, size: 14),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      subName.toString(),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSubCategory = val);
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // List View
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 60, color: subTextColor.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada transaksi',
                          style: TextStyle(
                            color: mainTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Coba ubah filter untuk melihat riwayat.',
                          style: TextStyle(color: subTextColor, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredTransactions.length,
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
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => AddTransactionScreen(editItem: tx),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
