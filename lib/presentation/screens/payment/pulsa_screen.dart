import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../core/providers/auth_provider.dart';
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

class PulsaScreen extends StatefulWidget {
  const PulsaScreen({super.key});

  @override
  State<PulsaScreen> createState() => _PulsaScreenState();
}

class _PulsaScreenState extends State<PulsaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _detectedOperator;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _internetPackages = [
    {
      'name': 'Internet 1 GB',
      'desc': 'Masa aktif 3 hari. Kuota Nasional 2G/3G/4G/5G.',
      'price': 15000,
    },
    {
      'name': 'Internet 3 GB',
      'desc': 'Masa aktif 7 hari. Kuota Nasional 2G/3G/4G/5G.',
      'price': 28000,
    },
    {
      'name': 'Internet 10 GB',
      'desc': 'Masa aktif 30 hari. Kuota Utama 8GB + Chat 2GB.',
      'price': 65000,
    },
    {
      'name': 'Internet Unlimited',
      'desc': 'Masa aktif 30 hari. FUP 20GB. Gratis nelpon sesama.',
      'price': 120000,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Autofill user's phone number
    final userPhone = context.read<AuthProvider>().user.phone;
    _phoneController.text = userPhone;
    _detectOperator(userPhone);

    _phoneController.addListener(() {
      _detectOperator(_phoneController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _detectOperator(String number) {
    if (number.length < 4) {
      setState(() {
        _detectedOperator = null;
      });
      return;
    }

    final String prefix = number.replaceAll(RegExp(r'\D'), '');
    if (prefix.startsWith('0811') || prefix.startsWith('0812') || prefix.startsWith('0813') || prefix.startsWith('0821') || prefix.startsWith('0822') || prefix.startsWith('62811') || prefix.startsWith('62812')) {
      setState(() => _detectedOperator = 'Telkomsel');
    } else if (prefix.startsWith('0817') || prefix.startsWith('0818') || prefix.startsWith('0819') || prefix.startsWith('0859') || prefix.startsWith('0877') || prefix.startsWith('0878')) {
      setState(() => _detectedOperator = 'XL');
    } else if (prefix.startsWith('0814') || prefix.startsWith('0815') || prefix.startsWith('0816') || prefix.startsWith('0855') || prefix.startsWith('0856') || prefix.startsWith('0857') || prefix.startsWith('0858')) {
      setState(() => _detectedOperator = 'Indosat');
    } else if (prefix.startsWith('0895') || prefix.startsWith('0896') || prefix.startsWith('0897') || prefix.startsWith('0898') || prefix.startsWith('0899')) {
      setState(() => _detectedOperator = 'Tri');
    } else if (prefix.startsWith('0881') || prefix.startsWith('0882') || prefix.startsWith('0888')) {
      setState(() => _detectedOperator = 'Smartfren');
    } else if (prefix.startsWith('0831') || prefix.startsWith('0832') || prefix.startsWith('0833') || prefix.startsWith('0838')) {
      setState(() => _detectedOperator = 'Axis');
    } else {
      setState(() => _detectedOperator = null);
    }
  }

  void _purchasePackage(String name, double price, bool isInternet) async {
    if (!_formKey.currentState!.validate()) return;

    final balance = context.read<BalanceProvider>();
    if (!balance.hasSufficientBalance(price)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo tidak mencukupi untuk membeli paket ini'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final pinValid = await PinDialog.show(context);
    if (!pinValid || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final String phone = _phoneController.text.trim();
      final String op = _detectedOperator ?? 'Lainnya';
      
      final tx = isInternet
          ? await MockTransactionService.instance.processInternet(
              phone: phone,
              operator: op,
              packageName: name,
              amount: price,
            )
          : await MockTransactionService.instance.processPulsa(
              phone: phone,
              operator: op,
              packageName: name,
              amount: price,
            );

      if (!mounted) return;

      await balance.deduct(price);
      await context.read<TransactionProvider>().addTransaction(tx);
      
      context.read<NotificationProvider>().addTransactionNotification(
        title: 'Transaksi Sukses',
        body: 'Pembelian ${isInternet ? "paket internet" : "pulsa"} $name untuk nomor $phone berhasil diproses.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pembelian $name berhasil!'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Navigator.of(context).pop();
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Memproses Pembelian...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: OvoAppBar(
          title: 'Pulsa & Internet',
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Pulsa'),
              Tab(text: 'Internet'),
            ],
          ),
          bottomHeight: 48,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Form(
                key: _formKey,
                child: OvoTextField(
                  label: 'Nomor HP',
                  hint: 'Masukkan nomor HP tujuan',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  suffixIcon: _detectedOperator != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Chip(
                            label: Text(_detectedOperator!),
                            backgroundColor: AppColors.primarySurface,
                            labelStyle: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nomor HP tidak boleh kosong';
                    }
                    if (val.trim().length < 9) {
                      return 'Nomor HP minimal 9 digit';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPulsaList(),
                  _buildInternetList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsaList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: DummyData.pulsaPackages.length,
      itemBuilder: (context, index) {
        final pkg = DummyData.pulsaPackages[index];
        final String name = pkg['quota'] as String;
        final int price = pkg['price'] as int;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: OvoCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Masa aktif mengikuti kebijakan provider',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                OvoButton(
                  label: CurrencyFormatter.format(price),
                  width: 110,
                  height: 40,
                  borderRadius: 20,
                  onPressed: () => _purchasePackage(name, price.toDouble(), false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInternetList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _internetPackages.length,
      itemBuilder: (context, index) {
        final pkg = _internetPackages[index];
        final String name = pkg['name'] as String;
        final String desc = pkg['desc'] as String;
        final int price = pkg['price'] as int;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: OvoCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Harga',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    OvoButton(
                      label: CurrencyFormatter.format(price),
                      width: 120,
                      height: 40,
                      borderRadius: 20,
                      onPressed: () => _purchasePackage(name, price.toDouble(), true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
