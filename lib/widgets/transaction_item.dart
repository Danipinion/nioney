import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/wallet.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final Category category;
  final Wallet wallet;
  final String currencySymbol;
  final VoidCallback? onDelete;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.category,
    required this.wallet,
    required this.currencySymbol,
    this.onDelete,
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
    final numberFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    final String amountPrefix = transaction.isExpense ? '-' : '+';
    final Color amountColor = transaction.isExpense
        ? Colors.white
        : const Color(0xFF66BB6A); // Emerald green for income

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
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.04),
            width: 1,
          ),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '  •  ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.2),
                          fontSize: 10,
                        ),
                      ),
                      Container(
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
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
