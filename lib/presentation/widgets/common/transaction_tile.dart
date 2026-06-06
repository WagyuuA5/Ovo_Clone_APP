import 'package:flutter/material.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../data/models/transaction_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.formatRelative(transaction.date),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.isDebit ? '-' : '+'}${CurrencyFormatter.format(transaction.amount.round())}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: transaction.isDebit ? AppColors.error : AppColors.success,
                  ),
                ),
                const SizedBox(height: 2),
                _buildStatusBadge(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: transaction.typeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        transaction.typeIcon,
        color: transaction.typeColor,
        size: 22,
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;
    switch (transaction.status) {
      case TransactionStatus.success:
        color = AppColors.success;
        label = 'Berhasil';
        break;
      case TransactionStatus.pending:
        color = AppColors.warning;
        label = 'Diproses';
        break;
      case TransactionStatus.failed:
        color = AppColors.error;
        label = 'Gagal';
        break;
    }
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(color: color),
    );
  }
}
