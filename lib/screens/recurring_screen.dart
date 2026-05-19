import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/category.dart';
import '../main.dart';

class RecurringScreen extends StatefulWidget {
  const RecurringScreen({super.key});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  DateTime _selectedDate = DateTime(2026, 5, 19);
  DateTime _currentMonth = DateTime(2026, 5, 1);

  void _showCupertinoDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required ValueChanged<DateTime> onDateSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final headerBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final pickerBgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    
    DateTime tempPickedDate = initialDate;

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
                            onDateSelected(tempPickedDate);
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
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: initialDate,
                        minimumDate: firstDate,
                        maximumDate: lastDate,
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

  // Dynamic interactive recurring items
  final List<Map<String, dynamic>> _recurringItems = [
    {
      'id': '1',
      'title': 'Gaji Bulanan Utama',
      'amount': 8500000.0,
      'isExpense': false,
      'period': 'MONTHLY',
      'categoryName': 'Gaji',
      'categoryColor': const Color(0xFF00D179),
      'categoryIcon': Icons.payments_rounded,
      'walletName': 'Cash',
      'day': 1,
    },
    {
      'id': '2',
      'title': 'Netflix Premium',
      'amount': 186000.0,
      'isExpense': true,
      'period': 'MONTHLY',
      'categoryName': 'Hiburan',
      'categoryColor': const Color(0xFFEF5350),
      'categoryIcon': Icons.movie_filter_rounded,
      'walletName': 'Cash',
      'day': 19,
    },
    {
      'id': '3',
      'title': 'Spotify Family Plan',
      'amount': 86000.0,
      'isExpense': true,
      'period': 'MONTHLY',
      'categoryName': 'Hiburan',
      'categoryColor': const Color(0xFF66BB6A),
      'categoryIcon': Icons.music_note_rounded,
      'walletName': 'Cash',
      'day': 19,
    },
  ];

  void _addRecurringItem(
    String title,
    double amount,
    bool isExpense,
    String period,
    Category category,
    String walletName,
    DateTime startDate,
  ) {
    setState(() {
      _recurringItems.add({
        'id': DateTime.now().toString(),
        'title': title,
        'amount': amount,
        'isExpense': isExpense,
        'period': period.toUpperCase(),
        'categoryName': category.name,
        'categoryColor': category.color,
        'categoryIcon': category.icon,
        'walletName': walletName,
        'day': startDate.day,
      });
    });
  }

  void _updateRecurringItem(
    String id,
    String title,
    double amount,
    bool isExpense,
    String period,
    Category category,
    String walletName,
    DateTime startDate,
  ) {
    setState(() {
      final index = _recurringItems.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        _recurringItems[index] = {
          'id': id,
          'title': title,
          'amount': amount,
          'isExpense': isExpense,
          'period': period.toUpperCase(),
          'categoryName': category.name,
          'categoryColor': category.color,
          'categoryIcon': category.icon,
          'walletName': walletName,
          'day': startDate.day,
        };
      }
    });
  }

  void _deleteItem(String id) {
    setState(() {
      _recurringItems.removeWhere((item) => item['id'] == id);
    });
  }

  // ----------------------------------------------------
  // RENDER DYNAMIC CALENDAR GRID (MATCHING SCREENSHOT 1!)
  // ----------------------------------------------------
  Widget _buildCalendarGrid(bool isDark) {
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Calculations for the calendar
    final year = _currentMonth.year;
    final month = _currentMonth.month;

    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Weekday: 1 = Mon, 7 = Sun
    // How many blank cells from prev month?
    final startPadding = firstDayOfMonth.weekday - 1;

    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;
    final daysInPrevMonth = DateTime(prevYear, prevMonth + 1, 0).day;

    List<Widget> gridCells = [];

    // 1. Render Days of Week Headers
    for (var day in daysOfWeek) {
      gridCells.add(
        Center(
          child: Text(
            day,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // 2. Render Muted Days from Previous Month
    for (int i = startPadding - 1; i >= 0; i--) {
      final dayNum = daysInPrevMonth - i;
      gridCells.add(
        Center(
          child: Text(
            dayNum.toString(),
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.15),
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    // 3. Render Current Month Days
    for (int day = 1; day <= daysInMonth; day++) {
      final cellDate = DateTime(year, month, day);
      final isSelected = cellDate.year == _selectedDate.year &&
          cellDate.month == _selectedDate.month &&
          cellDate.day == _selectedDate.day;

      // Check if this day has any recurring items
      final hasItems = _recurringItems.any((item) => item['day'] == day);

      gridCells.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = cellDate;
            });
          },
          child: Center(
            child: isSelected
                ? Container(
                    width: 38,
                    height: 52,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.white38 : const Color(0xFF1E293B),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.toString(),
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.toString(),
                          style: TextStyle(
                            color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (hasItems) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white24 : Colors.black12,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.9,
      mainAxisSpacing: 8,
      crossAxisSpacing: 4,
      children: gridCells,
    );
  }

  // ----------------------------------------------------
  // SHOW ADD NEW RECURRING PAGE (MATCHING SCREENSHOT 2!)
  // ----------------------------------------------------
  void _showAddRecurringPage({Map<String, dynamic>? editItem}) {
    final isEditing = editItem != null;
    final titleController = TextEditingController(text: editItem?['title']);
    final amountController = TextEditingController(
      text: editItem != null ? (editItem['amount'] as double).toStringAsFixed(0) : '',
    );
    bool isExpenseChoice = editItem?['isExpense'] ?? true;
    Category? selectedCategory;
    String selectedFrequency = 'Monthly';
    if (editItem != null) {
      final period = editItem['period'] as String;
      if (period == 'DAILY') selectedFrequency = 'Daily';
      else if (period == 'WEEKLY') selectedFrequency = 'Weekly';
      else if (period == 'MONTHLY') selectedFrequency = 'Monthly';
      else if (period == 'YEARLY') selectedFrequency = 'Yearly';
    }
    String selectedWallet = editItem?['walletName'] ?? 'Cash';
    DateTime startDate = editItem != null
        ? DateTime(2026, 5, editItem['day'] as int)
        : DateTime(2026, 5, 19);
    DateTime? endDate = editItem?['endDate'] as DateTime?;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          final provider = Provider.of<AppProvider>(context);
          if (editItem != null) {
            selectedCategory = provider.categories.firstWhere(
              (cat) => cat.name.toLowerCase() == (editItem['categoryName'] as String).toLowerCase(),
              orElse: () => provider.categories.first,
            );
          } else {
            selectedCategory ??= provider.categories.first;
          }
          
          final List<String> walletNames = provider.wallets.isNotEmpty 
              ? provider.wallets.map((w) => w.name).toList()
              : ['Cash'];
              
          if (!walletNames.contains(selectedWallet)) {
            selectedWallet = walletNames.first;
          }

          return StatefulBuilder(
            builder: (context, setPageState) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
              final subColor = isDark ? Colors.white54 : Colors.black54;
              final inputBg = isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015);
              final borderCol = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05);

              return Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                  leading: IconButton(
                    icon: Icon(Icons.close_rounded, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    isEditing ? 'Ubah Transaksi Berulang' : 'Transaksi Berulang Baru',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Outfit',
                      fontSize: 16,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.check_rounded, color: textColor),
                      onPressed: () {
                        final title = titleController.text;
                        final amount = double.tryParse(amountController.text) ?? 0.0;
                        if (title.isNotEmpty && amount > 0) {
                          if (isEditing) {
                            _updateRecurringItem(
                              editItem['id'] as String,
                              title,
                              amount,
                              isExpenseChoice,
                              selectedFrequency,
                              selectedCategory!,
                              selectedWallet,
                              startDate,
                            );
                          } else {
                            _addRecurringItem(
                              title,
                              amount,
                              isExpenseChoice,
                              selectedFrequency,
                              selectedCategory!,
                              selectedWallet,
                              startDate,
                            );
                          }
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Toggle Income vs Expense (Flat buttons)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setPageState(() => isExpenseChoice = true),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isExpenseChoice ? const Color(0xFFEF5350).withValues(alpha: 0.12) : Colors.transparent,
                                  border: Border.all(color: isExpenseChoice ? const Color(0xFFEF5350) : borderCol),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Pengeluaran',
                                  style: TextStyle(
                                    color: isExpenseChoice ? const Color(0xFFEF5350) : textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setPageState(() => isExpenseChoice = false),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !isExpenseChoice ? const Color(0xFF00D179).withValues(alpha: 0.12) : Colors.transparent,
                                  border: Border.all(color: !isExpenseChoice ? const Color(0xFF00D179) : borderCol),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Pemasukan',
                                  style: TextStyle(
                                    color: !isExpenseChoice ? const Color(0xFF00D179) : textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 1. Jumlah Amount Input (Screnshot 2 Style)
                      Text(
                        'Jumlah',
                        style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  provider.currencySymbol,
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 16),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_drop_down, color: textColor, size: 18),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Outfit'),
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(color: subColor),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 16),

                      // 2. Judul
                      Text(
                        'Judul',
                        style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'e.g. Netflix Subscription',
                          hintStyle: TextStyle(color: subColor),
                          filled: true,
                          fillColor: inputBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. Category Selector (Requested!)
                      Text(
                        'Kategori perulangan',
                        style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Category>(
                            value: selectedCategory,
                            dropdownColor: Theme.of(context).cardColor,
                            isExpanded: true,
                            items: provider.categories.map((Category cat) {
                              return DropdownMenuItem<Category>(
                                value: cat,
                                child: Row(
                                  children: [
                                    Icon(cat.icon, color: cat.color, size: 18),
                                    const SizedBox(width: 10),
                                    Text(cat.name, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newCat) {
                              if (newCat != null) {
                                setPageState(() {
                                  selectedCategory = newCat;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 24),

                      // 5. Frekuensi & Tanggal Mulai (Screenshot 2)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Frekuensi',
                                  style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(16)),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedFrequency,
                                      dropdownColor: Theme.of(context).cardColor,
                                      isExpanded: true,
                                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                                      items: ['Daily', 'Weekly', 'Monthly', 'Yearly'].map((String val) {
                                        return DropdownMenuItem<String>(
                                          value: val,
                                          child: Text(val),
                                        );
                                      }).toList(),
                                      onChanged: (newVal) {
                                        if (newVal != null) {
                                          setPageState(() {
                                            selectedFrequency = newVal;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tanggal Mulai',
                                  style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    _showCupertinoDatePicker(
                                      context: context,
                                      initialDate: startDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2035),
                                      onDateSelected: (newDate) {
                                        setPageState(() {
                                          startDate = newDate;
                                        });
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(16)),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today_rounded, color: subColor, size: 14),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${startDate.day}/${startDate.month}/${startDate.year}',
                                          style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 6. Tanggal Berakhir (Screenshot 2)
                      Text(
                        'Tanggal Berakhir',
                        style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          _showCupertinoDatePicker(
                            context: context,
                            initialDate: endDate ?? startDate.add(const Duration(days: 30)),
                            firstDate: startDate,
                            lastDate: DateTime(2035),
                            onDateSelected: (newDate) {
                              setPageState(() {
                                endDate = newDate;
                              });
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_month_rounded, color: subColor, size: 16),
                                  const SizedBox(width: 12),
                                  Text(
                                    endDate == null
                                        ? 'Optional (Never ends)'
                                        : '${endDate!.day}/${endDate!.month}/${endDate!.year}',
                                    style: TextStyle(
                                      color: endDate == null ? subColor : textColor,
                                      fontSize: 13,
                                      fontWeight: endDate == null ? FontWeight.normal : FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              if (endDate != null)
                                GestureDetector(
                                  onTap: () {
                                    setPageState(() {
                                      endDate = null;
                                    });
                                  },
                                  child: Icon(Icons.clear_rounded, color: subColor, size: 16),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 7. Bayar dengan Dompet (Screenshot 2)
                      Text(
                        isExpenseChoice ? 'Bayar dengan Dompet' : 'Terima ke Dompet',
                        style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderCol),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedWallet,
                            dropdownColor: Theme.of(context).cardColor,
                            isExpanded: true,
                            items: walletNames.map((wName) {
                              return DropdownMenuItem<String>(
                                value: wName,
                                child: Row(
                                  children: [
                                    Icon(Icons.account_balance_wallet_rounded, color: textColor, size: 18),
                                    const SizedBox(width: 10),
                                    Text(wName, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newW) {
                              if (newW != null) {
                                setPageState(() {
                                  selectedWallet = newW;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          );
        },
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
    final monthString = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][_currentMonth.month - 1] + ' ' + _currentMonth.year.toString();

    // Filter recurring items for selected day
    final dayItems = _recurringItems.where((item) => item['day'] == _selectedDate.day).toList();

    // Calculate total Monthly Commitments (Income - Expenses)
    double monthlyIncome = 0.0;
    double monthlyExpense = 0.0;
    for (var item in _recurringItems) {
      final amt = item['amount'] as double;
      final isExp = item['isExpense'] as bool;
      if (isExp) {
        monthlyExpense += amt;
      } else {
        monthlyIncome += amt;
      }
    }

    final monthlyNet = monthlyIncome - monthlyExpense;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Berulang',
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
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: mainTextColor, size: 24),
            onPressed: _showAddRecurringPage,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 1. Overview Card (Flat Pastel, matching Calendar style)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Komitmen Bulanan',
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          AppLocale.formatCurrency(monthlyNet.abs(), '$currency '),
                          style: TextStyle(
                            color: mainTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Calendar Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                            });
                          },
                          child: Icon(Icons.chevron_left_rounded, color: subTextColor, size: 24),
                        ),
                        Text(
                          monthString,
                          style: TextStyle(
                            color: mainTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                            });
                          },
                          child: Icon(Icons.chevron_right_rounded, color: subTextColor, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Beautiful Month Calendar Grid
                    _buildCalendarGrid(isDark),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Selected Date Header
              Text(
                'Transaksi pada ${_selectedDate.day} May ${_selectedDate.year}',
                style: TextStyle(
                  color: mainTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 14),

              // 3. Transactions list for selected date
              dayItems.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Column(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 40, color: subTextColor.withValues(alpha: 0.2)),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada transaksi berulang hari ini',
                              style: TextStyle(color: subTextColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: dayItems.map((item) {
                        final isExp = item['isExpense'] as bool;
                        final categoryCol = item['categoryColor'] as Color;

                        return GestureDetector(
                          onTap: () => _showAddRecurringPage(editItem: item),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.swap_horiz_rounded,
                                    color: subTextColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'] as String,
                                        style: TextStyle(
                                          color: mainTextColor,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item['period'] as String,
                                              style: TextStyle(color: subTextColor, fontSize: 8, fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(Icons.wallet_rounded, size: 10, color: subTextColor),
                                          const SizedBox(width: 2),
                                          Text(
                                            item['walletName'] as String,
                                            style: TextStyle(color: subTextColor, fontSize: 10, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(item['categoryIcon'] as IconData, size: 10, color: categoryCol),
                                          const SizedBox(width: 2),
                                          Text(
                                            item['categoryName'] as String,
                                            style: TextStyle(color: categoryCol, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      AppLocale.formatCurrency(item['amount'] as double, '${isExp ? "-" : "+"} $currency '),
                                      style: TextStyle(
                                        color: isExp ? const Color(0xFFEF5350) : const Color(0xFF00D179),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => _deleteItem(item['id'] as String),
                                      child: Text(
                                        'Hapus',
                                        style: TextStyle(
                                          color: Colors.redAccent.withValues(alpha: 0.7),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
