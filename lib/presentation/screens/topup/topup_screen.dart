import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../core/providers/balance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/common/ovo_app_bar.dart';
import '../../widgets/common/ovo_button.dart';
import '../../widgets/common/ovo_card.dart';
import '../../widgets/common/ovo_text_field.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  String? _selectedBank;
  int? _selectedAmount;
  final _customAmountController = TextEditingController();
  bool _useCustomAmount = false;

  @override
  void initState() {
    super.initState();
    _customAmountController.addListener(_onCustomAmountChanged);
  }

  @override
  void dispose() {
    _customAmountController.removeListener(_onCustomAmountChanged);
    _customAmountController.dispose();
    super.dispose();
  }

  void _onCustomAmountChanged() {
    final raw = _customAmountController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (raw.isNotEmpty) {
      setState(() {
        _useCustomAmount = true;
        _selectedAmount = int.tryParse(raw);
      });
      // Format field
      final formatted = _selectedAmount != null
          ? 'Rp ${_addThousandSeparator(raw)}'
          : '';
      if (_customAmountController.text != formatted && formatted.isNotEmpty) {
        _customAmountController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    } else {
      setState(() {
        _useCustomAmount = false;
        _selectedAmount = null;
      });
    }
  }

  String _addThousandSeparator(String digits) {
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i != 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  void _selectQuickAmount(int amount) {
    setState(() {
      _selectedAmount = amount;
      _useCustomAmount = false;
    });
    _customAmountController.clear();
  }

  void _proceed() {
    if (_selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih bank terlebih dahulu')),
      );
      return;
    }
    if (_selectedAmount == null || _selectedAmount! < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pilih atau masukkan nominal minimal Rp 10.000')),
      );
      return;
    }
    Navigator.of(context).pushNamed(
      '/topup/confirm',
      arguments: {
        'bank': _selectedBank!,
        'amount': _selectedAmount!.toDouble(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const OvoAppBar(title: 'Top Up OVO Cash'),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBalanceCard(),
                const SizedBox(height: 20),
                _buildBankSection(),
                const SizedBox(height: 20),
                _buildAmountSection(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Consumer<BalanceProvider>(
      builder: (context, balance, _) => OvoCard(
        color: AppColors.primarySurface,
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_rounded,
                color: AppColors.primary),
            const SizedBox(width: 10),
            Text('Saldo OVO Cash: ',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            Text(
              CurrencyFormatter.format(balance.ovoBalance.toInt()),
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pilih Bank', style: AppTextStyles.titleSmall),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.3,
          ),
          itemCount: DummyData.bankList.length,
          itemBuilder: (context, index) {
            final bank = DummyData.bankList[index];
            final isSelected = _selectedBank == bank;
            return GestureDetector(
              onTap: () => setState(() => _selectedBank = bank),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primarySurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_balance_rounded,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            size: 26,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            bank,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pilih Nominal', style: AppTextStyles.titleSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DummyData.topupAmounts.map((item) {
            final amount = item['amount'] as int;
            final label = item['label'] as String;
            final isSelected = !_useCustomAmount && _selectedAmount == amount;
            return GestureDetector(
              onTap: () => _selectQuickAmount(amount),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        OvoTextField(
          label: 'Nominal Lainnya',
          hint: 'Rp 0',
          controller: _customAmountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          prefixIcon: const Icon(Icons.edit_rounded,
              color: AppColors.textSecondary, size: 20),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: OvoButton(
        label: 'Lanjutkan',
        onPressed: _proceed,
      ),
    );
  }
}
