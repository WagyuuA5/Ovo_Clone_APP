import 'package:flutter/material.dart';

import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final int unreadNotifications;
  final VoidCallback onNotificationTap;
  final VoidCallback? onPromoTap;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.unreadNotifications,
    required this.onNotificationTap,
    this.onPromoTap,
  });

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Row: Logo + Actions ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // OVO Logo
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'OVO',
                      style: AppTextStyles.titleLargeWhite.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              // Action icons
              Row(
                children: [
                  // Promo/gift icon
                  GestureDetector(
                    onTap: onPromoTap,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.card_giftcard_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Notification bell with badge
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        if (unreadNotifications > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  unreadNotifications > 9
                                      ? '9+'
                                      : '$unreadNotifications',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Greeting Row: Avatar + Text ───────────────────────────────────
          Row(
            children: [
              // Avatar circle with initials
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initials(userName),
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang,',
                    style: AppTextStyles.bodySmallWhite.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userName,
                    style: AppTextStyles.titleMediumWhite.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
