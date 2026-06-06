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

class TransferConfirmScreen extends StatefulWidget {
  const TransferConfirmScreen({super.key});

  @override
  State<TransferConfirmScreen> createState() => _TransferConfirmScreenState();
}

class _TransferConfirmScreenState extends State<TransferConfirmScreen> {
  bool _isLoading = false;

  Future<void> _onPay(Map<String, dynamic> args) async {
    final balance = context.read<BalanceProvider>();
    final amount = args['amount'] as double;

    if (!balance.hasSufficientBalance(amount)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo tidak mencukupi'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final pinValid = await PinDialog.show(context);
    if (!pinValid || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final tx = await MockTransactionService.instance.processTransfer(
        targetPhone: args['phone'] as String,
        targetName: args['name'] as String,
        amount: amount,
        note: args['note'] as String?,
      );

      if (!mounted) return;

      await balance.deduct(amount);
      await balance.addPoints(10);
      await context.read<TransactionProvider>().addTransaction(tx);
      context.read<NotificationProvider>().addTransactionNotification(
        title: 'Transfer Berhasil',
        body:
            'Transfer ${CurrencyFormatter.format(amount.toInt())} ke ${args['name']} berhasil.',
      );

      if (!mounted) return;

      Navigator.of(context).pushNamed(
        '/transfer/success',
        arguments: {
          'phone': args['phone'],
          'name': args['name'],
          'amount': amount,
          'note': args['note'] ?? '',
          'referenceId': tx.referenceId ?? '',
          'date': tx.date,
        },
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
            {};
    final phone = args['phone'] as String? ?? '';
    final name = args['name'] as String? ?? '';
    final amount = (args['amount'] as num?)?.toDouble() ?? 0;
    final note = args['note'] as String? ?? '';
    final formattedAmount = CurrencyFormatter.format(amount.toInt());

    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Memproses transfer...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const OvoAppBar(title: 'Konfirmasi Transfer'),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(name, phone, formattedAmount, note),
            const SizedBox(height: 16),
            _buildBalanceInfo(),
            const SizedBox(height: 32),
            OvoButton(
              label: 'Bayar Sekarang',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : () => _onPay(args),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String name, String phone, String formattedAmount, String note) {
    return OvoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transfer OVO', style: AppTextStyles.titleSmall),
                    Text(
                      'OVO Cash',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                formattedAmount,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 12),
          _buildDetailRow('Kepada', name),
          _buildDetailRow('Nomor HP', phone),
          _buildDetailRow('Nominal', formattedAmount),
          _buildDetailRow('Catatan', note.isEmpty ? '-' : note),
          _buildDetailRow('Biaya Admin', 'Gratis',
              valueColor: AppColors.success),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
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

  Widget _buildBalanceInfo() {
    return Consumer<BalanceProvider>(
      builder: (context, balance, _) {
        return OvoCard(
          color: AppColors.primarySurface,
          child: Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                'Saldo OVO Cash: ',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              Text(
                CurrencyFormatter.format(balance.ovoBalance.toInt()),
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
