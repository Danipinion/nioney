import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isExpense = true;
  String? _selectedCategoryId;
  String? _selectedWalletId;
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default select first wallet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      if (provider.wallets.isNotEmpty) {
        setState(() {
          _selectedWalletId = provider.wallets.first.id;
        });
      }
      _setDefaultCategory(provider);
    });
  }

  void _setDefaultCategory(AppProvider provider) {
    final filtered = provider.categories
        .where((c) => c.isExpense == _isExpense)
        .toList();
    if (filtered.isNotEmpty) {
      setState(() {
        _selectedCategoryId = filtered.first.id;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
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
                  // Header Row (Batal | Year | Selesai)
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
                  // Cupertino Date Picker Wheel
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
                        mode: CupertinoDatePickerMode.date,
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

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;

    final parsedAmount =
        double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    if (parsedAmount <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount greater than 0'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedCategoryId == null || _selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a category and wallet'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.addTransaction(
      title: _titleController.text.trim(),
      amount: parsedAmount,
      isExpense: _isExpense,
      categoryId: _selectedCategoryId!,
      walletId: _selectedWalletId!,
      date: _selectedDate,
      note: _noteController.text.trim(),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);

    final filteredCategories = provider.categories
        .where((c) => c.isExpense == _isExpense)
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Handle Bar for modal
            const SizedBox(height: 12),
            Container(
              height: 4,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Transaction',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Main Form Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle Expense / Income
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isExpense = true;
                                _setDefaultCategory(provider);
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isExpense
                                    ? const Color(
                                        0xFFFF7043,
                                      ).withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isExpense
                                      ? const Color(
                                          0xFFFF7043,
                                        ).withValues(alpha: 0.4)
                                      : Colors.white.withValues(alpha: 0.04),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Expense',
                                  style: TextStyle(
                                    color: _isExpense
                                        ? const Color(0xFFFF7043)
                                        : Colors.white60,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isExpense = false;
                                _setDefaultCategory(provider);
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isExpense
                                    ? const Color(
                                        0xFF66BB6A,
                                      ).withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: !_isExpense
                                      ? const Color(
                                          0xFF66BB6A,
                                        ).withValues(alpha: 0.4)
                                      : Colors.white.withValues(alpha: 0.04),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Income',
                                  style: TextStyle(
                                    color: !_isExpense
                                        ? const Color(0xFF66BB6A)
                                        : Colors.white60,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Amount Input Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.04),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AMOUNT (${provider.currencySymbol})',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                provider.currencySymbol,
                                style: const TextStyle(
                                  color: Colors.white24,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w800,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    hintStyle: TextStyle(color: Colors.white24),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Enter amount';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title Input
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Transaction Title / Payee',
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 14,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: theme.primaryColor),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Category Selector Label
                    Text(
                      'SELECT CATEGORY',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Grid Categories List
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final cat = filteredCategories[index];
                        final isSelected = _selectedCategoryId == cat.id;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = cat.id;
                            });
                          },
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? cat.color.withValues(alpha: 0.18)
                                      : Colors.white.withValues(alpha: 0.03),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? cat.color
                                        : Colors.white.withValues(alpha: 0.06),
                                    width: isSelected ? 2 : 1.2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: cat.color.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 10,
                                            spreadRadius: -2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  cat.icon,
                                  color: isSelected
                                      ? cat.color
                                      : Colors.white54,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white38,
                                  fontSize: 9,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Wallet Selector Label
                    Text(
                      'SOURCE ACCOUNT / WALLET',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Horizontal Wallets Picker
                    SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: provider.wallets.length,
                        itemBuilder: (context, index) {
                          final wallet = provider.wallets[index];
                          final isSelected = _selectedWalletId == wallet.id;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedWalletId = wallet.id;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? wallet.color.withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? wallet.color
                                      : Colors.white.withValues(alpha: 0.06),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    wallet.icon,
                                    color: isSelected
                                        ? wallet.color
                                        : Colors.white54,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    wallet.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white54,
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Date Selection Card
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color: theme.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DATE',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'EEEE, dd MMMM yyyy',
                                      ).format(_selectedDate),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white30,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Notes Input
                    TextFormField(
                      controller: _noteController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Notes / Remarks (Optional)',
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 13,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: theme.primaryColor),
                        ),
                        filled: true,
                        fillColor: theme.cardColor.withValues(alpha: 0.2),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Submit Button
                    GestureDetector(
                      onTap: _submitData,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.25),
                              blurRadius: 16,
                              spreadRadius: -2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Save Transaction',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
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
