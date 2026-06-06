import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import 'edit_profile_screen.dart';
import 'security_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, user)),
              SliverToBoxAdapter(child: _buildMenuBody(context, auth)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    final initials = _getInitials(user.name);
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    backgroundImage: user.avatarUrl.isNotEmpty
                        ? NetworkImage(user.avatarUrl)
                        : null,
                    child: user.avatarUrl.isEmpty
                        ? Text(
                            initials,
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                user.name,
                style: AppTextStyles.titleLargeWhite.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.phone,
                style: AppTextStyles.bodyMediumWhite
                    .copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ));
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Edit Profil',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuBody(BuildContext context, AuthProvider auth) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(context, 'Akun & Profil', [
            _MenuItem(
              icon: Icons.person_outline_rounded,
              label: 'Edit Profil',
              color: AppColors.primary,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
            ),
            _MenuItem(
              icon: Icons.security_outlined,
              label: 'Keamanan',
              color: AppColors.info,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SecurityScreen()),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, 'Preferensi', [
            _MenuItem(
              icon: Icons.notifications_outlined,
              label: 'Notifikasi',
              color: AppColors.warning,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pengaturan notifikasi segera hadir')),
                );
              },
            ),
            _MenuItem(
              icon: Icons.dark_mode_outlined,
              label: 'Mode Gelap',
              color: Colors.blueGrey,
              onTap: () {},
              isSwitch: true,
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, 'Lainnya', [
            _MenuItem(
              icon: Icons.help_outline_rounded,
              label: 'Bantuan',
              color: AppColors.success,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pusat bantuan segera hadir')),
                );
              },
            ),
            _MenuItem(
              icon: Icons.info_outline_rounded,
              label: 'Tentang Aplikasi',
              color: AppColors.textSecondary,
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'OVO Clone',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025 OVO Clone. Belajar Flutter.',
                );
              },
            ),
            _MenuItem(
              icon: Icons.logout_rounded,
              label: 'Keluar',
              color: AppColors.error,
              isDestructive: true,
              onTap: () => _handleLogout(context, auth),
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : AppColors.cardShadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return _buildMenuItem(context, entry.value, isLast);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item, bool isLast) {
    return Column(
      children: [
        InkWell(
          onTap: item.isSwitch ? null : item.onTap,
          borderRadius: isLast
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                )
              : null,
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            title: Text(
              item.label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: item.isDestructive ? AppColors.error : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            trailing: item.isSwitch
                ? Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return Switch(
                        value: themeProvider.isDarkMode,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          themeProvider.toggleTheme(val);
                        },
                      );
                    },
                  )
                : Icon(
                    Icons.chevron_right_rounded,
                    color: item.isDestructive
                        ? AppColors.error.withOpacity(0.6)
                        : AppColors.textHint,
                    size: 20,
                  ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
        ),
        if (!isLast)
          Divider(height: 1, indent: 72, color: Theme.of(context).dividerTheme.color ?? AppColors.divider),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context, AuthProvider auth) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Keluar',
      message: 'Apakah kamu yakin ingin keluar dari akun OVO kamu?',
      confirmLabel: 'Keluar',
      cancelLabel: 'Batal',
      isDangerous: true,
    );
    if (confirmed && context.mounted) {
      await auth.logout();
      if (context.mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isSwitch;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isDestructive = false,
    this.isSwitch = false,
  });
}
