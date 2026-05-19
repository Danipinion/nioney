import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/category.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final currency = provider.currencySymbol;
    final isDark = theme.brightness == Brightness.dark;

    // Theme-aware colors
    final mainTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : const Color(0xFF64748B);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.05);
    final cardBgColor = isDark
        ? theme.cardColor.withValues(alpha: 0.3)
        : Colors.white;

    final breakdown = provider.getCategorySpendingBreakdown();
    final totalExpense = provider.monthlyExpense;

    final numberFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '$currency ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: TextStyle(color: mainTextColor, fontWeight: FontWeight.w700),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              if (breakdown.isEmpty) ...[
                const SizedBox(height: 80),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.pie_chart_outline_rounded,
                        size: 80,
                        color: subTextColor.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No spending data available',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: mainTextColor,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          'Add some expense transactions to see your financial analytics here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: subTextColor, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Main Chart Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(28),
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
                    children: [
                      Text(
                        'MONTHLY SPENDING SPLIT',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Custom interactive Donut Chart
                      SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            // Donut Ring Chart
                            PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {
                                        setState(() {
                                          if (!event
                                                  .isInterestedForInteractions ||
                                              pieTouchResponse == null ||
                                              pieTouchResponse.touchedSection ==
                                                  null) {
                                            _touchedIndex = -1;
                                            return;
                                          }
                                          _touchedIndex = pieTouchResponse
                                              .touchedSection!
                                              .touchedSectionIndex;
                                        });
                                      },
                                ),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 4,
                                centerSpaceRadius: 60,
                                sections: _buildPieSections(
                                  breakdown,
                                  totalExpense,
                                ),
                              ),
                            ),

                            // Center aggregate text overlay
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Total Outflow',
                                    style: TextStyle(
                                      color: subTextColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    numberFormat.format(totalExpense),
                                    style: TextStyle(
                                      color: mainTextColor,
                                      fontSize: 18,
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Categories Spending Breakdown List
                Text(
                  'Spending by Category',
                  style: TextStyle(
                    color: mainTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),

                // List of progress indicators
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: breakdown.length,
                  itemBuilder: (context, index) {
                    final sortedList = breakdown.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));

                    final entry = sortedList[index];
                    final cat = entry.key;
                    final amt = entry.value;
                    final percent = totalExpense > 0
                        ? (amt / totalExpense)
                        : 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor, width: 1),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cat.color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  cat.icon,
                                  color: cat.color,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cat.name,
                                      style: TextStyle(
                                        color: mainTextColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '${(percent * 100).toStringAsFixed(1)}% of total spent',
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                numberFormat.format(amt),
                                style: TextStyle(
                                  color: mainTextColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Linear progress indicator
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percent,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.05),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                cat.color,
                              ),
                              minHeight: 6,
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

  List<PieChartSectionData> _buildPieSections(
    Map<Category, double> breakdown,
    double total,
  ) {
    final List<PieChartSectionData> sections = [];
    int i = 0;

    // Sort to keep consistent layout
    final sortedBreakdown = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedBreakdown) {
      final cat = entry.key;
      final val = entry.value;
      final isTouched = i == _touchedIndex;
      final double radius = isTouched ? 22.0 : 16.0;

      sections.add(
        PieChartSectionData(
          color: cat.color,
          value: val,
          radius: radius,
          showTitle: false,
          badgeWidget: isTouched
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: cat.color, width: 1),
                  ),
                  child: Text(
                    '${((val / total) * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: cat.color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          badgePositionPercentageOffset: 0.98,
        ),
      );
      i++;
    }
    return sections;
  }
}
