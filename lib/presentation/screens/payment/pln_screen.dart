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
import '../../widgets/common/ovo_text_field.dart';
import '../../widgets/dialogs/pin_dialog.dart';

class PlnScreen extends StatefulWidget {
  const PlnScreen({super.key});

  @override
  State<PlnScreen> createState() => _PlnScreenState();
}

class _PlnScreenState extends State<PlnScreen> {
  final _customerIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isChecking = false;
  
  // Mock customer info
  final String _mockCustomerName = 'BUDI SANTOSO';
  final String _mockTariff = 'R1 / 900 VA';
  final String _mockStatus = 'AKTIF';
  
  int _selectedStep = 0; // 0: Input Customer ID, 1: Select type & amount
  int _selectedMode = 0; // 0: Token Listrik, 1: Tagihan Listrik
  int? _selectedTokenAmount;
  final int _mockTagihanAmount = 285000;
  
  final List<int> _tokenOptions = [20000, 50000, 100000, 200000, 500000];
  bool _isProcessingPayment = false;

  void _checkBilling() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isChecking = true;
    });
    
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    
    setState(() {
      _isChecking = false;
      _selectedStep = 1;
    });
  }

  void _processPayment() async {
    final balance = context.read<BalanceProvider>();
    final double amount = _selectedMode == 0 
        ? (_selectedTokenAmount?.toDouble() ?? 0) 
        : _mockTagihanAmount.toDouble();
        
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih nominal pembayaran terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!balance.hasSufficientBalance(amount)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo tidak mencukupi untuk melakukan transaksi'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final pinValid = await PinDialog.show(context);
    if (!pinValid || !mounted) return;

    setState(() {
      _isProcessingPayment = true;
    });
    try {
      final String customerId = _customerIdController.text.trim();
      final result = await MockTransactionService.instance.processPlnPayment(
        customerId: customerId,
        customerName: _mockCustomerName,
        amount: amount,
      );

      final tx = result['transaction'];
      final token = result['token'] as String?;

      if (!mounted) return;

      await balance.deduct(amount);
      await context.read<TransactionProvider>().addTransaction(tx);
      
      final String notifBody = _selectedMode == 0
          ? 'Pembelian token PLN Rp ${CurrencyFormatter.format(amount.toInt())} berhasil. Nomor token Anda: $token'
          : 'Pembayaran tagihan listrik PLN sebesar Rp ${CurrencyFormatter.format(amount.toInt())} berhasil.';
          
      context.read<NotificationProvider>().addTransactionNotification(
        title: 'Transaksi PLN Berhasil',
        body: notifBody,
      );

      _showSuccessDialog(amount, token);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat memproses transaksi.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  void _showSuccessDialog(double amount, String? token) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
              const SizedBox(height: 16),
              Text(
                'Pembayaran Sukses',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Transaksi PLN Anda telah berhasil diproses.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (token != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'NOMOR TOKEN PLN',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        token,
                        style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              OvoButton(
                label: 'Kembali',
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close success dialog
                  Navigator.of(context).pop(); // Close PLN screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isProcessingPayment,
      message: 'Memproses Pembayaran...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const OvoAppBar(
          title: 'PLN Listrik',
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OvoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Masukkan ID Pelanggan / No. Meter',
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: OvoTextField(
                              hint: 'Contoh: 51234567890',
                              controller: _customerIdController,
                              keyboardType: TextInputType.number,
                              readOnly: _selectedStep > 0,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'ID Pelanggan tidak boleh kosong';
                                }
                                if (val.trim().length < 8) {
                                  return 'ID Pelanggan minimal 8 digit';
                                }
                                return null;
                              },
                            ),
                          ),
                          if (_selectedStep == 0) ...[
                            const SizedBox(width: 12),
                            OvoButton(
                              label: 'Cek',
                              width: 80,
                              height: 50,
                              isLoading: _isChecking,
                              onPressed: _checkBilling,
                            ),
                          ]
                        ],
                      ),
                      if (_selectedStep > 0) ...[
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: AppColors.divider),
                        const SizedBox(height: 16),
                        _buildCustomerInfoCard(),
                      ],
                    ],
                  ),
                ),
                if (_selectedStep > 0) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Pilih Layanan',
                    style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModeSelector('Token Listrik', 0),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModeSelector('Tagihan Listrik', 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_selectedMode == 0) _buildTokenPicker() else _buildBillDisplay(),
                  const SizedBox(height: 40),
                  OvoButton(
                    label: _selectedMode == 0 ? 'Beli Token' : 'Bayar Tagihan',
                    onPressed: _processPayment,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Nama Pelanggan', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            Text(_mockCustomerName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tarif / Daya', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            Text(_mockTariff, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Status', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _mockStatus,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeSelector(String label, int mode) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
          _selectedTokenAmount = null;
        });
      },
      child: Container(
        height: 48,
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
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTokenPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Nominal Token',
          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _tokenOptions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final amt = _tokenOptions[index];
            final isSelected = _selectedTokenAmount == amt;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTokenAmount = amt;
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        CurrencyFormatter.format(amt),
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bayar: ${CurrencyFormatter.format(amt + 1500)}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBillDisplay() {
    return OvoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tagihan Listrik Anda',
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Periode', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              Text('Agustus 2025', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jumlah Tagihan', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              Text(CurrencyFormatter.format(_mockTagihanAmount), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Biaya Admin', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              Text('Rp 2.500', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Pembayaran', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text(CurrencyFormatter.format(_mockTagihanAmount + 2500), style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}
