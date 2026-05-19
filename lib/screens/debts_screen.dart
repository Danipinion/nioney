import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../main.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  bool _showDebts = true; // true = Utang (we owe), false = Piutang (they owe us)

  // Local state for interactive debts
  final List<Map<String, dynamic>> _debtItems = [
    {
      'id': '1',
      'name': 'Bro Budi (Pinjaman HP)',
      'amount': 2500000.0,
      'paid': 1000000.0,
      'isDebt': true,
      'date': '12 April 2026',
      'color': const Color(0xFFFF7043),
    },
    {
      'id': '2',
      'name': 'Beli Laptop (Tokopedia Paylater)',
      'amount': 8500000.0,
      'paid': 5000000.0,
      'isDebt': true,
      'date': '05 Jan 2026',
      'color': const Color(0xFFAB47BC),
    },
    {
      'id': '3',
      'name': 'Pinjaman Alif (Bensin)',
      'amount': 150000.0,
      'paid': 0.0,
      'isDebt': false,
      'date': '10 Mei 2026',
      'color': const Color(0xFF42A5F5),
    },
    {
      'id': '4',
      'name': 'Sewa Studio Roni',
      'amount': 700000.0,
      'paid': 700000.0,
      'isDebt': false,
      'date': '22 Feb 2026',
      'color': const Color(0xFF66BB6A),
    },
  ];

  void _addRecord(String name, double amount, bool isDebt, String date) {
    setState(() {
      _debtItems.add({
        'id': DateTime.now().toString(),
        'name': name,
        'amount': amount,
        'paid': 0.0,
        'isDebt': isDebt,
        'date': date.isNotEmpty ? date : '19 Mei 2026',
        'color': isDebt ? const Color(0xFFFF7043) : const Color(0xFF42A5F5),
      });
    });
  }

  void _addInstallment(String id, double amount) {
    setState(() {
      final index = _debtItems.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        final currentPaid = _debtItems[index]['paid'] as double;
        final totalAmt = _debtItems[index]['amount'] as double;
        _debtItems[index]['paid'] = (currentPaid + amount).clamp(0.0, totalAmt);
      }
    });
  }

  void _removeRecord(String id) {
    setState(() {
      _debtItems.removeWhere((item) => item['id'] == id);
    });
  }

  void _showAddSheet() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final dateController = TextEditingController();
    bool isDebtChoice = _showDebts;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF0F172A) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subColor = isDark ? Colors.white54 : Colors.black54;

        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                      'Tambah Catatan Utang / Piutang',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Type selector
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
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Teman / Lembaga',
                        labelStyle: TextStyle(color: subColor),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Jumlah Uang',
                        labelStyle: TextStyle(color: subColor),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: dateController,
                      decoration: InputDecoration(
                        labelText: 'Tanggal (e.g. 19 Mei 2026)',
                        labelStyle: TextStyle(color: subColor),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          final name = nameController.text;
                          final amount = double.tryParse(amountController.text) ?? 0.0;
                          final date = dateController.text;
                          if (name.isNotEmpty && amount > 0) {
                            _addRecord(name, amount, isDebtChoice, date);
                            Navigator.pop(context);
                          }
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
            );
          },
        );
      },
    );
  }

  void _showInstallmentSheet(String itemId, String name) {
    final amtController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF0F172A) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subColor = isDark ? Colors.white54 : Colors.black54;

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
                  'Catat Cicilan / Angsuran',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pembayaran cicilan untuk "$name"',
                  style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: amtController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah Pembayaran',
                    labelStyle: TextStyle(color: subColor),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D179),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      final amount = double.tryParse(amtController.text) ?? 0.0;
                      if (amount > 0) {
                        _addInstallment(itemId, amount);
                        Navigator.pop(context);
                      }
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

    // Filter items based on the active tab
    final filteredItems = _debtItems.where((item) => item['isDebt'] == _showDebts).toList();

    double totalAmount = 0.0;
    double totalPaid = 0.0;
    for (var item in filteredItems) {
      totalAmount += item['amount'] as double;
      totalPaid += item['paid'] as double;
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

              // Tab controller row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showDebts = true),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _showDebts ? const Color(0xFF1E293B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Utang Saya',
                          style: TextStyle(
                            color: _showDebts ? Colors.white : subTextColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showDebts = false),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_showDebts ? const Color(0xFF1E293B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Piutang Saya',
                          style: TextStyle(
                            color: !_showDebts ? Colors.white : subTextColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocale.formatCurrency(totalRemaining, '$currency '),
                          style: TextStyle(
                            color: _showDebts ? const Color(0xFFFF7043) : const Color(0xFF42A5F5),
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (_showDebts ? const Color(0xFFFF7043) : const Color(0xFF42A5F5)).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 16),

              filteredItems.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          children: [
                            Icon(Icons.payment_rounded, size: 64, color: subTextColor.withValues(alpha: 0.2)),
                            const SizedBox(height: 12),
                            Text('Belum ada catatan di sini', style: TextStyle(color: mainTextColor, fontSize: 14)),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: filteredItems.map((item) {
                        final color = item['color'] as Color;
                        final paid = item['paid'] as double;
                        final total = item['amount'] as double;
                        final itemProgress = total > 0 ? (paid / total).clamp(0.0, 1.0) : 0.0;
                        final isSettled = itemProgress >= 1.0;

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
                                      color: isSettled ? const Color(0xFF00D179).withValues(alpha: 0.12) : color.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isSettled ? Icons.check_circle_rounded : (_showDebts ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded),
                                      color: isSettled ? const Color(0xFF00D179) : color,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'] as String,
                                          style: TextStyle(
                                            color: mainTextColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                            decoration: isSettled ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Dipinjam: ${item['date']}',
                                          style: TextStyle(
                                            color: subTextColor,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeRecord(item['id'] as String),
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: subTextColor.withValues(alpha: 0.4),
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Terbayar: ${AppLocale.formatCurrency(paid, '$currency ')} / ${AppLocale.formatCurrency(total, '$currency ')}',
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
                                      color: isSettled ? const Color(0xFF00D179) : color,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(isSettled ? const Color(0xFF00D179) : color),
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
                                      side: BorderSide(color: color.withValues(alpha: 0.3)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () => _showInstallmentSheet(item['id'] as String, item['name'] as String),
                                    child: Text(
                                      _showDebts ? 'Bayar Cicilan' : 'Terima Pembayaran',
                                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
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
        onPressed: _showAddSheet,
        backgroundColor: const Color(0xFF1E293B),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
