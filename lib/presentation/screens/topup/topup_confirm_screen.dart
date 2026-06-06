import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/providers/balance_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../../core/services/mock_transaction_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/ovo_app_bar.dart';
import '../../widgets/common/ovo_button.dart';
import '../../widgets/common/ovo_card.dart';
import '../../widgets/dialogs/pin_dialog.dart';

class TopUpConfirmScreen extends StatefulWidget {
  const TopUpConfirmScreen({super.key});

  @override
  State<TopUpConfirmScreen> createState() => _TopUpConfirmScreenState();
}

class _TopUpConfirmScreenState extends State<TopUpConfirmScreen> {
  bool _isLoading = false;

  Future<void> _onConfirm(String bank, double amount) async {
    final pinValid = await PinDialog.show(context);
    if (!pinValid || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final tx = await MockTransactionService.instance.processTopUp(
        bankName: bank,
        amount: amount,
      );

      if (!mounted) return;

      final balance = context.read<BalanceProvider>();
      await balance.credit(amount);
      await balance.addPoints(5);
      await context.read<TransactionProvider>().addTransaction(tx);
      context.read<NotificationProvider>().addTransactionNotification(
        title: 'Top Up Berhasil',
        body:
            'Top Up ${CurrencyFormatter.format(amount.toInt())} via $bank berhasil. Saldo kamu bertambah.',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Top Up berhasil! Saldo bertambah ${CurrencyFormatter.format(amount.toInt())}',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
            {};
    final bank = args['bank'] as String? ?? '';
    final amount = (args['amount'] as num?)?.toDouble() ?? 0;
    final formattedAmount = CurrencyFormatter.format(amount.toInt());

    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Memproses top up...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const OvoAppBar(title: 'Konfirmasi Top Up'),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(bank, formattedAmount),
            const SizedBox(height: 16),
            _buildInstructionsCard(bank, formattedAmount),
            const SizedBox(height: 32),
            OvoButton(
              label: 'Konfirmasi Top Up',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : () => _onConfirm(bank, amount),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String bank, String formattedAmount) {
    return OvoCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: AppColors.success,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top Up via $bank',
                    style: AppTextStyles.titleSmall),
                Text(
                  'Transfer dari rekening $bank',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            formattedAmount,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(String bank, String formattedAmount) {
    final steps = [
      'Buka aplikasi mobile banking $bank',
      'Pilih menu Transfer',
      'Masukkan nomor rekening OVO: 1234-5678-9012',
      'Masukkan nominal: $formattedAmount',
      'Konfirmasi dan selesai',
    ];

    return OvoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cara Top Up via $bank',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
