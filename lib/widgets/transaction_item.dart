import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/wallet.dart';
import '../main.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final Category category;
  final Wallet wallet;
  final String currencySymbol;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.category,
    required this.wallet,
    required this.currencySymbol,
    this.onDelete,
    this.onTap,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return 'Today, ${DateFormat('hh:mm a').format(date)}';
    } else if (txDate == yesterday) {
      return 'Yesterday, ${DateFormat('hh:mm a').format(date)}';
    } else {
      return DateFormat('dd MMM, hh:mm a').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = AppLocale.isInitialized
        ? NumberFormat.currency(
            locale: 'id_ID',
            symbol: '',
            decimalDigits: 0,
          )
        : NumberFormat.currency(
            symbol: '',
            decimalDigits: 0,
          );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF64748B);
    final dotColor = isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black12;
    final cardBgColor = isDark ? Theme.of(context).cardColor.withValues(alpha: 0.4) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.05);

    final String amountPrefix = transaction.isExpense ? '-' : '+';
    final Color amountColor = transaction.isExpense
        ? (isDark ? Colors.white : const Color(0xFFE53935)) // High-contrast Red/White for Expense
        : const Color(0xFF00D179); // Vibrant emerald green for income

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.redAccent),
      ),
      onDismissed: (_) {
        if (onDelete != null) {
          onDelete!();
        }
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
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
        child: Row(
          children: [
            // Category Icon Badge
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: category.color.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(category.icon, color: category.color, size: 22),
            ),
            const SizedBox(width: 14),
            // Title & Wallet Meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: TextStyle(
                      color: mainTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          transaction.subCategory.isNotEmpty
                              ? '${category.name} › ${transaction.subCategory}'
                              : category.name,
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '  •  ',
                        style: TextStyle(
                          color: dotColor,
                          fontSize: 10,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: wallet.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            wallet.name,
                            style: TextStyle(
                              color: wallet.color.withValues(alpha: 0.8),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Amount & Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$amountPrefix$currencySymbol ${numberFormat.format(transaction.amount)}',
                  style: TextStyle(
                    color: amountColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.date),
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
      ),
    );
  }
}
