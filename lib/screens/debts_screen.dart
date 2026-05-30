import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/debt.dart';
import '../main.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  bool _showDebts = true; // true = Utang (we owe), false = Piutang (they owe us)

  void _showAddDebtSheet() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    
    DateTime selectedDate = DateTime.now();
    DateTime? selectedDueDate;
    String? selectedWalletId;
    bool isDebtChoice = _showDebts;

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

            final themeColor = isDebtChoice ? const Color(0xFFFF7043) : const Color(0xFF42A5F5);

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
                child: SingleChildScrollView(
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
                        'Tambah Catatan Utang / Piutang',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Segmented Debt/Piutang Choice
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setSheetState(() => isDebtChoice = true),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDebtChoice ? const Color(0xFFFF7043).withValues(alpha: 0.15) : Colors.transparent,
                                  border: Border.all(color: isDebtChoice ? const Color(0xFFFF7043) : (isDark ? Colors.white10 : Colors.black12)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Utang (Saya Pinjam)',
                                  style: TextStyle(
                                    color: isDebtChoice ? const Color(0xFFFF7043) : textColor,
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
                              onTap: () => setSheetState(() => isDebtChoice = false),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !isDebtChoice ? const Color(0xFF42A5F5).withValues(alpha: 0.15) : Colors.transparent,
                                  border: Border.all(color: !isDebtChoice ? const Color(0xFF42A5F5) : (isDark ? Colors.white10 : Colors.black12)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Piutang (Teman Pinjam)',
                                  style: TextStyle(
                                    color: !isDebtChoice ? const Color(0xFF42A5F5) : textColor,
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

                      // Name input
                      TextField(
                        controller: nameController,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: isDebtChoice ? 'Nama Pemberi Pinjaman' : 'Nama Peminjam',
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

                      // Amount input
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Jumlah Uang (Rp)',
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

                      // Wallet Selector (Optional)
                      if (provider.wallets.isNotEmpty) ...[
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
                                  Text(
                                    isDebtChoice 
                                        ? 'Hubungkan ke Dompet (Uang Masuk)' 
                                        : 'Hubungkan ke Dompet (Uang Keluar)',
                                    style: TextStyle(color: subColor, fontSize: 12),
                                  ),
                                ],
                              ),
                              dropdownColor: sheetBg,
                              isExpanded: true,
                              items: [
                                DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Catat Tanpa Transaksi Dompet', style: TextStyle(color: subColor, fontSize: 12)),
                                ),
                                ...provider.wallets.map((w) {
                                  return DropdownMenuItem<String?>(
                                    value: w.id,
                                    child: Row(
                                      children: [
                                        Icon(w.icon, size: 16, color: w.color),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${w.name} (${AppLocale.formatCurrency(w.balance, 'Rp ')})',
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
                        const SizedBox(height: 16),
                      ],

                      // Date Pickers Row
                      Row(
                        children: [
                          // Pinjam Date
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setSheetState(() {
                                    selectedDate = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Tanggal: ${DateFormat('dd MMM yy').format(selectedDate)}',
                                        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(Icons.calendar_today_rounded, size: 14, color: themeColor),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Due Date
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDueDate ?? DateTime.now().add(const Duration(days: 30)),
                                  firstDate: DateTime.now().subtract(const Duration(days: 305)),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setSheetState(() {
                                    selectedDueDate = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selectedDueDate != null
                                            ? 'Tempo: ${DateFormat('dd MMM yy').format(selectedDueDate!)}'
                                            : 'Jatuh Tempo (Opsional)',
                                        style: TextStyle(
                                          color: selectedDueDate != null ? textColor : subColor,
                                          fontSize: 12,
                                          fontWeight: selectedDueDate != null ? FontWeight.bold : FontWeight.normal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (selectedDueDate != null)
                                      GestureDetector(
                                        onTap: () {
                                          setSheetState(() {
                                            selectedDueDate = null;
                                          });
                                        },
                                        child: Icon(Icons.close_rounded, size: 14, color: Colors.redAccent),
                                      )
                                    else
                                      Icon(Icons.calendar_today_rounded, size: 14, color: subColor),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Note field
                      TextField(
                        controller: noteController,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Catatan (Opsional)',
                          labelStyle: TextStyle(color: subColor, fontSize: 13),
                          filled: true,
                          fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Confirm Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            final name = nameController.text.trim();
                            final amount = double.tryParse(amountController.text) ?? 0.0;
                            final note = noteController.text.trim();

                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Nama tidak boleh kosong')),
                              );
                              return;
                            }
                            if (amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Jumlah nominal uang harus lebih dari 0')),
                              );
                              return;
                            }

                            final navigator = Navigator.of(context);
                            final scaffoldMessenger = ScaffoldMessenger.of(context);

                            await provider.addDebt(
                              name: name,
                              amount: amount,
                              isDebt: isDebtChoice,
                              date: selectedDate,
                              dueDate: selectedDueDate,
                              note: note,
                              walletId: selectedWalletId,
                            );

                            navigator.pop();
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(content: Text('Catatan utang/piutang berhasil disimpan')),
                            );
                          },
                          child: const Text(
                            'Simpan Catatan',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showInstallmentSheet(Debt debt) {
    final amtController = TextEditingController();
    String? selectedWalletId;

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

            final themeColor = debt.isDebt ? const Color(0xFFFF7043) : const Color(0xFF42A5F5);

            if (selectedWalletId == null && provider.wallets.isNotEmpty) {
              selectedWalletId = provider.wallets.first.id;
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
                      debt.isDebt ? 'Bayar Cicilan Utang' : 'Terima Pembayaran Piutang',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      debt.isDebt 
                          ? 'Membayar sisa utang kepada "${debt.name}"'
                          : 'Menerima cicilan piutang dari "${debt.name}"',
                      style: TextStyle(color: subColor, fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Amount input
                    TextField(
                      controller: amtController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Jumlah Pembayaran (Rp)',
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

                    // Wallet Selector
                    if (provider.wallets.isNotEmpty) ...[
                      Text(
                        'PILIH DOMPET TRANSAKSI',
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
                                      '${w.name} (${AppLocale.formatCurrency(w.balance, 'Rp ')})',
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
                        'Tidak ada dompet tersedia. Transaksi dompet dinonaktifkan.',
                        style: TextStyle(color: Colors.redAccent.withValues(alpha: 0.8), fontSize: 12),
                      ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: selectedWalletId == null 
                            ? null 
                            : () async {
                                final amount = double.tryParse(amtController.text) ?? 0.0;
                                if (amount <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Nominal cicilan harus lebih dari 0')),
                                  );
                                  return;
                                }

                                final navigator = Navigator.of(context);
                                final scaffoldMessenger = ScaffoldMessenger.of(context);

                                await provider.addDebtInstallment(
                                  debtId: debt.id,
                                  installmentAmount: amount,
                                  walletId: selectedWalletId!,
                                  paymentDate: DateTime.now(),
                                );

                                navigator.pop();
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('Cicilan pembayaran berhasil dicatat')),
                                );
                              },
                        child: const Text(
                          'Konfirmasi Bayar',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  void _confirmDeleteDebt(Debt debt) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Hapus Catatan',
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan utang/piutang dengan "${debt.name}"?',
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
              await provider.deleteDebt(debt.id);
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Catatan berhasil dihapus')),
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

    // Filter items based on active tab
    final filteredItems = provider.debts.where((item) => item.isDebt == _showDebts).toList();

    double totalAmount = 0.0;
    double totalPaid = 0.0;
    for (var item in filteredItems) {
      totalAmount += item.amount;
      totalPaid += item.paidAmount;
    }

    final totalRemaining = totalAmount - totalPaid;
    final progress = totalAmount > 0 ? (totalPaid / totalAmount).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Utang & Piutang',
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Custom tab controller selector
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showDebts = true),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _showDebts 
                                ? (isDark ? const Color(0xFF0F172A) : Colors.white) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              if (_showDebts && !isDark)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Text(
                            'Utang Saya',
                            style: TextStyle(
                              color: _showDebts ? mainTextColor : subTextColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showDebts = false),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_showDebts 
                                ? (isDark ? const Color(0xFF0F172A) : Colors.white) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              if (!_showDebts && !isDark)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Text(
                            'Piutang Saya',
                            style: TextStyle(
                              color: !_showDebts ? mainTextColor : subTextColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Overview box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _showDebts ? 'Sisa Utang Belum Lunas' : 'Sisa Piutang Belum Ditagih',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            AppLocale.formatCurrency(totalRemaining, '$currency '),
                            style: TextStyle(
                              color: _showDebts ? const Color(0xFFFF7043) : const Color(0xFF42A5F5),
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (_showDebts ? const Color(0xFFFF7043) : const Color(0xFF42A5F5)).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(progress * 100).toStringAsFixed(0)}% Lunas',
                            style: TextStyle(
                              color: _showDebts ? const Color(0xFFFF7043) : const Color(0xFF42A5F5),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(_showDebts ? const Color(0xFFFF7043) : const Color(0xFF42A5F5)),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              Text(
                _showDebts ? 'Daftar Pemberi Pinjaman' : 'Daftar Peminjam Uang',
                style: TextStyle(
                  color: mainTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 16),

              filteredItems.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60.0),
                        child: Column(
                          children: [
                            Icon(
                              _showDebts ? Icons.monetization_on_outlined : Icons.handshake_outlined, 
                              size: 64, 
                              color: subTextColor.withValues(alpha: 0.25)
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showDebts ? 'Tidak ada utang tercatat' : 'Tidak ada piutang tercatat', 
                              style: TextStyle(color: mainTextColor, fontSize: 14, fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tekan tombol + di bawah untuk mencatat', 
                              style: TextStyle(color: subTextColor, fontSize: 12)
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: filteredItems.map((item) {
                        final themeColor = _showDebts ? const Color(0xFFFF7043) : const Color(0xFF42A5F5);
                        final paid = item.paidAmount;
                        final total = item.amount;
                        final itemProgress = total > 0 ? (paid / total).clamp(0.0, 1.0) : 0.0;
                        final isSettled = item.isSettled;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isSettled ? const Color(0xFF00D179).withValues(alpha: 0.12) : themeColor.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isSettled ? Icons.check_circle_rounded : (_showDebts ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded),
                                      color: isSettled ? const Color(0xFF00D179) : themeColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            color: mainTextColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                            decoration: isSettled ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Dipinjam: ${DateFormat('dd MMM yyyy').format(item.date)}',
                                          style: TextStyle(
                                            color: subTextColor,
                                            fontSize: 11,
                                          ),
                                        ),
                                        if (item.dueDate != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Jatuh Tempo: ${DateFormat('dd MMM yyyy').format(item.dueDate!)}',
                                            style: TextStyle(
                                              color: !isSettled && item.dueDate!.isBefore(DateTime.now()) 
                                                  ? Colors.redAccent 
                                                  : subTextColor,
                                              fontSize: 10,
                                              fontWeight: !isSettled && item.dueDate!.isBefore(DateTime.now()) 
                                                  ? FontWeight.bold 
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _confirmDeleteDebt(item),
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.redAccent.withValues(alpha: 0.5),
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              if (item.note.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    item.note,
                                    style: TextStyle(color: subTextColor, fontSize: 11, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Terbayar: ${AppLocale.formatCurrency(paid, 'Rp ')} / ${AppLocale.formatCurrency(total, 'Rp ')}',
                                    style: TextStyle(
                                      color: mainTextColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  Text(
                                    '${(itemProgress * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      color: isSettled ? const Color(0xFF00D179) : themeColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: itemProgress,
                                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.04),
                                  valueColor: AlwaysStoppedAnimation<Color>(isSettled ? const Color(0xFF00D179) : themeColor),
                                  minHeight: 6,
                                ),
                              ),
                              if (!isSettled) ...[
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  height: 38,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: themeColor.withValues(alpha: 0.3)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () => _showInstallmentSheet(item),
                                    child: Text(
                                      _showDebts ? 'Bayar Cicilan' : 'Terima Pembayaran',
                                      style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: _showAddDebtSheet,
        backgroundColor: const Color(0xFF1E293B),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
