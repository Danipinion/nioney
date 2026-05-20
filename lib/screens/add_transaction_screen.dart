import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';

import '../models/transaction.dart';
class AddTransactionScreen extends StatefulWidget {
  final Transaction? editItem;
  const AddTransactionScreen({super.key, this.editItem});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  int _transactionTypeIndex = 0; // 0: Pengeluaran, 1: Pemasukan, 2: Transfer
  String? _selectedCategoryId;
  String? _selectedWalletId;
  DateTime _selectedDate = DateTime.now();

  String _amountStr = '0';
  String _selectedSubCategory = '';
  bool _titipBayar = false;
  bool _showOperators = false;

  // Split Expense & Reimbursement State
  double _reimburseAmount = 0.0;
  double _myShareAmount = 0.0;
  String _reimburseStr = '0';
  String _myShareStr = '0';
  int _activeAmountField = 0; // 0: Total, 1: Reimburse, 2: My Share

  String? _destinationWalletId;

  void _syncSplits() {
    final double totalAmount = double.tryParse(_amountStr.replaceAll('.', '').replaceAll(' ', '')) ?? 0.0;
    if (_activeAmountField == 0) {
      _reimburseAmount = totalAmount;
      _myShareAmount = 0.0;
      _reimburseStr = _reimburseAmount.toInt().toString();
      _myShareStr = '0';
    } else if (_activeAmountField == 1) {
      final double parsedReimburse = double.tryParse(_reimburseStr.replaceAll('.', '').replaceAll(' ', '')) ?? 0.0;
      if (parsedReimburse > totalAmount) {
        _reimburseAmount = totalAmount;
        _reimburseStr = totalAmount.toInt().toString();
      } else {
        _reimburseAmount = parsedReimburse;
      }
      _myShareAmount = totalAmount - _reimburseAmount;
      _myShareStr = _myShareAmount.toInt().toString();
    } else if (_activeAmountField == 2) {
      final double parsedMyShare = double.tryParse(_myShareStr.replaceAll('.', '').replaceAll(' ', '')) ?? 0.0;
      if (parsedMyShare > totalAmount) {
        _myShareAmount = totalAmount;
        _myShareStr = totalAmount.toInt().toString();
      } else {
        _myShareAmount = parsedMyShare;
      }
      _reimburseAmount = totalAmount - _myShareAmount;
      _reimburseStr = _reimburseAmount.toInt().toString();
    }
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      if (widget.editItem != null) {
        final tx = widget.editItem!;
        setState(() {
          _transactionTypeIndex = tx.categoryId == 'sys_transfer' ? 2 : (tx.isExpense ? 0 : 1);
          _selectedCategoryId = tx.categoryId;
          _selectedWalletId = tx.walletId;
          _selectedDate = tx.date;
          _amountStr = tx.amount.toInt().toString();
          _titleController.text = tx.title;
          _noteController.text = tx.note;
          
          if (provider.wallets.isNotEmpty) {
            _destinationWalletId = provider.wallets.first.id;
          }
          _syncSplits();
        });
      } else {
        if (provider.wallets.isNotEmpty) {
          setState(() {
            _selectedWalletId = provider.wallets.first.id;
            if (provider.wallets.length > 1) {
              _destinationWalletId = provider.wallets[1].id;
            } else {
              _destinationWalletId = provider.wallets.first.id;
            }
          });
        }
        _updateCategorySelection(provider);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _updateCategorySelection(AppProvider provider) {
    final bool isExpense = _transactionTypeIndex == 0 || _transactionTypeIndex == 2;
    final filtered = provider.categories
        .where((c) => c.isExpense == isExpense)
        .toList();
    if (filtered.isNotEmpty) {
      setState(() {
        _selectedCategoryId = filtered.first.id;
        _selectedSubCategory = '';
      });
    }
  }

  void _selectDate(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final headerBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final pickerBgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    
    DateTime tempPickedDate = _selectedDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setPickerState) {
            return Container(
              decoration: BoxDecoration(
                color: pickerBgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: headerBgColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          tempPickedDate.year.toString(),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = tempPickedDate;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Selesai',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 240,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        brightness: isDark ? Brightness.dark : Brightness.light,
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.dateAndTime,
                        initialDateTime: _selectedDate,
                        minimumDate: DateTime(2020),
                        maximumDate: DateTime(2035),
                        onDateTimeChanged: (DateTime newDate) {
                          setPickerState(() {
                            tempPickedDate = newDate;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Future<void> _submitData() async {
    final hasOperators = _amountStr.contains('+') || _amountStr.contains('-') || _amountStr.contains('x') || _amountStr.contains('÷');
    if (hasOperators) {
      _performCalculation();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hasil perhitungan telah diperbarui. Ketuk done sekali lagi untuk menyimpan.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final parsedAmount = double.tryParse(_amountStr.replaceAll('.', '')) ?? 0.0;
    if (parsedAmount <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nominal jumlah terlebih dahulu'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final provider = Provider.of<AppProvider>(context, listen: false);

    if (_transactionTypeIndex == 2) {
      if (_selectedWalletId == null || _destinationWalletId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih dompet asal dan dompet tujuan'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (_selectedWalletId == _destinationWalletId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dompet asal dan tujuan tidak boleh sama'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    } else {
      if (_selectedCategoryId == null || _selectedWalletId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih kategori dan dompet sumber'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    String noteText = _noteController.text.trim();
    if (_titipBayar && _transactionTypeIndex == 0) {
      final formattedReimburse = _formatAmount(_reimburseAmount.toInt().toString());
      final formattedBeban = _formatAmount(_myShareAmount.toInt().toString());
      final splitNote = 'Reimburse: Rp $formattedReimburse | Beban: Rp $formattedBeban';
      noteText = noteText.isEmpty ? '[$splitNote]' : '[$splitNote] $noteText';
    }

    if (_transactionTypeIndex == 2) {
      final sourceWallet = provider.wallets.firstWhere((w) => w.id == _selectedWalletId);
      final destWallet = provider.wallets.firstWhere((w) => w.id == _destinationWalletId);

      final sourceTitle = 'Transfer ke ${destWallet.name}';
      final destTitle = 'Transfer dari ${sourceWallet.name}';

      if (widget.editItem != null) {
        // Warning: Edit transfer is not fully supported for two sides simultaneously, so we just update the source transaction if edited
        await provider.updateTransaction(Transaction(
          id: widget.editItem!.id,
          title: sourceTitle,
          amount: parsedAmount,
          isExpense: true,
          categoryId: 'sys_transfer',
          walletId: _selectedWalletId!,
          date: _selectedDate,
          note: noteText,
        ));
      } else {
        await provider.addTransaction(
          title: sourceTitle,
          amount: parsedAmount,
          isExpense: true,
          categoryId: 'sys_transfer',
          walletId: _selectedWalletId!,
          date: _selectedDate,
          note: noteText,
        );
      }

      if (widget.editItem == null) {
        await provider.addTransaction(
          title: destTitle,
          amount: parsedAmount,
          isExpense: false,
          categoryId: 'sys_transfer',
          walletId: _destinationWalletId!,
          date: _selectedDate,
          note: noteText,
        );
      }
    } else {
      String finalTitle = _titleController.text.trim();
      if (finalTitle.isEmpty) {
        finalTitle = _selectedSubCategory.isNotEmpty ? _selectedSubCategory : 'Transaksi Tanpa Judul';
      }

      await provider.addTransaction(
        title: finalTitle,
        amount: parsedAmount,
        isExpense: _transactionTypeIndex == 0,
        categoryId: _selectedCategoryId!,
        walletId: _selectedWalletId!,
        date: _selectedDate,
        note: noteText,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  double _evaluateExpression(String expr) {
    String cleanExpr = expr.replaceAll('x', '*').replaceAll('÷', '/').replaceAll(' ', '');
    try {
      final RegExp regExp = RegExp(r'(\d+\.?\d*)|([\+\-\*\/])');
      final matches = regExp.allMatches(cleanExpr);
      if (matches.isEmpty) return 0.0;

      List<double> numbers = [];
      List<String> operators = [];

      for (var m in matches) {
        String token = m.group(0)!;
        if (token == '+' || token == '-' || token == '*' || token == '/') {
          operators.add(token);
        } else {
          numbers.add(double.tryParse(token) ?? 0.0);
        }
      }

      if (numbers.isEmpty) return 0.0;

      int i = 0;
      while (i < operators.length) {
        if (operators[i] == '*' || operators[i] == '/') {
          double left = numbers[i];
          double right = i + 1 < numbers.length ? numbers[i + 1] : 0.0;
          double res = 0.0;
          if (operators[i] == '*') {
            res = left * right;
          } else {
            res = right != 0.0 ? left / right : 0.0;
          }
          numbers[i] = res;
          if (i + 1 < numbers.length) numbers.removeAt(i + 1);
          operators.removeAt(i);
        } else {
          i++;
        }
      }

      double total = numbers[0];
      for (int j = 0; j < operators.length; j++) {
        double nextVal = j + 1 < numbers.length ? numbers[j + 1] : 0.0;
        if (operators[j] == '+') {
          total += nextVal;
        } else if (operators[j] == '-') {
          total -= nextVal;
        }
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }

  void _performCalculation() {
    String targetStr = _activeAmountField == 0
        ? _amountStr
        : (_activeAmountField == 1 ? _reimburseStr : _myShareStr);

    final result = _evaluateExpression(targetStr);
    setState(() {
      String finalResult = '';
      if (result == result.toInt()) {
        finalResult = result.toInt().toString();
      } else {
        finalResult = result.toStringAsFixed(1);
        if (finalResult.endsWith('.0')) {
          finalResult = finalResult.substring(0, finalResult.length - 2);
        }
      }

      if (_activeAmountField == 0) {
        _amountStr = finalResult;
      } else if (_activeAmountField == 1) {
        _reimburseStr = finalResult;
      } else {
        _myShareStr = finalResult;
      }

      _syncSplits();
    });
  }

  Widget _buildOperatorIconBtn({
    IconData? icon,
    String? label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: color, size: 18)
              : Text(
                  label!,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  void _onKeyboardTap(String value) {
    setState(() {
      String targetStr = _activeAmountField == 0
          ? _amountStr
          : (_activeAmountField == 1 ? _reimburseStr : _myShareStr);

      if (targetStr == '0') {
        if (value != '0' && value != '000' && value != '.') {
          targetStr = value;
        } else if (value == '.') {
          targetStr = '0.';
        }
      } else {
        if (value == '.') {
          final lastPart = targetStr.split(RegExp(r'[\+\-\*\/x÷]')).last.trim();
          if (!lastPart.contains('.')) {
            targetStr += '.';
          }
        } else {
          targetStr += value;
        }
      }

      if (_activeAmountField == 0) {
        _amountStr = targetStr;
      } else if (_activeAmountField == 1) {
        _reimburseStr = targetStr;
      } else {
        _myShareStr = targetStr;
      }

      _syncSplits();
    });
  }

  void _onBackspace() {
    setState(() {
      String targetStr = _activeAmountField == 0
          ? _amountStr
          : (_activeAmountField == 1 ? _reimburseStr : _myShareStr);

      if (targetStr.length > 1) {
        if (targetStr.endsWith(' ')) {
          targetStr = targetStr.trimRight();
          targetStr = targetStr.substring(0, targetStr.length - 1).trimRight();
        } else {
          targetStr = targetStr.substring(0, targetStr.length - 1);
        }
        if (targetStr.isEmpty) targetStr = '0';
      } else {
        targetStr = '0';
      }

      if (_activeAmountField == 0) {
        _amountStr = targetStr;
      } else if (_activeAmountField == 1) {
        _reimburseStr = targetStr;
      } else {
        _myShareStr = targetStr;
      }

      _syncSplits();
    });
  }

  void _onClear() {
    setState(() {
      if (_activeAmountField == 0) {
        _amountStr = '0';
      } else if (_activeAmountField == 1) {
        _reimburseStr = '0';
      } else {
        _myShareStr = '0';
      }
      _showOperators = false;
      _syncSplits();
    });
  }

  String _formatAmount(String value) {
    if (value.isEmpty || value == '0') return '0';

    final hasOperators = value.contains('+') || value.contains('-') || value.contains('x') || value.contains('÷');
    if (!hasOperators) {
      final n = double.tryParse(value.replaceAll('.', '')) ?? 0;
      final formatter = NumberFormat('#,###', 'id_ID');
      return formatter.format(n);
    }

    final RegExp pattern = RegExp(r'(\d+\.?\d*)|([^\d\.]+)');
    final matches = pattern.allMatches(value);

    StringBuffer sb = StringBuffer();
    for (var m in matches) {
      String token = m.group(0)!;
      if (token.contains('+') || token.contains('-') || token.contains('x') || token.contains('÷') || token.trim().isEmpty) {
        sb.write(token);
      } else {
        final cleanNum = token.replaceAll('.', '');
        final n = double.tryParse(cleanNum) ?? 0;
        final formatter = NumberFormat('#,###', 'id_ID');
        sb.write(formatter.format(n));
      }
    }
    return sb.toString();
  }

  String _getFormattedDateLabel() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final monthStr = months[_selectedDate.month - 1];
    final dayStr = _selectedDate.day.toString();
    final timeStr = DateFormat('HH:mm').format(_selectedDate);
    return '$monthStr $dayStr\n$timeStr';
  }

  List<Map<String, dynamic>> _getSubCategories(AppProvider provider, String categoryId) {
    final subList = provider.getSubCategoriesForCategory(categoryId);
    if (subList.isEmpty) {
      return [
        {'name': 'Umum', 'icon': Icons.payments_outlined},
        {'name': 'Pribadi', 'icon': Icons.person_outline_rounded},
        {'name': 'Lain-lain', 'icon': Icons.more_horiz_rounded},
      ];
    }
    return subList.map((name) => {'name': name, 'icon': Icons.circle_outlined}).toList();
  }

  Widget _buildKey({
    required Widget child,
    required Color bgColor,
    required VoidCallback onTap,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Center(
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  void _showWalletSelectionSheet(BuildContext context, AppProvider provider, {required bool isSource}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSource ? 'Pilih Dompet Asal' : 'Pilih Dompet Tujuan',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.wallets.length,
                  itemBuilder: (context, index) {
                    final wallet = provider.wallets[index];
                    final isSelected = isSource
                        ? _selectedWalletId == wallet.id
                        : _destinationWalletId == wallet.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? wallet.color.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? wallet.color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            if (isSource) {
                              _selectedWalletId = wallet.id;
                            } else {
                              _destinationWalletId = wallet.id;
                            }
                          });
                          Navigator.pop(context);
                        },
                        leading: Icon(wallet.icon, color: wallet.color),
                        title: Text(
                          wallet.name,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: wallet.color)
                            : null,
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final mutedTextColor = isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF94A3B8);
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04);
    final inputBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    final filteredCategories = provider.categories
        .where((c) => c.isExpense == (_transactionTypeIndex == 0 || _transactionTypeIndex == 2) && !c.id.startsWith('sys_'))
        .toList();

    final activeMainCategory = filteredCategories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => filteredCategories.isNotEmpty ? filteredCategories.first : filteredCategories[0],
    );

    final subCategories = _getSubCategories(provider, activeMainCategory.id);

    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Handle Bar
            const SizedBox(height: 12),
            Container(
              height: 4,
              width: 50,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),

            // Top Segment Controls & Scanner Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _transactionTypeIndex = 0;
                                  _updateCategorySelection(provider);
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  color: _transactionTypeIndex == 0
                                      ? const Color(0xFF23354E)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    'Pengeluaran',
                                    style: TextStyle(
                                      color: _transactionTypeIndex == 0
                                          ? Colors.white
                                          : subTextColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _transactionTypeIndex = 1;
                                  _updateCategorySelection(provider);
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  color: _transactionTypeIndex == 1
                                      ? const Color(0xFF23354E)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    'Pemasukan',
                                    style: TextStyle(
                                      color: _transactionTypeIndex == 1
                                          ? Colors.white
                                          : subTextColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _transactionTypeIndex = 2;
                                  _updateCategorySelection(provider);
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  color: _transactionTypeIndex == 2
                                      ? const Color(0xFF23354E)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    'Transfer',
                                    style: TextStyle(
                                      color: _transactionTypeIndex == 2
                                          ? Colors.white
                                          : subTextColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 16),

            // Main Scrollable Fields Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Horizontal Category List View (Compact & Elegant like screenshot)
                    if (_transactionTypeIndex != 2) ...[
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, index) {
                            final cat = filteredCategories[index];
                            final isSelected = _selectedCategoryId == cat.id;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategoryId = cat.id;
                                  _selectedSubCategory = '';
                                });
                              },
                              child: Container(
                                width: 82,
                                margin: const EdgeInsets.only(right: 6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 48,
                                      width: 48,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? cat.color
                                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                                        shape: BoxShape.circle,
                                        border: isSelected
                                            ? Border.all(color: Colors.white, width: 2)
                                            : null,
                                      ),
                                      child: Icon(
                                        cat.icon,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      cat.name,
                                      style: TextStyle(
                                        color: isSelected ? textColor : subTextColor,
                                        fontSize: 10,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Horizontal Subcategory Pills Row
                      if (subCategories.isNotEmpty) ...[
                        SizedBox(
                          height: 38,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: subCategories.length,
                            itemBuilder: (context, index) {
                              final subCat = subCategories[index];
                              final isSelected = _selectedSubCategory == subCat['name'];
                              final activeColor = activeMainCategory.color;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSubCategory = subCat['name'];
                                    _titleController.text = subCat['name'];
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: inputBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? activeColor : borderCol,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        subCat['icon'],
                                        color: isSelected ? activeColor : subTextColor,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        subCat['name'],
                                        style: TextStyle(
                                          color: isSelected ? textColor : subTextColor,
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                    if (_transactionTypeIndex == 2) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderCol),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rincian Transfer Dompet',
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                // Left: Dompet Asal (Source)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _showWalletSelectionSheet(context, provider, isSource: true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: borderCol),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Dari Dompet',
                                            style: TextStyle(
                                              color: subTextColor,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                _selectedWalletId != null
                                                    ? provider.wallets.firstWhere((w) => w.id == _selectedWalletId).icon
                                                    : Icons.account_balance_wallet_rounded,
                                                color: _selectedWalletId != null
                                                    ? provider.wallets.firstWhere((w) => w.id == _selectedWalletId).color
                                                    : theme.primaryColor,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _selectedWalletId != null
                                                      ? provider.wallets.firstWhere((w) => w.id == _selectedWalletId).name
                                                      : 'Pilih Asal',
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Middle Transfer Arrow Icon
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: theme.primaryColor,
                                    size: 16,
                                  ),
                                ),
                                // Right: Dompet Tujuan (Destination)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _showWalletSelectionSheet(context, provider, isSource: false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: borderCol),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Ke Dompet',
                                            style: TextStyle(
                                              color: subTextColor,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                _destinationWalletId != null
                                                    ? provider.wallets.firstWhere((w) => w.id == _destinationWalletId).icon
                                                    : Icons.account_balance_wallet_rounded,
                                                color: _destinationWalletId != null
                                                    ? provider.wallets.firstWhere((w) => w.id == _destinationWalletId).color
                                                    : Colors.teal,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _destinationWalletId != null
                                                      ? provider.wallets.firstWhere((w) => w.id == _destinationWalletId).name
                                                      : 'Pilih Tujuan',
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Amount Text Display Section
                    Text(
                      'Jumlah',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Currency Rp dropdown pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                provider.currencySymbol,
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF23354E),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                color: isDark ? Colors.white70 : const Color(0xFF23354E),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Number
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _activeAmountField = 0;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _activeAmountField == 0
                                  ? theme.primaryColor.withValues(alpha: 0.05)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _activeAmountField == 0
                                    ? theme.primaryColor.withValues(alpha: 0.3)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatAmount(_amountStr),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 36,
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (_activeAmountField == 0)
                                  Container(
                                    margin: const EdgeInsets.only(left: 2),
                                    width: 2.5,
                                    height: 32,
                                    color: theme.primaryColor.withValues(alpha: 0.7),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Reimburse (Titip Bayar) switch card container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderCol),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Titip Bayar',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pisahkan menjadi pengeluaran & penggantian',
                                style: TextStyle(
                                  color: mutedTextColor,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          CupertinoSwitch(
                            value: _titipBayar,
                            activeColor: theme.primaryColor,
                            onChanged: (val) {
                              setState(() {
                                _titipBayar = val;
                                if (_titipBayar) {
                                  _activeAmountField = 1; // Focus to Reimburse field when switched ON!
                                  _syncSplits();
                                } else {
                                  _activeAmountField = 0; // Focus back to Total
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_titipBayar) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderCol),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rincian Beban Pembagian',
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // Card 1: Di-reimburse (Dititip)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _activeAmountField = 1;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _activeAmountField == 1
                                            ? theme.primaryColor.withValues(alpha: 0.08)
                                            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _activeAmountField == 1
                                              ? theme.primaryColor
                                              : borderCol,
                                          width: _activeAmountField == 1 ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Dititip (Reimburse)',
                                                style: TextStyle(
                                                  color: _activeAmountField == 1 ? theme.primaryColor : subTextColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_circle_down_rounded,
                                                color: _activeAmountField == 1 ? theme.primaryColor : subTextColor.withValues(alpha: 0.5),
                                                size: 14,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                'Rp ',
                                                style: TextStyle(
                                                  color: _activeAmountField == 1 ? textColor : subTextColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  _formatAmount(_reimburseStr),
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 15,
                                                    fontFamily: 'Outfit',
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (_activeAmountField == 1)
                                                Container(
                                                  margin: const EdgeInsets.only(left: 2),
                                                  width: 1.5,
                                                  height: 14,
                                                  color: theme.primaryColor,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Card 2: Beban Saya
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _activeAmountField = 2;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _activeAmountField == 2
                                            ? Colors.orange.withValues(alpha: 0.08)
                                            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _activeAmountField == 2
                                              ? Colors.orange
                                              : borderCol,
                                          width: _activeAmountField == 2 ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Beban Saya',
                                                style: TextStyle(
                                                  color: _activeAmountField == 2 ? Colors.orange : subTextColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Icon(
                                                Icons.person_outline_rounded,
                                                color: _activeAmountField == 2 ? Colors.orange : subTextColor.withValues(alpha: 0.5),
                                                size: 14,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                'Rp ',
                                                style: TextStyle(
                                                  color: _activeAmountField == 2 ? textColor : subTextColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  _formatAmount(_myShareStr),
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 15,
                                                    fontFamily: 'Outfit',
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (_activeAmountField == 2)
                                                Container(
                                                  margin: const EdgeInsets.only(left: 2),
                                                  width: 1.5,
                                                  height: 14,
                                                  color: Colors.orange,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Quick Split presets
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final double totalAmount = double.tryParse(_amountStr.replaceAll('.', '').replaceAll(' ', '')) ?? 0.0;
                                    setState(() {
                                      _reimburseAmount = totalAmount;
                                      _myShareAmount = 0.0;
                                      _reimburseStr = _reimburseAmount.toInt().toString();
                                      _myShareStr = '0';
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '100% Dititip',
                                      style: TextStyle(color: subTextColor, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    final double totalAmount = double.tryParse(_amountStr.replaceAll('.', '').replaceAll(' ', '')) ?? 0.0;
                                    setState(() {
                                      _reimburseAmount = totalAmount / 2;
                                      _myShareAmount = totalAmount / 2;
                                      _reimburseStr = _reimburseAmount.toInt().toString();
                                      _myShareStr = _myShareAmount.toInt().toString();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Bagi Dua (50:50)',
                                      style: TextStyle(color: subTextColor, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Title Input Box
                    Container(
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderCol),
                      ),
                      child: TextFormField(
                        controller: _titleController,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Judul',
                          hintStyle: TextStyle(color: mutedTextColor, fontSize: 13),
                          prefixIcon: Icon(Icons.description_outlined, color: subTextColor, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Note Input and Wallet Selector side-by-side Row
                    Row(
                      children: [
                        Expanded(
                          flex: _transactionTypeIndex == 2 ? 1 : 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderCol),
                            ),
                            child: TextFormField(
                              controller: _noteController,
                              style: TextStyle(color: textColor, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Tambah catatan...',
                                hintStyle: TextStyle(color: mutedTextColor, fontSize: 13),
                                prefixIcon: Icon(Icons.edit_note_rounded, color: subTextColor, size: 20),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                        if (_transactionTypeIndex != 2) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () => _showWalletSelectionSheet(context, provider, isSource: true),
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: inputBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderCol),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedWalletId != null
                                            ? provider.wallets.firstWhere((w) => w.id == _selectedWalletId).name
                                            : 'Pilih Dompet',
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: subTextColor,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Custom Bottom Grid Keyboard
            Container(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 20),
              child: Column(
                children: [
                  if (_showOperators)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildOperatorIconBtn(
                            icon: Icons.add,
                            color: theme.primaryColor,
                            onTap: () {
                              setState(() {
                                _amountStr += ' + ';
                                _showOperators = false;
                              });
                            },
                          ),
                          _buildOperatorIconBtn(
                            icon: Icons.remove,
                            color: Colors.orange,
                            onTap: () {
                              setState(() {
                                _amountStr += ' - ';
                                _showOperators = false;
                              });
                            },
                          ),
                          _buildOperatorIconBtn(
                            icon: Icons.close,
                            color: Colors.blue,
                            onTap: () {
                              setState(() {
                                _amountStr += ' x ';
                                _showOperators = false;
                              });
                            },
                          ),
                          _buildOperatorIconBtn(
                            label: '÷',
                            color: Colors.purple,
                            onTap: () {
                              setState(() {
                                _amountStr += ' ÷ ';
                                _showOperators = false;
                              });
                            },
                          ),
                          _buildOperatorIconBtn(
                            label: '=',
                            color: Colors.teal,
                            onTap: () {
                              _performCalculation();
                              setState(() {
                                _showOperators = false;
                              });
                            },
                          ),
                          _buildOperatorIconBtn(
                            label: 'C',
                            color: Colors.redAccent,
                            onTap: () {
                              setState(() {
                                _amountStr = '0';
                                _showOperators = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      _buildKey(
                        bgColor: inputBg,
                        onTap: () => _onKeyboardTap('1'),
                        child: Text('1', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _buildKey(
                        bgColor: inputBg,
                        onTap: () => _onKeyboardTap('2'),
                        child: Text('2', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _buildKey(
                        bgColor: inputBg,
                        onTap: () => _onKeyboardTap('3'),
                        child: Text('3', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _buildKey(
                        bgColor: isDark ? const Color(0xFF3F2022) : const Color(0xFFFEE2E2),
                        onTap: _onBackspace,
                        child: Icon(Icons.backspace_outlined, color: Colors.redAccent.shade400, size: 20),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildKey(
                        bgColor: inputBg,
                        onTap: () => _onKeyboardTap('4'),
                        child: Text('4', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _buildKey(
                        bgColor: inputBg,
                        onTap: () => _onKeyboardTap('5'),
                        child: Text('5', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _buildKey(
                        bgColor: inputBg,
                        onTap: () => _onKeyboardTap('6'),
                        child: Text('6', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _buildKey(
                        bgColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        onTap: () {
                          setState(() {
                            _showOperators = !_showOperators;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('+-', style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.w800, height: 1.0)),
                            Text('x=', style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.w800, height: 1.0)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildKey(
                        bgColor: inputBg,
                        onTap: () => _onKeyboardTap('7'),
                        child: Text('7', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _buildKey(
                        bgColor: inputBg,
                        onTap: () => _onKeyboardTap('8'),
                        child: Text('8', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _buildKey(
                        bgColor: inputBg,
                        onTap: () => _onKeyboardTap('9'),
                        child: Text('9', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _buildKey(
                        bgColor: inputBg,
                        onTap: () => _selectDate(context),
                        child: Text(
                          _getFormattedDateLabel(),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Outfit',
                            height: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildKey(
                        bgColor: inputBg,
                        onTap: () => _onKeyboardTap('.'),
                        child: Text('.', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _buildKey(
                        bgColor: inputBg,
                        onTap: () => _onKeyboardTap('0'),
                        child: Text('0', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _buildKey(
                        bgColor: inputBg,
                        onTap: () => _onKeyboardTap('000'),
                        child: Text('000', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _buildKey(
                        bgColor: const Color(0xFF23354E),
                        onTap: _submitData,
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
