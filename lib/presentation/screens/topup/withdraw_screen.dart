import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/providers/balance_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../../core/services/mock_transaction_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/ovo_app_bar.dart';
import '../../widgets/common/ovo_button.dart';
import '../../widgets/dialogs/pin_dialog.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  String? _selectedBank;
  int? _selectedAmount;
  bool _isLoading = false;

  final List<String> _banks = ['BCA', 'Mandiri', 'BRI'];
  final List<int> _amounts = [100000, 200000, 500000, 1000000];

  void _onLanjutkan() async {
    if (_selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih ATM Bank tujuan')),
      );
      return;
    }
    if (_selectedAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih nominal penarikan')),
      );
      return;
    }

    final balance = context.read<BalanceProvider>();
    final double amount = _selectedAmount!.toDouble();

    if (!balance.hasSufficientBalance(amount)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo tidak mencukupi untuk melakukan penarikan'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final pinValid = await PinDialog.show(context);
    if (!pinValid || !mounted) return;

    setState(() => _isLoading = true);

    try {
      // Simulate delay
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final withdrawCode = MockTransactionService.instance.generateWithdrawCode();
      final tx = TransactionModel(
        id: 'TRX${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        type: TransactionType.withdraw,
        direction: TransactionDirection.debit,
        title: 'Tarik Tunai ATM $_selectedBank',
        subtitle: 'Kode Tarik Tunai: $withdrawCode',
        amount: amount,
        date: DateTime.now(),
        status: TransactionStatus.success,
        referenceId: 'REF${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      );

      await balance.deduct(amount);
      await context.read<TransactionProvider>().addTransaction(tx);
      
      context.read<NotificationProvider>().addTransactionNotification(
        title: 'Tarik Tunai Sukses',
        body: 'Tarik tunai sebesar Rp ${CurrencyFormatter.format(_selectedAmount!)} di ATM $_selectedBank berhasil dilakukan.',
      );

      setState(() => _isLoading = false);

      _showSuccessBottomSheet(withdrawCode);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memproses penarikan tunai.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessBottomSheet(String code) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kode Tarik Tunai',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Gunakan kode di bawah ini pada ATM $_selectedBank tujuan Anda',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  code,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Kode ini berlaku selama 30 menit.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OvoButton(
                      label: 'Salin Kode',
                      variant: OvoButtonVariant.secondary,
                      onPressed: () {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Kode berhasil disalin')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OvoButton(
                      label: 'Tutup',
                      onPressed: () {
                        Navigator.of(ctx).pop(); // Close bottom sheet
                        Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Memproses Penarikan...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const OvoAppBar(
          title: 'Tarik Tunai',
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Choose ATM
            Text(
              'Pilih ATM Bank',
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: _banks.map((bank) {
                final isSelected = _selectedBank == bank;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBank = bank;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primarySurface : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                            width: isSelected ? 2 : 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.account_balance_rounded, color: AppColors.primary),
                            const SizedBox(height: 8),
                            Text(
                              bank,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            // Choose Amount
            Text(
              'Pilih Nominal Penarikan',
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _amounts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemBuilder: (context, index) {
                final amt = _amounts[index];
                final isSelected = _selectedAmount == amt;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAmount = amt;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primarySurface : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                        width: isSelected ? 2 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        CurrencyFormatter.format(amt),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            OvoButton(
              label: 'Lanjutkan',
              onPressed: _onLanjutkan,
            ),
          ],
        ),
      ),
    );
  }
}
