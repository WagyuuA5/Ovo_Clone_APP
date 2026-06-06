import 'package:flutter/material.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/services/mock_auth_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../widgets/common/ovo_app_bar.dart';
import '../../widgets/dialogs/pin_dialog.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometricsEnabled = false;

  void _handleChangePin() async {
    // Step 1: Verify old PIN
    final verified = await PinDialog.show(
      context,
      title: 'Verifikasi PIN Lama',
      subtitle: 'Masukkan 6 digit PIN OVO kamu saat ini',
    );

    if (!verified || !mounted) return;

    // We verified old PIN. Now show full-screen input for new PIN.
    final newPin = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const _NewPinInputScreen(title: 'Buat PIN Baru'),
      ),
    );

    if (newPin == null || !mounted) return;

    // Confirm new PIN
    final confirmPin = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const _NewPinInputScreen(title: 'Konfirmasi PIN Baru'),
      ),
    );

    if (confirmPin == null || !mounted) return;

    if (newPin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN baru tidak cocok. Gagal mengubah PIN.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // PIN is matching, save it!
    final savedOldPin = await MockAuthService.instance.getPin();
    final success = await MockAuthService.instance.changePin(savedOldPin, newPin);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN berhasil diubah'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengubah PIN.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const OvoAppBar(
        title: 'Keamanan',
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionHeader('PIN'),
          _buildListTile(
            icon: Icons.lock_outline_rounded,
            title: 'Ganti PIN',
            onTap: _handleChangePin,
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Biometrik'),
          SwitchListTile(
            value: _biometricsEnabled,
            onChanged: (val) {
              setState(() {
                _biometricsEnabled = val;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    val ? 'Sidik Jari / Face ID diaktifkan' : 'Biometrik dinonaktifkan',
                  ),
                ),
              );
            },
            activeColor: AppColors.primary,
            title: Text(
              'Sidik Jari / Face ID',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            secondary: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Info Perangkat'),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.phone_android_rounded, color: AppColors.info, size: 20),
            ),
            title: Text(
              'Perangkat Terdaftar',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Smartphone Android • Perangkat ini',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const Divider(height: 1, indent: 72, color: AppColors.divider),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.circle_notifications_rounded, color: AppColors.success, size: 20),
            ),
            title: Text(
              'Sesi Aktif',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${DateFormatter.formatShort(now)} • Perangkat ini',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textHint,
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }
}

class _NewPinInputScreen extends StatefulWidget {
  final String title;

  const _NewPinInputScreen({required this.title});

  @override
  State<_NewPinInputScreen> createState() => _NewPinInputScreenState();
}

class _NewPinInputScreenState extends State<_NewPinInputScreen> {
  String _pin = '';

  void _onKeyPressed(String key) {
    if (key == 'del') {
      if (_pin.isNotEmpty) {
        setState(() {
          _pin = _pin.substring(0, _pin.length - 1);
        });
      }
    } else {
      if (_pin.length < 6) {
        setState(() {
          _pin += key;
        });
        if (_pin.length == 6) {
          Navigator.of(context).pop(_pin);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OvoAppBar(
        title: widget.title,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              widget.title == 'Buat PIN Baru'
                  ? 'Masukkan 6 digit PIN baru Anda'
                  : 'Konfirmasi 6 digit PIN baru Anda',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) => _buildDot(index)),
            ),
            const Spacer(),
            _buildNumpad(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final filled = index < _pin.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.primary : AppColors.divider,
        border: Border.all(
          color: filled ? AppColors.primary : AppColors.textHint,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];
    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) => _buildKey(key)).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildKey(String key) {
    if (key.isEmpty) {
      return const SizedBox(width: 80, height: 64);
    }
    return SizedBox(
      width: 80,
      height: 64,
      child: InkWell(
        onTap: () => _onKeyPressed(key),
        borderRadius: BorderRadius.circular(40),
        child: Center(
          child: key == 'del'
              ? const Icon(Icons.backspace_outlined, color: AppColors.textPrimary, size: 22)
              : Text(
                  key,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
