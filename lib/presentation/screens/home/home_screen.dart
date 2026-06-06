import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../widgets/common/balance_card.dart';
import '../../widgets/common/transaction_tile.dart';
import 'widgets/home_header.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/promo_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final userName = authProvider.user.name;
    final unreadCount = notificationProvider.unreadCount;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Sticky header as SliverToBoxAdapter (no overlap) ──────────────
          SliverToBoxAdapter(
            child: HomeHeader(
              userName: userName,
              unreadNotifications: unreadCount,
              onNotificationTap: () {
                Navigator.of(context).pushNamed(AppRoutes.inbox);
              },
              onPromoTap: () {
                Navigator.of(context).pushNamed(AppRoutes.inbox);
              },
            ),
          ),

          // ── White/Dark rounded-top content container ───────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // Balance Card
                  const BalanceCard(),

                  const SizedBox(height: 20),

                  // Quick Actions
                  const QuickActionGrid(),

                  const SizedBox(height: 24),

                  // Promo Banner
                  const PromoBanner(),

                  const SizedBox(height: 24),

                  // Recent Transactions
                  _buildRecentTransactions(theme, isDark),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(ThemeData theme, bool isDark) {
    return Consumer<TransactionProvider>(
      builder: (context, txProvider, _) {
        final recent = txProvider.recentTransactions;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaksi Terakhir',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.history);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Lihat Semua',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            if (recent.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 48,
                        color: isDark ? AppColors.textHintDark : AppColors.textHint,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada transaksi',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color ?? AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.3) : AppColors.cardShadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: List.generate(recent.length, (index) {
                      final tx = recent[index];
                      return Column(
                        children: [
                           TransactionTile(
                            transaction: tx,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.transactionDetail,
                                arguments: tx,
                              );
                            },
                          ),
                          if (index < recent.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: theme.dividerTheme.color ?? AppColors.divider,
                              indent: 74,
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
