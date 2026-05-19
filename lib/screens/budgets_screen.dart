import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  void _showAddBudgetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddBudgetSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final currency = provider.currencySymbol;
    final isDark = theme.brightness == Brightness.dark;

    final mainTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF64748B);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.05);
    final cardBgColor = isDark ? theme.cardColor.withValues(alpha: 0.4) : Colors.white;

    final numberFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '$currency ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Budgets',
          style: TextStyle(
            color: mainTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: mainTextColor),
        actions: [
          IconButton(
            onPressed: () => _showAddBudgetSheet(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: theme.primaryColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              if (provider.budgets.isEmpty) ...[
                const SizedBox(height: 100),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.track_changes_rounded,
                        size: 80,
                        color: subTextColor.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Budgets Set Yet',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: mainTextColor,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          'Setting budgets helps you limit expenses and build strong financial discipline. Tap "+" to start.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _showAddBudgetSheet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Create First Budget',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  'Active Monthly Limits',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Budgets List View
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.budgets.length,
                  itemBuilder: (context, index) {
                    final budget = provider.budgets[index];
                    final category = provider.categories.firstWhere(
                      (c) => c.id == budget.categoryId,
                      orElse: () => provider.categories.last,
                    );

                    // Recalculate spent dynamically based on live transactions
                    final double spent = provider.getSpentForCategory(budget.categoryId);
                    final double limit = budget.limitAmount;
                    final double progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
                    final bool isOver = spent > limit;
                    final bool isWarning = !isOver && (spent / limit) >= 0.8;

                    // Health badges
                    String statusText = 'Healthy';
                    Color statusColor = const Color(0xFF66BB6A);
                    if (isOver) {
                      statusText = 'Over Budget!';
                      statusColor = const Color(0xFFEF5350);
                    } else if (isWarning) {
                      statusText = 'Near Limit!';
                      statusColor = const Color(0xFFFFCA28);
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: borderColor,
                          width: 1,
                        ),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: category.color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  category.icon,
                                  color: category.color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.name,
                                      style: TextStyle(
                                        color: mainTextColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            statusText.toUpperCase(),
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${(progress * 100).toStringAsFixed(0)}% Used',
                                          style: TextStyle(
                                            color: subTextColor,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Delete Button
                              IconButton(
                                onPressed: () => provider.deleteBudget(budget.id),
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: subTextColor.withValues(alpha: 0.5),
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Spent vs Limit Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    numberFormat.format(spent),
                                    style: TextStyle(
                                      color: isOver ? const Color(0xFFEF5350) : mainTextColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  Text(
                                    ' spent',
                                    style: TextStyle(
                                      color: subTextColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Limit: ',
                                    style: TextStyle(
                                      color: subTextColor.withValues(alpha: 0.6),
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    numberFormat.format(limit),
                                    style: TextStyle(
                                      color: mainTextColor.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Beautiful Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.04),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isOver
                                    ? const Color(0xFFEF5350)
                                    : (isWarning ? const Color(0xFFFFCA28) : category.color),
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class AddBudgetSheet extends StatefulWidget {
  const AddBudgetSheet({super.key});

  @override
  State<AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<AddBudgetSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _limitController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final expenseCategories = provider.categories.where((c) => c.isExpense).toList();
      if (expenseCategories.isNotEmpty) {
        setState(() {
          _selectedCategoryId = expenseCategories.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      return;
    }

    final double limit = double.tryParse(_limitController.text.replaceAll(',', '')) ?? 0.0;
    if (limit <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a limit greater than 0'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final provider = Provider.of<AppProvider>(context, listen: false);

    // Check if budget for category already exists
    final exists = provider.budgets.any((b) => b.categoryId == _selectedCategoryId);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A budget for this category already exists!'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    provider.addBudget(categoryId: _selectedCategoryId!, limitAmount: limit);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final mainTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF64748B);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05);
    final cardBgColor = isDark ? theme.cardColor.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.02);

    final expenseCategories = provider.categories.where((c) => c.isExpense).toList();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 50,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.18) : Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Set Category Budget',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: mainTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: subTextColor),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Limit Input Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MONTHLY BUDGET LIMIT (${provider.currencySymbol})',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          provider.currencySymbol,
                          style: TextStyle(
                            color: subTextColor.withValues(alpha: 0.5),
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _limitController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: mainTextColor,
                              fontSize: 26,
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w800,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(color: subTextColor.withValues(alpha: 0.3)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Enter limit';
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
              const SizedBox(height: 22),

              // Category Selector dropdown
              Text(
                'TARGET CATEGORY',
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  dropdownColor: theme.cardColor,
                  style: TextStyle(
                    color: mainTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: subTextColor,
                  ),
                  items: expenseCategories.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.id,
                      child: Row(
                        children: [
                          Icon(c.icon, color: c.color, size: 18),
                          const SizedBox(width: 10),
                          Text(c.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategoryId = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Create Button
              GestureDetector(
                onTap: _submit,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withValues(alpha: 0.2),
                        blurRadius: 16,
                        spreadRadius: -2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Activate Budget',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
