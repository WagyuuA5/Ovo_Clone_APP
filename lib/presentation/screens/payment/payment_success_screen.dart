import 'package:flutter/material.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../widgets/common/ovo_button.dart';
import '../../widgets/common/ovo_card.dart';
import '../../widgets/dialogs/success_dialog.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> args;

  const PaymentSuccessScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final merchantName = args['merchantName'] as String? ?? 'Merchant';
    final category = args['category'] as String? ?? 'Kategori';
    final amount = args['amount'] as double? ?? 0.0;
    final date = args['date'] as DateTime? ?? DateTime.now();
    final referenceId = args['referenceId'] as String? ?? '';

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
              title: 'Pembayaran Berhasil!',
              subtitle: 'Pembayaran Anda ke $merchantName telah sukses diproses.',
            ),
            const SizedBox(height: 24),
            _buildDetailCard(
              merchantName: merchantName,
              category: category,
              amount: amount,
              date: date,
              referenceId: referenceId,
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
              onPressed: () => Navigator.of(context).pushReplacementNamed('/history'),
            ),
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
          color: AppColors.success.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String merchantName,
    required String category,
    required double amount,
    required DateTime date,
    required String referenceId,
  }) {
    return OvoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  'Total Bayar',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.format(amount.round()),
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 20),
          _buildRow('Merchant', merchantName),
          _buildRow('Kategori', category),
          _buildRow('Waktu', DateFormatter.format(date)),
          _buildRow('No. Referensi', referenceId),
          _buildRow('Metode Pembayaran', 'OVO Cash'),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
