import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/constants/dummy_data.dart';
import '../../../core/providers/balance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/contact_model.dart';
import '../../widgets/common/ovo_app_bar.dart';
import '../../widgets/common/ovo_button.dart';
import '../../widgets/common/ovo_card.dart';
import '../../widgets/common/ovo_text_field.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _foundContactName;
  bool _isLookingUp = false;
  bool _hasSearched = false;
  String? _phoneError;
  String? _amountError;

  static const List<int> _quickAmounts = [50000, 100000, 200000, 500000];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_formatAmount);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.removeListener(_formatAmount);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _formatAmount() {
    final text = _amountController.text;
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return;

    final formatted = 'Rp ${_addThousandSeparator(digits)}';
    if (_amountController.text != formatted) {
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  String _addThousandSeparator(String digits) {
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i != 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  void _setQuickAmount(int amount) {
    final formatted = 'Rp ${_addThousandSeparator(amount.toString())}';
    _amountController.text = formatted;
    setState(() => _amountError = null);
  }

  void _onContactTap(ContactModel contact) {
    _phoneController.text = contact.phone;
    setState(() {
      _foundContactName = contact.name;
      _hasSearched = true;
      _phoneError = null;
    });
  }

  Future<void> _lookupPhone() async {
    final phone = _phoneController.text.trim();
    final error = Validators.validatePhone(phone);
    if (error != null) {
      setState(() => _phoneError = error);
      return;
    }
    setState(() {
      _isLookingUp = true;
      _phoneError = null;
      _hasSearched = false;
      _foundContactName = null;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final contact = DummyData.contacts.where((c) => c.phone == phone).firstOrNull;
    setState(() {
      _isLookingUp = false;
      _hasSearched = true;
      _foundContactName = contact?.name ?? 'Pengguna OVO';
    });
  }

  void _proceed() {
    final phone = _phoneController.text.trim();
    final phoneError = Validators.validatePhone(phone);
    if (phoneError != null) {
      setState(() => _phoneError = phoneError);
      return;
    }
    if (!_hasSearched || _foundContactName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap cari nomor tujuan terlebih dahulu')),
      );
      return;
    }

    final rawAmount = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
    final balance = context.read<BalanceProvider>().ovoBalance;
    final amountError = Validators.validateAmount(rawAmount, balance.toInt());
    if (amountError != null) {
      setState(() => _amountError = amountError);
      return;
    }

    final amount = double.parse(rawAmount);
    Navigator.of(context).pushNamed(
      '/transfer/confirm',
      arguments: {
        'phone': phone,
        'name': _foundContactName!,
        'amount': amount,
        'note': _noteController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const OvoAppBar(title: 'Transfer OVO'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFavoriteContacts(),
            const SizedBox(height: 20),
            _buildPhoneSection(),
            if (_hasSearched && _foundContactName != null) ...[
              const SizedBox(height: 12),
              _buildContactResultCard(),
            ],
            const SizedBox(height: 20),
            _buildAmountSection(),
            const SizedBox(height: 20),
            OvoTextField(
              label: 'Catatan (Opsional)',
              hint: 'Tambahkan catatan...',
              controller: _noteController,
              maxLength: 100,
            ),
            const SizedBox(height: 32),
            OvoButton(
              label: 'Lanjutkan',
              onPressed: _proceed,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteContacts() {
    final favorites = DummyData.contacts.where((c) => c.isFavorite).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kontak Favorit', style: AppTextStyles.titleSmall),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final contact = favorites[index];
              return GestureDetector(
                onTap: () => _onContactTap(contact),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primarySurface,
                      child: Text(
                        contact.avatarInitial,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 56,
                      child: Text(
                        contact.name.split(' ').first,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nomor HP Tujuan', style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: OvoTextField(
                hint: '08xxxxxxxxxx',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                errorText: _phoneError,
                onChanged: (_) => setState(() {
                  _phoneError = null;
                  _hasSearched = false;
                  _foundContactName = null;
                }),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 52,
              child: OvoButton(
                label: 'Cari',
                isLoading: _isLookingUp,
                onPressed: _lookupPhone,
                width: 72,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactResultCard() {
    return OvoCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primarySurface,
            child: Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_foundContactName!, style: AppTextStyles.titleSmall),
                Text(
                  _phoneController.text,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ],
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OvoTextField(
          label: 'Nominal',
          hint: 'Rp 0',
          controller: _amountController,
          keyboardType: TextInputType.number,
          errorText: _amountError,
          onChanged: (_) => setState(() => _amountError = null),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickAmounts.map((amount) {
            return GestureDetector(
              onTap: () => _setQuickAmount(amount),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  CurrencyFormatter.format(amount),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
