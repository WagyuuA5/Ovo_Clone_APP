import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/providers/notification_provider.dart';
import '../home/home_screen.dart';
import '../inbox/inbox_screen.dart';
import '../profile/profile_screen.dart';
import '../finance/finance_screen.dart';

class _FinancePlaceholder extends StatelessWidget {
  const _FinancePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Finance',
          style: AppTextStyles.titleMediumWhite.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Segera Hadir',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fitur Finance sedang dalam pengembangan',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InboxPlaceholder extends StatelessWidget {
  const _InboxPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Inbox',
          style: AppTextStyles.titleMediumWhite.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Inbox',
          style: AppTextStyles.titleMedium,
        ),
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTextStyles.titleMediumWhite.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Profile',
          style: AppTextStyles.titleMedium,
        ),
      ),
    );
  }
}

class _PaymentScreen extends StatelessWidget {
  const _PaymentScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Scan & Pay',
          style: AppTextStyles.titleMediumWhite.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.payment),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.primary,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Scan QR untuk Bayar',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ketuk untuk membuka scanner',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  static final List<Widget> _pages = [
    const HomeScreen(),
    const FinanceScreen(),
    const _PaymentScreen(),
    const InboxScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // Central Pay button — navigate directly to payment screen route
      Navigator.of(context).pushNamed(AppRoutes.payment);
      return;
    }
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<NotificationProvider>(
      builder: (context, notifProvider, _) {
        final unreadCount = notifProvider.unreadCount;

        return Container(
          decoration: BoxDecoration(
            color: theme.bottomNavigationBarTheme.backgroundColor ?? AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.3) : AppColors.primary.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: Row(
                children: [
                  // Home
                  _buildNavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    theme: theme,
                    isDark: isDark,
                  ),
                  // Finance
                  _buildNavItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Finance',
                    index: 1,
                    theme: theme,
                    isDark: isDark,
                  ),
                  // Pay (center elevated)
                  _buildCenterPayButton(theme, isDark),
                  // Inbox with badge
                  _buildNavItemWithBadge(
                    icon: Icons.inbox_rounded,
                    label: 'Inbox',
                    index: 3,
                    badgeCount: unreadCount,
                    theme: theme,
                    isDark: isDark,
                  ),
                  // Profile
                  _buildNavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    index: 4,
                    theme: theme,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required ThemeData theme,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = theme.bottomNavigationBarTheme.selectedItemColor ?? AppColors.primary;
    final inactiveColor = theme.bottomNavigationBarTheme.unselectedItemColor ?? AppColors.textHint;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge({
    required IconData icon,
    required String label,
    required int index,
    required int badgeCount,
    required ThemeData theme,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = theme.bottomNavigationBarTheme.selectedItemColor ?? AppColors.primary;
    final inactiveColor = theme.bottomNavigationBarTheme.unselectedItemColor ?? AppColors.textHint;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          badgeCount > 9 ? '9+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterPayButton(ThemeData theme, bool isDark) {
    final activeColor = theme.bottomNavigationBarTheme.selectedItemColor ?? AppColors.primary;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabTapped(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Elevated center button
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withOpacity(0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Pay',
              style: AppTextStyles.labelSmall.copyWith(
                color: activeColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
