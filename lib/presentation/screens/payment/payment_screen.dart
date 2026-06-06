import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/balance_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../../core/services/mock_transaction_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/merchant_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/ovo_app_bar.dart';
import '../../widgets/common/ovo_button.dart';
import '../../widgets/common/ovo_card.dart';
import '../../widgets/common/ovo_text_field.dart';
import '../../widgets/dialogs/pin_dialog.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  final _scannerController = MobileScannerController();
  final _formKey = GlobalKey<FormState>();

  MerchantModel? _selectedMerchant;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _amountController.addListener(_formatAmount);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.removeListener(_formatAmount);
    _amountController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _formatAmount() {
    final text = _amountController.text;
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    final formatted = 'Rp ${_addThousandSeparator(digits)}';
    if (_amountController.text != formatted) {
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  String _addThousandSeparator(String str) {
    if (str.isEmpty) return '';
    final intValue = int.tryParse(str) ?? 0;
    return NumberFormat.decimalPattern('id').format(intValue);
  }

  void _simulateScan() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Merchant (Simulasi Scan)',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: DummyData.merchants.length,
                  itemBuilder: (context, index) {
                    final merchant = DummyData.merchants[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primarySurface,
                        child: Icon(
                          merchant.category.toLowerCase().contains('f&b')
                              ? Icons.restaurant_rounded
                              : Icons.shopping_bag_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        merchant.name,
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        merchant.category,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _selectedMerchant = merchant;
                          _amountController.clear();
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _processPayment() async {
    if (_selectedMerchant == null) return;
    if (!_formKey.currentState!.validate()) return;

    final balance = context.read<BalanceProvider>();
    final amountText = _amountController.text;
    final int amount = CurrencyFormatter.parse(amountText);

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal pembayaran')),
      );
      return;
    }

    if (!balance.hasSufficientBalance(amount.toDouble())) {
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
      final double paymentAmount = amount.toDouble();
      final String refId = 'REF${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      // Simulate payment delay
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final tx = TransactionModel(
        id: 'TRX${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        type: TransactionType.payment,
        direction: TransactionDirection.debit,
        title: 'Pembayaran ke ${_selectedMerchant!.name}',
        subtitle: _selectedMerchant!.category,
        amount: paymentAmount,
        date: DateTime.now(),
        status: TransactionStatus.success,
        referenceId: refId,
      );

      await balance.deduct(paymentAmount);
      await context.read<TransactionProvider>().addTransaction(tx);
      
      context.read<NotificationProvider>().addTransactionNotification(
        title: 'Pembayaran Berhasil',
        body: 'Pembayaran sebesar Rp ${CurrencyFormatter.format(amount)} ke ${_selectedMerchant!.name} telah berhasil.',
      );

      Navigator.of(context).pushReplacementNamed('/payment/success', arguments: {
        'merchantName': _selectedMerchant!.name,
        'category': _selectedMerchant!.category,
        'amount': paymentAmount,
        'date': DateTime.now(),
        'referenceId': refId,
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat memproses pembayaran.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Memproses Pembayaran...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: OvoAppBar(
          title: 'Bayar',
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Scan QR'),
              Tab(text: 'Tunjukkan QR'),
            ],
          ),
          bottomHeight: 48,
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildScanTab(),
            _buildShowQrTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildScanTab() {
    if (_selectedMerchant != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              OvoCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primarySurface,
                      child: const Icon(Icons.storefront_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedMerchant!.name,
                            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedMerchant!.category,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        setState(() {
                          _selectedMerchant = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OvoTextField(
                label: 'Nominal Pembayaran',
                hint: 'Masukkan nominal',
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Text(
                    'Rp',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Nominal tidak boleh kosong';
                  }
                  final int amt = CurrencyFormatter.parse(val);
                  if (amt < 1000) {
                    return 'Nominal minimal Rp 1.000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              OvoButton(
                label: 'Bayar Sekarang',
                onPressed: _processPayment,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      final rawVal = barcode.rawValue;
                      if (rawVal != null) {
                        final matched = DummyData.merchants.firstWhere(
                          (m) =>
                              m.name.toLowerCase() == rawVal.toLowerCase() ||
                              m.id.toLowerCase() == rawVal.toLowerCase(),
                          orElse: () => DummyData.merchants.first,
                        );
                        setState(() {
                          _selectedMerchant = matched;
                          _amountController.clear();
                        });
                        break;
                      }
                    }
                  },
                ),
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Posisikan QR code di dalam kotak',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: OvoButton(
            label: 'Simulasi Scan QR',
            variant: OvoButtonVariant.secondary,
            onPressed: _simulateScan,
          ),
        ),
      ],
    );
  }

  Widget _buildShowQrTab() {
    final user = context.watch<AuthProvider>().user;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OvoCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'QR Code Saya',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tunjukkan QR ini ke merchant untuk melakukan pembayaran',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                QrImageView(
                  data: user.phone,
                  version: QrVersions.auto,
                  size: 200.0,
                  foregroundColor: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  user.name,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user.phone,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          OvoButton(
            label: 'Simpan QR ke Galeri',
            variant: OvoButtonVariant.secondary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur segera hadir')),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Extends widget for centerChildren layout helper
extension ColumnCenterChildren on Column {
  Column get centerChildren {
    return Column(
      key: key,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: CrossAxisAlignment.center,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: children,
    );
  }
}
