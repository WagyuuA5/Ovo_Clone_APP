import 'package:flutter/material.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../widgets/common/ovo_app_bar.dart';
import '../../widgets/common/ovo_button.dart';
import '../../widgets/common/ovo_card.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OvoAppBar(
        title: 'Detail Transaksi',
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur berbagi segera hadir')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildDetailCard(),
            const SizedBox(height: 16),
            OvoButton(
              label: 'Laporkan Masalah',
              variant: OvoButtonVariant.ghost,
              prefixIcon: Icons.flag_outlined,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Laporan akan diproses dalam 1x24 jam')),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return OvoCard(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: transaction.typeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Icon(
              transaction.typeIcon,
              color: transaction.typeColor,
              size: 36,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            transaction.typeLabel,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${transaction.isDebit ? '-' : '+'}${CurrencyFormatter.format(transaction.amount.round())}',
            style: AppTextStyles.headlineSmall.copyWith(
              color: transaction.isDebit ? AppColors.error : AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;
    IconData icon;
    switch (transaction.status) {
      case TransactionStatus.success:
        color = AppColors.success;
        label = 'Berhasil';
        icon = Icons.check_circle_rounded;
        break;
      case TransactionStatus.pending:
        color = AppColors.warning;
        label = 'Diproses';
        icon = Icons.access_time_rounded;
        break;
      case TransactionStatus.failed:
        color = AppColors.error;
        label = 'Gagal';
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    return OvoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Transaksi',
              style: AppTextStyles.titleSmall
                  .copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),
          _buildDetailRow('ID Transaksi', transaction.id),
          _buildDetailRow('Jenis', transaction.typeLabel),
          _buildDetailRow(
              'Tanggal', DateFormatter.format(transaction.date)),
          _buildDetailRowWidget(
            'Status',
            _buildInlineStatusBadge(),
          ),
          _buildDetailRow(
            'Nominal',
            '${transaction.isDebit ? '-' : '+'}${CurrencyFormatter.format(transaction.amount.round())}',
            valueColor:
                transaction.isDebit ? AppColors.error : AppColors.success,
          ),
          _buildDetailRow('Keterangan', transaction.subtitle),
          _buildDetailRow('Catatan', transaction.note ?? '-'),
          _buildDetailRow(
              'No. Referensi', transaction.referenceId ?? '-'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWidget(String label, Widget widget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          const Spacer(),
          widget,
        ],
      ),
    );
  }

  Widget _buildInlineStatusBadge() {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: AppTextStyles.labelSmall.copyWith(color: color)),
    );
  }
}
