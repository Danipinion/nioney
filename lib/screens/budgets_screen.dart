import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../main.dart';

class _SafeFormatter {
  final String symbol;
  _SafeFormatter(this.symbol);
  String format(num value) => AppLocale.formatCurrency(value.toDouble(), symbol);
}

// Semi-circle progress gauge painter
class SemiCircleGaugePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  SemiCircleGaugePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    // Draw background track (180 degrees arc)
    paint.color = backgroundColor;
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height * 2),
      3.1415926535, // Start angle (Pi)
      3.1415926535, // Sweep angle (Pi)
      false,
      paint,
    );

    // Draw progress track
    final double cleanProgress = progress.isNaN || progress.isInfinite ? 0.0 : progress.clamp(0.0, 1.0);
    paint.color = progressColor;
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height * 2),
      3.1415926535,
      3.1415926535 * cleanProgress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  DateTime _selectedMonth = DateTime.now();

  void _prevMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

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

    // Theme-aware colors
    final mainTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF64748B);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.05);
    final cardBgColor = isDark ? theme.cardColor : Colors.white;

    final numberFormat = _SafeFormatter('$currency ');

    // Compute dynamic sums for active budgets
    final double totalLimit = provider.budgets.fold(0.0, (sum, b) => sum + b.limitAmount);
    double totalSpent = 0.0;
    for (var budget in provider.budgets) {
      totalSpent += provider.getSpentForCategory(budget.categoryId, targetMonth: _selectedMonth);
    }
    final double remaining = totalLimit - totalSpent;
    final double progress = totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;

    final bool isOver = totalSpent > totalLimit;
    final bool isWarning = !isOver && totalLimit > 0 && (totalSpent / totalLimit) >= 0.8;

    String statusText = 'Normal';
    Color statusColor = const Color(0xFF00D179); // Premium Green
    if (isOver) {
      statusText = 'Over Limit';
      statusColor = const Color(0xFFEF5350); // Red
    } else if (isWarning) {
      statusText = 'Near Limit';
      statusColor = const Color(0xFFFFB300); // Amber
    }

    final int lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    const monthsIndo = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    const monthsIndoShort = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final String monthName = '${monthsIndo[_selectedMonth.month - 1]} ${_selectedMonth.year}';
    final shortName = monthsIndoShort[_selectedMonth.month - 1];
    final String periodRange = '1 $shortName - $lastDay $shortName';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Anggaran',
          style: TextStyle(
            color: mainTextColor,
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: mainTextColor),
            onPressed: () {},
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

              // 1. Overview Budget Gauge Card (Flat Pastel, extremely clean)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: borderColor),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          )
                        ],
                ),
                child: Column(
                  children: [
                    // Month Navigation Arrow Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _prevMonth,
                          child: Icon(Icons.chevron_left_rounded, color: subTextColor, size: 24),
                        ),
                        Text(
                          monthName,
                          style: TextStyle(
                            color: mainTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        GestureDetector(
                          onTap: _nextMonth,
                          child: Icon(Icons.chevron_right_rounded, color: subTextColor, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Spend estimation and health badge row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anda Bisa Belanja',
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              numberFormat.format(remaining < 0 ? 0.0 : remaining),
                              style: TextStyle(
                                color: remaining < 0 ? const Color(0xFFEF5350) : mainTextColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '($periodRange)',
                              style: TextStyle(
                                color: subTextColor.withValues(alpha: 0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Lagi Bulan Ini',
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // Health Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOver ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                                color: statusColor,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Semi-circular Gauge Painter
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        SizedBox(
                          width: 170,
                          height: 85,
                          child: CustomPaint(
                            painter: SemiCircleGaugePainter(
                              progress: progress,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.black.withValues(alpha: 0.05),
                              progressColor: statusColor,
                            ),
                          ),
                        ),
                        // Percent text in the center
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: mainTextColor,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              Text(
                                'Terpakai',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Total Spent vs Limit Label below gauge
                    Text(
                      '${numberFormat.format(totalSpent)} / ${numberFormat.format(totalLimit)}',
                      style: TextStyle(
                        color: mainTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 2. Budget list header
              Text(
                'Anggaran Anda',
                style: TextStyle(
                  color: mainTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 16),

              // Budgets List / Empty State
              provider.budgets.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.track_changes_rounded,
                              size: 64,
                              color: subTextColor.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada anggaran',
                              style: TextStyle(
                                color: mainTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                'Buat anggaran bulanan atau mingguan agar pengeluaran kamu lebih teratur.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: provider.budgets.map((budget) {
                        final category = provider.categories.firstWhere(
                          (c) => c.id == budget.categoryId,
                          orElse: () => provider.categories.last,
                        );

                        final double spent = provider.getSpentForCategory(budget.categoryId, targetMonth: _selectedMonth);
                        final double limit = budget.limitAmount;
                        final double progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
                        final double sisa = limit - spent;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Category Pastel Circle Icon
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: category.color.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      category.icon,
                                      color: category.color,
                                      size: 18,
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
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${numberFormat.format(spent)} / ${numberFormat.format(limit)}',
                                          style: TextStyle(
                                            color: subTextColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Outfit',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Period Badge on Right
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      budget.period.toLowerCase() == 'weekly' ? 'WEEKLY' : 'MONTHLY',
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  // Delete Budget Trigger
                                  IconButton(
                                    onPressed: () => provider.deleteBudget(budget.id),
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: subTextColor.withValues(alpha: 0.4),
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              
                              // Budget Linear Progress Bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: isDark
                                      ? Colors.white.withValues(alpha: 0.04)
                                      : Colors.black.withValues(alpha: 0.04),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    sisa < 0 ? const Color(0xFFEF5350) : category.color,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Sisa ${numberFormat.format(sisa)}',
                                style: TextStyle(
                                  color: sisa < 0 ? const Color(0xFFEF5350) : subTextColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
              
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetSheet(context),
        backgroundColor: const Color(0xFF1E293B), // Sleek flat dark navy FAB
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

// ----------------------------------------------------
// ADD BUDGET SCREEN (MATCHING SCREENSHOT 2 EXACTLY!)
// ----------------------------------------------------
class AddBudgetSheet extends StatefulWidget {
  const AddBudgetSheet({super.key});

  @override
  State<AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<AddBudgetSheet> {
  final TextEditingController _limitController = TextEditingController(text: '0');
  final TextEditingController _nameController = TextEditingController();
  
  String _selectedPeriod = 'Bulanan'; // 'Mingguan' | 'Bulanan'
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
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final double limit = double.tryParse(_limitController.text.replaceAll(',', '')) ?? 0.0;
    if (limit <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan jumlah batas anggaran lebih dari 0!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori terlebih dahulu!'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    final provider = Provider.of<AppProvider>(context, listen: false);

    // Verify if budget for category already exists
    final exists = provider.budgets.any((b) => b.categoryId == _selectedCategoryId);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anggaran untuk kategori ini sudah ada!'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    // Add budget via provider
    provider.addBudget(
      categoryId: _selectedCategoryId!,
      limitAmount: limit,
      period: _selectedPeriod == 'Mingguan' ? 'weekly' : 'monthly',
    );

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
    final cardBgColor = isDark ? theme.cardColor : Colors.white;

    final expenseCategories = provider.categories.where((c) => c.isExpense).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // 1. Header (X, Anggaran Baru, Simpan)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.close_rounded, color: mainTextColor, size: 24),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  'Anggaran Baru',
                  style: TextStyle(
                    color: mainTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Outfit',
                  ),
                ),
                TextButton(
                  onPressed: _submit,
                  child: Text(
                    'Simpan',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Batas Jumlah Section
                  Text(
                    'Batas Jumlah',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        // Currency Selector Box (Rp ▾)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                provider.currencySymbol,
                                style: TextStyle(
                                  color: mainTextColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down_rounded, color: subTextColor, size: 20),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Numeric Input Box
                        Expanded(
                          child: TextField(
                            controller: _limitController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: mainTextColor,
                              fontSize: 32,
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w800,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              hintText: '0',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Anggaran Label Name Section
                  Text(
                    'Anggaran',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    style: TextStyle(
                      color: mainTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'cth. Anggaran Bulanan Saya',
                      hintStyle: TextStyle(color: subTextColor.withValues(alpha: 0.45)),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.015),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Periode Toggle Section (Mingguan | Bulanan)
                  Text(
                    'Periode',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 54,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPeriod = 'Mingguan';
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedPeriod == 'Mingguan'
                                    ? cardBgColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: _selectedPeriod == 'Mingguan' && !isDark
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.04),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'Mingguan',
                                style: TextStyle(
                                  color: _selectedPeriod == 'Mingguan' ? mainTextColor : subTextColor,
                                  fontSize: 13,
                                  fontWeight: _selectedPeriod == 'Mingguan' ? FontWeight.w800 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPeriod = 'Bulanan';
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedPeriod == 'Bulanan'
                                    ? cardBgColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: _selectedPeriod == 'Bulanan' && !isDark
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.04),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'Bulanan',
                                style: TextStyle(
                                  color: _selectedPeriod == 'Bulanan' ? mainTextColor : subTextColor,
                                  fontSize: 13,
                                  fontWeight: _selectedPeriod == 'Bulanan' ? FontWeight.w800 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bulanan mengikuti pengaturan hari awal siklus anggaran di profil.',
                    style: TextStyle(
                      color: subTextColor.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Kategori Section (Horizontally Scrollable Circles)
                  Text(
                    'Kategori',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: expenseCategories.map((cat) {
                        final isSel = _selectedCategoryId == cat.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = cat.id;
                            });
                          },
                          child: Container(
                            width: 78,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Circle Category Box
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  height: 52,
                                  width: 52,
                                  decoration: BoxDecoration(
                                    color: cat.color.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSel ? cat.color : Colors.transparent,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      cat.icon,
                                      color: cat.color,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Label Text
                                Text(
                                  cat.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSel ? mainTextColor : subTextColor,
                                    fontSize: 10,
                                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
