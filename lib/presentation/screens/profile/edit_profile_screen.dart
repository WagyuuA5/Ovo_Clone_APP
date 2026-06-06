import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/common/ovo_app_bar.dart';
import '../../widgets/common/ovo_button.dart';
import '../../widgets/common/ovo_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().updateUserProfile(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui profil. Silakan coba lagi.'),
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
    final user = context.watch<AuthProvider>().user;
    final initials = _getInitials(user.name);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const OvoAppBar(
        title: 'Edit Profil',
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Avatar with 'Ganti Foto' Overlay
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pilih foto dari galeri'),
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primarySurface,
                      backgroundImage: user.avatarUrl.isNotEmpty
                          ? NetworkImage(user.avatarUrl)
                          : null,
                      child: user.avatarUrl.isEmpty
                          ? Text(
                              initials,
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Name text field
              OvoTextField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                controller: _nameController,
                keyboardType: TextInputType.name,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 20),
              // Email text field
              OvoTextField(
                label: 'Email',
                hint: 'Masukkan email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 20),
              // Phone text field (read-only)
              OvoTextField(
                label: 'Nomor HP',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                readOnly: true,
                prefixIcon: const Icon(Icons.phone, color: AppColors.textHint),
              ),
              const SizedBox(height: 40),
              // Submit button
              OvoButton(
                label: 'Simpan Perubahan',
                isLoading: _isLoading,
                onPressed: _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
