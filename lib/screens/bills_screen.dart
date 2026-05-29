import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/bill.dart';
import '../models/category.dart';
import '../models/wallet.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get Category helper
  Category _getCategory(String catId, List<Category> categories) {
    return categories.firstWhere(
      (c) => c.id == catId,
      orElse: () => const Category(
        id: 'bills',
        name: 'Tempat Tinggal',
        icon: Icons.home_rounded,
        color: Color(0xFFFFCA28),
        isExpense: true,
      ),
    );
  }

  // Show bottom sheet to create or edit a bill
  void _showAddEditBillSheet({Bill? billToEdit}) {
    final isEditing = billToEdit != null;
    final titleController = TextEditingController(text: billToEdit?.title ?? '');
    final amountController = TextEditingController(
      text: billToEdit != null ? billToEdit.amount.toInt().toString() : '',
    );
    
    DateTime selectedDueDate = billToEdit?.dueDate ?? DateTime.now().add(const Duration(days: 3));
    String selectedCategoryId = billToEdit?.categoryId ?? 'bills';
    String selectedSubCategory = billToEdit?.subCategory ?? 'Tagihan';
    String? selectedWalletId = billToEdit?.walletId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final provider = Provider.of<AppProvider>(context);
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final sheetBg = isDark ? const Color(0xFF0F172A) : Colors.white;
            final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
            final subColor = isDark ? Colors.white70 : const Color(0xFF64748B);

            final expenseCategories = provider.categories.where((c) => c.isExpense).toList();
            final currentCategory = _getCategory(selectedCategoryId, provider.categories);
            final subCategories = provider.getSubCategoriesForCategory(selectedCategoryId);

            if (!subCategories.contains(selectedSubCategory) && subCategories.isNotEmpty) {
              selectedSubCategory = subCategories.first;
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: sheetBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isEditing ? 'Ubah Pengingat Tagihan' : 'Tambah Pengingat Tagihan',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Nama Tagihan',
                        labelStyle: TextStyle(color: subColor, fontSize: 13),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Jumlah Tagihan (Rp)',
                        labelStyle: TextStyle(color: subColor, fontSize: 13),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Due Date Picker Row
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDueDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                dialogTheme: DialogThemeData(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setSheetState(() {
                            selectedDueDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_month_rounded, size: 20, color: currentCategory.color),
                                const SizedBox(width: 12),
                                Text(
                                  'Jatuh Tempo: ${DateFormat('dd MMMM yyyy').format(selectedDueDate)}',
                                  style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_drop_down_rounded, color: subColor),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Selector Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCategoryId,
                                dropdownColor: sheetBg,
                                items: expenseCategories.map((c) {
                                  return DropdownMenuItem<String>(
                                    value: c.id,
                                    child: Row(
                                      children: [
                                        Icon(c.icon, size: 16, color: c.color),
                                        const SizedBox(width: 8),
                                        Text(
                                          c.name,
                                          style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setSheetState(() {
                                      selectedCategoryId = val;
                                      final subs = provider.getSubCategoriesForCategory(val);
                                      if (subs.isNotEmpty) {
                                        selectedSubCategory = subs.first;
                                      } else {
                                        selectedSubCategory = 'Lainnya';
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Subcategory Dropdown
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: subCategories.contains(selectedSubCategory) ? selectedSubCategory : (subCategories.isNotEmpty ? subCategories.first : 'Lainnya'),
                                dropdownColor: sheetBg,
                                items: (subCategories.isNotEmpty ? subCategories : ['Lainnya']).map((sub) {
                                  return DropdownMenuItem<String>(
                                    value: sub,
                                    child: Text(
                                      sub,
                                      style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setSheetState(() {
                                      selectedSubCategory = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Preselected Wallet Selector
                    if (provider.wallets.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: selectedWalletId,
                            hint: Row(
                              children: [
                                Icon(Icons.account_balance_wallet_rounded, size: 16, color: subColor),
                                const SizedBox(width: 8),
                                Text('Pilih Dompet Default (Opsional)', style: TextStyle(color: subColor, fontSize: 12)),
                              ],
                            ),
                            dropdownColor: sheetBg,
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Tanpa Dompet Default', style: TextStyle(color: subColor, fontSize: 12)),
                              ),
                              ...provider.wallets.map((w) {
                                return DropdownMenuItem<String?>(
                                  value: w.id,
                                  child: Row(
                                    children: [
                                      Icon(w.icon, size: 16, color: w.color),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${w.name} (Rp ${w.balance.toInt()})',
                                        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              setSheetState(() {
                                selectedWalletId = val;
                              });
                            },
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentCategory.color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final amount = double.tryParse(amountController.text) ?? 0.0;
                          
                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nama tagihan tidak boleh kosong')),
                            );
                            return;
                          }
                          if (amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Jumlah nominal tagihan harus lebih dari 0')),
                            );
                            return;
                          }

                          final navigator = Navigator.of(context);
                          final scaffoldMessenger = ScaffoldMessenger.of(context);

                          if (isEditing) {
                            final updated = billToEdit.copyWith(
                              title: title,
                              amount: amount,
                              dueDate: selectedDueDate,
                              categoryId: selectedCategoryId,
                              subCategory: selectedSubCategory,
                              walletId: selectedWalletId,
                            );
                            await provider.updateBill(updated);
                          } else {
                            await provider.addBill(
                              title: title,
                              amount: amount,
                              dueDate: selectedDueDate,
                              categoryId: selectedCategoryId,
                              subCategory: selectedSubCategory,
                              walletId: selectedWalletId,
                            );
                          }

                          navigator.pop();
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing ? 'Tagihan berhasil diperbarui' : 'Tagihan berhasil disimpan',
                              ),
                            ),
                          );
                        },
                        child: Text(
                          isEditing ? 'Simpan Perubahan' : 'Simpan Tagihan',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Show bottom sheet to pay a bill
  void _showPayBillSheet(Bill bill) {
    String? selectedWalletId = bill.walletId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final provider = Provider.of<AppProvider>(context);
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final sheetBg = isDark ? const Color(0xFF0F172A) : Colors.white;
            final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
            final subColor = isDark ? Colors.white70 : const Color(0xFF64748B);

            if (selectedWalletId == null && provider.wallets.isNotEmpty) {
              selectedWalletId = provider.wallets.first.id;
            }

            final currentCategory = _getCategory(bill.categoryId, provider.categories);

            return Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Bayar Tagihan',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Anda akan membayar "${bill.title}" sebesar Rp ${NumberFormat.decimalPattern('id_ID').format(bill.amount)}',
                    style: TextStyle(color: subColor, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Wallet Selector
                  if (provider.wallets.isNotEmpty) ...[
                    Text(
                      'PILIH DOMPET PEMBAYARAN',
                      style: TextStyle(color: subColor, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedWalletId,
                          dropdownColor: sheetBg,
                          isExpanded: true,
                          items: provider.wallets.map((w) {
                            return DropdownMenuItem<String>(
                              value: w.id,
                              child: Row(
                                children: [
                                  Icon(w.icon, size: 16, color: w.color),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${w.name} (Rp ${NumberFormat.decimalPattern('id_ID').format(w.balance)})',
                                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setSheetState(() {
                                selectedWalletId = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ] else
                    Text(
                      'Tidak ada dompet tersedia. Tambahkan dompet terlebih dahulu di menu Dompet.',
                      style: TextStyle(color: Colors.redAccent.withValues(alpha: 0.8), fontSize: 12),
                    ),

                  const SizedBox(height: 24),

                  // Confirm Pay Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentCategory.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: selectedWalletId == null
                          ? null
                          : () async {
                              final navigator = Navigator.of(context);
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              
                              await provider.payBill(
                                billId: bill.id,
                                walletId: selectedWalletId!,
                                paidDate: DateTime.now(),
                              );

                              navigator.pop();
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(content: Text('Tagihan berhasil dibayar')),
                              );
                            },
                      child: const Text(
                        'Konfirmasi Pembayaran',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Confirm delete dialog
  void _confirmDeleteBill(Bill bill) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Hapus Tagihan',
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus tagihan "${bill.title}"?',
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
              await provider.deleteBill(bill.id);
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Tagihan berhasil dihapus')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currency = provider.currencySymbol;

    final mainTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF64748B);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.05);
    final cardBgColor = isDark ? theme.cardColor : Colors.white;

    final formatter = NumberFormat.decimalPattern('id_ID');

    // Split bills into paid & unpaid
    final unpaidBills = provider.bills.where((b) => !b.isPaid).toList();
    final paidBills = provider.bills.where((b) => b.isPaid).toList();

    // Sort unpaid by dueDate ascending (urgent first)
    unpaidBills.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    // Sort paid by paidDate descending (newest first)
    paidBills.sort((a, b) => (b.paidDate ?? DateTime.now()).compareTo(a.paidDate ?? DateTime.now()));

    // Calculations
    double totalUnpaid = 0.0;
    for (var b in unpaidBills) {
      totalUnpaid += b.amount;
    }

    // Monthly stats: Count how many bills are paid vs unpaid this month
    final now = DateTime.now();
    int paidThisMonth = 0;
    int totalThisMonth = 0;

    for (var b in provider.bills) {
      if (b.dueDate.month == now.month && b.dueDate.year == now.year) {
        totalThisMonth++;
        if (b.isPaid) {
          paidThisMonth++;
        }
      }
    }

    final double completionRate = totalThisMonth > 0 ? paidThisMonth / totalThisMonth : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Tagihan Keuangan',
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
      body: SafeArea(
        child: Column(
          children: [
            // Header stats section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  // Unpaid Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Belum Dibayar',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '$currency ${formatter.format(totalUnpaid)}',
                                style: TextStyle(
                                  color: totalUnpaid > 0 ? Colors.redAccent : const Color(0xFF00D179),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (totalThisMonth > 0) ...[
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$paidThisMonth / $totalThisMonth Lunas',
                                style: TextStyle(
                                  color: mainTextColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 70,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: completionRate,
                                    minHeight: 6,
                                    backgroundColor: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D179)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Switcher
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                labelColor: mainTextColor,
                unselectedLabelColor: subTextColor,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Outfit'),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Outfit'),
                tabs: const [
                  Tab(text: 'Belum Dibayar'),
                  Tab(text: 'Riwayat Lunas'),
                ],
              ),
            ),

            // Tab View contents
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Unpaid Bills
                  _buildBillsList(unpaidBills, provider.categories, provider.wallets, isDark, mainTextColor, subTextColor, cardBgColor, borderColor, false),

                  // Tab 2: Paid Bills
                  _buildBillsList(paidBills, provider.categories, provider.wallets, isDark, mainTextColor, subTextColor, cardBgColor, borderColor, true),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _showAddEditBillSheet(),
        backgroundColor: const Color(0xFF1E293B),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildBillsList(
    List<Bill> bills,
    List<Category> categories,
    List<Wallet> wallets,
    bool isDark,
    Color mainTextColor,
    Color subTextColor,
    Color cardBgColor,
    Color borderColor,
    bool isHistoryTab,
  ) {
    if (bills.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isHistoryTab ? Icons.assignment_turned_in_rounded : Icons.receipt_long_rounded,
                size: 64,
                color: subTextColor.withValues(alpha: 0.25),
              ),
              const SizedBox(height: 16),
              Text(
                isHistoryTab ? 'Belum ada riwayat pembayaran' : 'Semua tagihan Anda lunas!',
                style: TextStyle(color: mainTextColor, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                isHistoryTab ? 'Tagihan yang dilunasi akan muncul di sini' : 'Tekan tombol + untuk menambahkan tagihan baru',
                style: TextStyle(color: subTextColor, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final currencyFormat = NumberFormat.decimalPattern('id_ID');

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        final cat = _getCategory(bill.categoryId, categories);

        // Overdue state
        final isOverdue = !bill.isPaid && bill.dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));
        final isDueSoon = !bill.isPaid && !isOverdue && bill.dueDate.difference(DateTime.now()).inDays <= 3;

        // Fetch pre-selected wallet
        Wallet? defaultWallet;
        if (bill.walletId != null) {
          defaultWallet = wallets.firstWhere((w) => w.id == bill.walletId, orElse: () => wallets.first);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: bill.isPaid
                  ? null
                  : () {
                      // Tap options for unpaid bills
                      _showUnpaidBillOptions(bill);
                    },
              onLongPress: () => _confirmDeleteBill(bill),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    // Category icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bill.isPaid
                            ? const Color(0xFF00D179).withValues(alpha: 0.12)
                            : (isOverdue ? Colors.redAccent.withValues(alpha: 0.12) : cat.color.withValues(alpha: 0.12)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        bill.isPaid ? Icons.check_circle_rounded : cat.icon,
                        color: bill.isPaid
                            ? const Color(0xFF00D179)
                            : (isOverdue ? Colors.redAccent : cat.color),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Information details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.title,
                            style: TextStyle(
                              color: mainTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: bill.isPaid ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (bill.isPaid) ...[
                            Text(
                              'Lunas: ${DateFormat('dd MMM yyyy').format(bill.paidDate ?? DateTime.now())}',
                              style: TextStyle(color: const Color(0xFF00D179), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            if (defaultWallet != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.account_balance_wallet_rounded, size: 10, color: subTextColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Melalui ${defaultWallet.name}',
                                    style: TextStyle(color: subTextColor, fontSize: 10),
                                  ),
                                ],
                              ),
                            ]
                          ] else ...[
                            Text(
                              'Tempo: ${DateFormat('dd MMM yyyy').format(bill.dueDate)}',
                              style: TextStyle(
                                color: isOverdue
                                    ? Colors.redAccent
                                    : (isDueSoon ? Colors.orangeAccent : subTextColor),
                                fontSize: 11,
                                fontWeight: (isOverdue || isDueSoon) ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (isOverdue) ...[
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Terlambat',
                                  style: TextStyle(color: Colors.redAccent, fontSize: 8, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ] else if (isDueSoon) ...[
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Segera Jatuh Tempo',
                                  style: TextStyle(color: Colors.orangeAccent, fontSize: 8, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ]
                          ]
                        ],
                      ),
                    ),

                    // Amount & Action
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rp ${currencyFormat.format(bill.amount)}',
                          style: TextStyle(
                            color: bill.isPaid ? subTextColor : mainTextColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!bill.isPaid)
                          GestureDetector(
                            onTap: () => _showPayBillSheet(bill),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: (isOverdue ? Colors.redAccent : const Color(0xFF00D179)).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Bayar',
                                style: TextStyle(
                                  color: isOverdue ? Colors.redAccent : const Color(0xFF00D179),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () => _confirmDeleteBill(bill),
                            child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent.withValues(alpha: 0.6), size: 18),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Show bottom sheet with options for unpaid bill
  void _showUnpaidBillOptions(Bill bill) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF0F172A) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final borderColor = isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05);

        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                bill.title,
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Pay
              ListTile(
                leading: const Icon(Icons.payments_rounded, color: Color(0xFF00D179)),
                title: Text('Bayar Tagihan', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _showPayBillSheet(bill);
                },
              ),
              Divider(color: borderColor, height: 1),

              // Edit
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
                title: Text('Ubah Tagihan', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _showAddEditBillSheet(billToEdit: bill);
                },
              ),
              Divider(color: borderColor, height: 1),

              // Delete
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                title: Text('Hapus Tagihan', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteBill(bill);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
