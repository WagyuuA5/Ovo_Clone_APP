import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../widgets/common/ovo_button.dart';
import '../../widgets/common/ovo_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String? _phoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _normalizePhone(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('+62')) return trimmed;
    if (trimmed.startsWith('08')) {
      return '+62${trimmed.substring(1)}';
    }
    return trimmed;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor HP wajib diisi';
    }
    final digits = value.trim().replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9 || digits.length > 13) {
      return 'Nomor HP harus 10–13 digit';
    }
    final v = value.trim();
    if (!v.startsWith('08') && !v.startsWith('+62')) {
      return 'Nomor HP harus diawali 08 atau +62';
    }
    return null;
  }

  Future<void> _onSendOtp(BuildContext context) async {
    setState(() => _phoneError = null);
    final error = _validatePhone(_phoneController.text);
    if (error != null) {
      setState(() => _phoneError = error);
      return;
    }

    final phone = _normalizePhone(_phoneController.text);
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendOtp(phone);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushNamed(
        AppRoutes.otp,
        arguments: phone,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Gagal mengirim OTP. Coba lagi.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'OVO',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: -1,
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // OVO logo big text at top
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Text(
                            'OVO',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Masuk ke OVO',
                      style: AppTextStyles.headlineMedium,
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Masukkan nomor HP yang terdaftar',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Phone number input
                    OvoTextField(
                      label: 'Nomor HP',
                      hint: '0812 3456 7890',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      errorText: _phoneError,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[\d\+]'),
                        ),
                      ],
                      prefixIcon: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        child: Text(
                          '+62',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onChanged: (_) {
                        if (_phoneError != null) {
                          setState(() => _phoneError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Send OTP button
                    OvoButton(
                      label: 'Kirim OTP',
                      isLoading: authProvider.isLoading,
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _onSendOtp(context),
                    ),
                    const SizedBox(height: 40),

                    // Register link
                    Center(
                      child: OvoButton(
                        label: 'Daftar sebagai pengguna baru',
                        variant: OvoButtonVariant.ghost,
                        onPressed: () {
                          // Registration flow placeholder
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Fitur pendaftaran akan segera hadir.'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
