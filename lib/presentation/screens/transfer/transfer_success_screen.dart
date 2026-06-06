import 'package:flutter/material.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../widgets/common/ovo_button.dart';
import '../../widgets/common/ovo_card.dart';
import '../../widgets/dialogs/success_dialog.dart';

class TransferSuccessScreen extends StatelessWidget {
  const TransferSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
            {};
    final amount = (args['amount'] as num?)?.toDouble() ?? 0;
    final name = args['name'] as String? ?? '';
    final phone = args['phone'] as String? ?? '';
    final note = args['note'] as String? ?? '';
    final referenceId = args['referenceId'] as String? ?? '';
    final date = args['date'] as DateTime? ?? DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 32),
            _buildHeaderBadge(),
            const SizedBox(height: 24),
            SuccessDialog(
              title: 'Transfer Berhasil!',
              subtitle:
                  'Transfer ke $name telah berhasil diproses.',
            ),
            const SizedBox(height: 24),
            _buildDetailCard(
              amount: amount,
              name: name,
              phone: phone,
              note: note,
              referenceId: referenceId,
              date: date,
            ),
            const SizedBox(height: 32),
            OvoButton(
              label: 'Kembali ke Beranda',
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                (route) => false,
              ),
            ),
            const SizedBox(height: 12),
            OvoButton(
              label: 'Lihat Riwayat',
              variant: OvoButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pushNamed('/history'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBadge() {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: AppColors.headerGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.swap_horiz_rounded,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required double amount,
    required String name,
    required String phone,
    required String note,
    required String referenceId,
    required DateTime date,
  }) {
    return OvoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Transaksi',
            style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 8),
          _buildRow('Jumlah',
              CurrencyFormatter.format(amount.toInt()),
              valueColor: AppColors.primary),
          _buildRow('Kepada', name),
          _buildRow('Nomor HP', phone),
          if (note.isNotEmpty) _buildRow('Catatan', note),
          _buildRow('Waktu', DateFormatter.format(date)),
          if (referenceId.isNotEmpty)
            _buildRow('Referensi', referenceId),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
