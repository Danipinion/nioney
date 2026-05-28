import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/savings_target.dart';
import '../models/wallet.dart';
import '../main.dart';

class SavingsTargetDetailScreen extends StatefulWidget {
  final String targetId;

  const SavingsTargetDetailScreen({super.key, required this.targetId});

  @override
  State<SavingsTargetDetailScreen> createState() =>
      _SavingsTargetDetailScreenState();
}

class _SavingsTargetDetailScreenState extends State<SavingsTargetDetailScreen> {
  void _showDepositWithdrawSheet(BuildContext context, SavingsTarget target) {
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
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
                      style: TextStyle(color: subColor, fontSize: 12),
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
                                    ? const Color(
                                        0xFF00D179,
                                      ).withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDeposit
                                      ? const Color(0xFF00D179)
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                'Setor Tabungan',
                                style: TextStyle(
                                  color: isDeposit
                                      ? const Color(0xFF00D179)
                                      : subColor,
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
                                  color: !isDeposit
                                      ? Colors.redAccent
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                'Tarik Uang',
                                style: TextStyle(
                                  color: !isDeposit
                                      ? Colors.redAccent
                                      : subColor,
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
                      isDeposit
                          ? 'Dompet Sumber (Potong Saldo)'
                          : 'Dompet Tujuan (Masuk Saldo)',
                      style: TextStyle(
                        color: subColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedWalletId,
                      dropdownColor: isDark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      style: TextStyle(color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.black.withValues(alpha: 0.015),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: provider.wallets.map((w) {
                        return DropdownMenuItem<String>(
                          value: w.id,
                          child: Row(
                            children: [
                              Icon(w.icon, color: w.color, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                w.name,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                ),
                              ),
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
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Jumlah Uang',
                        labelStyle: TextStyle(color: subColor, fontSize: 13),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.black.withValues(alpha: 0.015),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
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
                          backgroundColor: isDeposit
                              ? const Color(0xFF00D179)
                              : Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          final amount =
                              double.tryParse(amountController.text) ?? 0.0;
                          if (amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Masukkan jumlah uang yang valid!',
                                ),
                              ),
                            );
                            return;
                          }
                          if (selectedWalletId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pilih dompet terlebih dahulu!'),
                              ),
                            );
                            return;
                          }

                          if (isDeposit) {
                            // Check wallet balance
                            final wallet = provider.wallets.firstWhere(
                              (w) => w.id == selectedWalletId,
                            );
                            if (wallet.balance < amount) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Peringatan: Saldo dompet tidak mencukupi, tetapi transaksi tetap dicatat.',
                                  ),
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
                                content: Text(
                                  'Berhasil menyetor ${AppLocale.formatCurrency(amount, '$currency ')}!',
                                ),
                                backgroundColor: const Color(0xFF00D179),
                              ),
                            );
                          } else {
                            // Withdraw check: cannot exceed target saved amount
                            if (amount > target.savedAmount) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Jumlah penarikan melebihi dana terkumpul (${AppLocale.formatCurrency(target.savedAmount, '$currency ')})!',
                                  ),
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
                                content: Text(
                                  'Berhasil menarik ${AppLocale.formatCurrency(amount, '$currency ')}!',
                                ),
                                backgroundColor: Colors.teal,
                              ),
                            );
                          }
                        },
                        child: Text(
                          isDeposit ? 'Konfirmasi Setor' : 'Konfirmasi Tarik',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
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

  void _showDeleteConfirm(
    BuildContext context,
    AppProvider provider,
    SavingsTarget target,
  ) {
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
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
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
                provider.deleteSavingsTarget(target.id);
                // Go back to main screen since this target is deleted
                Navigator.pop(context); // Pop dialog
                Navigator.pop(context); // Pop detail screen
              },
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

    // Find the target or return a fallback if not found (e.g. during deletion transition)
    final targetList = provider.savingsTargets
        .where((t) => t.id == widget.targetId)
        .toList();
    if (targetList.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            'Target tidak ditemukan',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ),
      );
    }
    final target = targetList.first;

    final mainTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : const Color(0xFF64748B);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.05);
    final cardBgColor = isDark ? theme.cardColor : Colors.white;

    final saved = target.savedAmount;
    final targetAmt = target.targetAmount;
    final progress = targetAmt > 0 ? (saved / targetAmt).clamp(0.0, 1.0) : 0.0;
    final isFinished = target.isAchieved;

    // Filter transactions specifically belonging to this saving target
    // We map categoryId == 'sys_saving_target' and subCategory == target.title
    final targetTx = provider.transactions.where((tx) {
      return tx.categoryId == 'sys_saving_target' &&
          tx.subCategory == target.title;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          target.title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            fontFamily: 'Outfit',
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: mainTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () => _showDeleteConfirm(context, provider, target),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Main info header card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: target.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  target.icon,
                                  color: target.color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            target.title,
                                            style: TextStyle(
                                              color: mainTextColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              fontFamily: 'Outfit',
                                            ),
                                          ),
                                        ),
                                        if (isFinished)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF00D179,
                                              ).withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'Tercapai',
                                              style: TextStyle(
                                                color: Color(0xFF00D179),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      target.targetDate != null
                                          ? 'Batas Tanggal: ${DateFormat('dd MMMM yyyy').format(target.targetDate!)}'
                                          : 'Tanpa Batas Tanggal',
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Dana Terkumpul',
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                AppLocale.formatCurrency(saved, '$currency '),
                                style: TextStyle(
                                  color: mainTextColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: isFinished
                                      ? const Color(0xFF00D179)
                                      : target.color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.black.withValues(alpha: 0.04),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isFinished
                                    ? const Color(0xFF00D179)
                                    : target.color,
                              ),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Target Sasaran: ${AppLocale.formatCurrency(targetAmt, '$currency ')}',
                            style: TextStyle(color: subTextColor, fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00D179),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () =>
                                  _showDepositWithdrawSheet(context, target),
                              icon: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: const Text(
                                'Setor Uang',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.redAccent,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                if (saved <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Celengan Anda masih kosong!',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                _showDepositWithdrawSheet(context, target);
                              },
                              icon: const Icon(
                                Icons.remove_rounded,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                              label: const Text(
                                'Tarik Uang',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Transactions history title
                    Text(
                      'Riwayat Transaksi Celengan',
                      style: TextStyle(
                        color: mainTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 12),

                    targetTx.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 40.0,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.history_rounded,
                                    size: 40,
                                    color: subTextColor.withValues(alpha: 0.15),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Belum ada transaksi celengan',
                                    style: TextStyle(
                                      color: subTextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: targetTx.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final tx = targetTx[idx];
                              final wallet = provider.wallets.firstWhere(
                                (w) => w.id == tx.walletId,
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
                                  color: cardBgColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            (tx.isExpense
                                                    ? const Color(0xFF00D179)
                                                    : Colors.redAccent)
                                                .withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        tx.isExpense
                                            ? Icons.arrow_downward_rounded
                                            : Icons.arrow_upward_rounded,
                                        color: tx.isExpense
                                            ? const Color(0xFF00D179)
                                            : Colors.redAccent,
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
                                            tx.title,
                                            style: TextStyle(
                                              color: mainTextColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${DateFormat('dd MMM yyyy • HH:mm').format(tx.date)} • ${wallet.name}',
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
                                            ? const Color(0xFF00D179)
                                            : Colors.redAccent,
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
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
