import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/savings_target.dart';
import '../main.dart';

class SavingsTargetsScreen extends StatefulWidget {
  const SavingsTargetsScreen({super.key});

  @override
  State<SavingsTargetsScreen> createState() => _SavingsTargetsScreenState();
}

class _SavingsTargetsScreenState extends State<SavingsTargetsScreen> {
  // Predefined colors & icons for new saving target creation
  final List<Color> _availableColors = [
    const Color(0xFF3B82F6), // Sapphire Blue
    const Color(0xFF10B981), // Emerald Green
    const Color(0xFFF59E0B), // Amber Yellow
    const Color(0xFFEC4899), // Pink
    const Color(0xFF8B5CF6), // Violet
    const Color(0xFFEF4444), // Red
    const Color(0xFF14B8A6), // Teal
  ];

  final List<IconData> _availableIcons = [
    Icons.savings_rounded,
    Icons.tablet_mac_rounded,
    Icons.beach_access_rounded,
    Icons.shield_rounded,
    Icons.directions_car_rounded,
    Icons.home_rounded,
    Icons.laptop_mac_rounded,
    Icons.flight_takeoff_rounded,
    Icons.favorite_rounded,
  ];

  void _showAddSheet() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    DateTime? selectedDate;
    Color selectedColor = _availableColors[0];
    IconData selectedIcon = _availableIcons[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), // Less rounded as requested
                ),
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Tambah Target Tabungan',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Name Input
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Nama Keinginan / Target',
                          labelStyle: TextStyle(color: subColor, fontSize: 13),
                          filled: true,
                          fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10), // Clean, less rounded
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        style: TextStyle(color: textColor, fontSize: 14),
                      ),
                      const SizedBox(height: 12),

                      // Target Amount Input
                      TextField(
                        controller: targetController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Target Jumlah Tabungan',
                          labelStyle: TextStyle(color: subColor, fontSize: 13),
                          filled: true,
                          fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        style: TextStyle(color: textColor, fontSize: 14),
                      ),
                      const SizedBox(height: 12),

                      // Optional Date Picker Row (Customized)
                      InkWell(
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? now,
                            firstDate: now,
                            lastDate: DateTime(now.year + 50),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  dialogTheme: DialogThemeData(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setSheetState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_month_rounded, size: 18, color: Theme.of(context).primaryColor),
                                  const SizedBox(width: 12),
                                  Text(
                                    selectedDate != null
                                        ? DateFormat('dd MMMM yyyy').format(selectedDate!)
                                        : 'Tanggal Berakhir (Opsional)',
                                    style: TextStyle(
                                      color: selectedDate != null ? textColor : subColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              if (selectedDate != null)
                                GestureDetector(
                                  onTap: () {
                                    setSheetState(() {
                                      selectedDate = null;
                                    });
                                  },
                                  child: Icon(Icons.clear_rounded, size: 18, color: subColor),
                                )
                              else
                                Icon(Icons.chevron_right_rounded, size: 18, color: subColor),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Color selector
                      Text(
                        'Pilih Warna',
                        style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _availableColors.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, idx) {
                            final col = _availableColors[idx];
                            final isSel = selectedColor == col;
                            return GestureDetector(
                              onTap: () => setSheetState(() => selectedColor = col),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: col,
                                  shape: BoxShape.circle,
                                  border: isSel
                                      ? Border.all(color: textColor, width: 2)
                                      : null,
                                ),
                                child: isSel
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Icon selector
                      Text(
                        'Pilih Ikon',
                        style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _availableIcons.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, idx) {
                            final ic = _availableIcons[idx];
                            final isSel = selectedIcon == ic;
                            return GestureDetector(
                              onTap: () => setSheetState(() => selectedIcon = ic),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(8),
                                  border: isSel
                                      ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                                      : null,
                                ),
                                child: Icon(ic, color: isSel ? Theme.of(context).primaryColor : subColor, size: 20),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            final title = titleController.text.trim();
                            final targetVal = double.tryParse(targetController.text) ?? 0.0;
                            if (title.isNotEmpty && targetVal > 0) {
                              Provider.of<AppProvider>(context, listen: false).addSavingsTarget(
                                title: title,
                                targetAmount: targetVal,
                                targetDate: selectedDate,
                                color: selectedColor,
                                icon: selectedIcon,
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Nama target & target jumlah tabungan harus diisi dengan benar!'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Buat Target',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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

  void _showDepositWithdrawSheet(SavingsTarget target) {
    final amountController = TextEditingController();
    bool isDeposit = true; // Setor vs Tarik
    String? selectedWalletId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            final provider = Provider.of<AppProvider>(context);
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final sheetBg = isDark ? const Color(0xFF0F172A) : Colors.white;
            final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
            final subColor = isDark ? Colors.white54 : Colors.black54;
            final currency = provider.currencySymbol;

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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Kelola Celengan',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    Text(
                      target.title,
                      style: TextStyle(
                        color: subColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Deposit / Withdraw Switch
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() => isDeposit = true),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isDeposit
                                    ? const Color(0xFF00D179).withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDeposit ? const Color(0xFF00D179) : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                'Setor Tabungan',
                                style: TextStyle(
                                  color: isDeposit ? const Color(0xFF00D179) : subColor,
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
                            onTap: () => setSheetState(() => isDeposit = false),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isDeposit
                                    ? Colors.redAccent.withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: !isDeposit ? Colors.redAccent : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                'Tarik Uang',
                                style: TextStyle(
                                  color: !isDeposit ? Colors.redAccent : subColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Wallet Dropdown Selector
                    Text(
                      isDeposit ? 'Dompet Sumber (Potong Saldo)' : 'Dompet Tujuan (Masuk Saldo)',
                      style: TextStyle(color: subColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedWalletId,
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      style: TextStyle(color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: provider.wallets.map((w) {
                        return DropdownMenuItem<String>(
                          value: w.id,
                          child: Row(
                            children: [
                              Icon(w.icon, color: w.color, size: 16),
                              const SizedBox(width: 8),
                              Text(w.name, style: TextStyle(color: textColor, fontSize: 13)),
                              const SizedBox(width: 4),
                              Text(
                                '(${AppLocale.formatCurrency(w.balance, '$currency ')})',
                                style: TextStyle(color: subColor, fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setSheetState(() {
                          selectedWalletId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Amount Input
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Jumlah Uang',
                        labelStyle: TextStyle(color: subColor, fontSize: 13),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      style: TextStyle(color: textColor, fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDeposit ? const Color(0xFF00D179) : Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          final amount = double.tryParse(amountController.text) ?? 0.0;
                          if (amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Masukkan jumlah uang yang valid!')),
                            );
                            return;
                          }
                          if (selectedWalletId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pilih dompet terlebih dahulu!')),
                            );
                            return;
                          }

                          if (isDeposit) {
                            // Check wallet balance
                            final wallet = provider.wallets.firstWhere((w) => w.id == selectedWalletId);
                            if (wallet.balance < amount) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Peringatan: Saldo dompet tidak mencukupi, tetapi transaksi tetap dicatat.'),
                                  backgroundColor: Colors.amber,
                                ),
                              );
                            }

                            provider.depositToSavingsTarget(
                              targetId: target.id,
                              amount: amount,
                              walletId: selectedWalletId!,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Berhasil menyetor ${AppLocale.formatCurrency(amount, '$currency ')}!'),
                                backgroundColor: const Color(0xFF00D179),
                              ),
                            );
                          } else {
                            // Withdraw check: cannot exceed target saved amount
                            if (amount > target.savedAmount) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Jumlah penarikan melebihi dana terkumpul (${AppLocale.formatCurrency(target.savedAmount, '$currency ')})!'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            provider.withdrawFromSavingsTarget(
                              targetId: target.id,
                              amount: amount,
                              walletId: selectedWalletId!,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Berhasil menarik ${AppLocale.formatCurrency(amount, '$currency ')}!'),
                                backgroundColor: Colors.teal,
                              ),
                            );
                          }
                        },
                        child: Text(
                          isDeposit ? 'Konfirmasi Setor' : 'Konfirmasi Tarik',
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

  void _showDeleteConfirm(SavingsTarget target) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subColor = isDark ? Colors.white70 : const Color(0xFF64748B);

        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Hapus Celengan?',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus celengan "${target.title}"? Riwayat setoran tidak akan dihapus, tetapi catatan target tabungan ini akan hilang.',
            style: TextStyle(color: subColor, fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: subColor)),
            ),
            TextButton(
              onPressed: () {
                Provider.of<AppProvider>(context, listen: false).deleteSavingsTarget(target.id);
                Navigator.pop(context);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
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

    double totalTarget = 0.0;
    double totalSaved = 0.0;
    for (var t in provider.savingsTargets) {
      totalTarget += t.targetAmount;
      totalSaved += t.savedAmount;
    }

    final overallProgress = totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Target Tabungan',
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

              // Total target card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(14), // Sharp / less rounded as requested
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Terkumpul Celengan',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocale.formatCurrency(totalSaved, '$currency '),
                          style: TextStyle(
                            color: mainTextColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D179).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(overallProgress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Color(0xFF00D179),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: overallProgress,
                        backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D179)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Target Akumulasi: ${AppLocale.formatCurrency(totalTarget, '$currency ')}',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Celengan Aktif',
                style: TextStyle(
                  color: mainTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 12),

              provider.savingsTargets.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          children: [
                            Icon(Icons.savings_rounded, size: 48, color: subTextColor.withValues(alpha: 0.2)),
                            const SizedBox(height: 12),
                            Text('Belum ada target tabungan', style: TextStyle(color: mainTextColor, fontSize: 13)),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: provider.savingsTargets.map((t) {
                        final color = t.color;
                        final saved = t.savedAmount;
                        final target = t.targetAmount;
                        final progress = target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;
                        final isFinished = t.isAchieved;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(12), // clean / less rounded
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      t.icon,
                                      color: color,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                t.title,
                                                style: TextStyle(
                                                  color: mainTextColor,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 13,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (isFinished)
                                              Container(
                                                margin: const EdgeInsets.only(left: 6),
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF00D179).withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'Tercapai',
                                                  style: TextStyle(color: Color(0xFF00D179), fontSize: 9, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          t.targetDate != null
                                              ? 'Target: ${DateFormat('dd MMM yyyy').format(t.targetDate!)}'
                                              : 'Tanpa Batas Tanggal',
                                          style: TextStyle(
                                            color: subTextColor,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _showDeleteConfirm(t),
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: subTextColor.withValues(alpha: 0.4),
                                      size: 18,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${AppLocale.formatCurrency(saved, '$currency ')} / ${AppLocale.formatCurrency(target, '$currency ')}',
                                    style: TextStyle(
                                      color: mainTextColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  Text(
                                    '${(progress * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      color: isFinished ? const Color(0xFF00D179) : color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.04),
                                  valueColor: AlwaysStoppedAnimation<Color>(isFinished ? const Color(0xFF00D179) : color),
                                  minHeight: 5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 32,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: color.withValues(alpha: 0.3)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () => _showDepositWithdrawSheet(t),
                                  child: Text(
                                    'Setor / Tarik Dana',
                                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ),
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
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}
