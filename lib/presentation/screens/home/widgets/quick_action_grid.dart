import 'package:flutter/material.dart';

import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_text_styles.dart';
import '../../../../app/routes/app_routes.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  static final List<_ActionItem> _actions = [
    _ActionItem(
      icon: Icons.swap_horiz_rounded,
      label: 'Transfer',
      color: AppColors.primary,
      route: AppRoutes.transfer,
    ),
    _ActionItem(
      icon: Icons.add_circle_outline,
      label: 'Top Up',
      color: AppColors.success,
      route: AppRoutes.topup,
    ),
    _ActionItem(
      icon: Icons.qr_code_scanner_rounded,
      label: 'Bayar',
      color: AppColors.info,
      route: AppRoutes.payment,
    ),
    _ActionItem(
      icon: Icons.atm,
      label: 'Tarik Tunai',
      color: AppColors.warning,
      route: AppRoutes.withdraw,
    ),
    _ActionItem(
      icon: Icons.electrical_services_rounded,
      label: 'PLN',
      color: const Color(0xFFF59E0B),
      route: AppRoutes.pln,
    ),
    _ActionItem(
      icon: Icons.phone_android_rounded,
      label: 'Pulsa',
      color: const Color(0xFF3B82F6),
      route: AppRoutes.pulsa,
    ),
    _ActionItem(
      icon: Icons.wifi_rounded,
      label: 'Internet',
      color: const Color(0xFF14B8A6),
      route: AppRoutes.pulsa,
    ),
    _ActionItem(
      icon: Icons.apps_rounded,
      label: 'Lainnya',
      color: const Color(0xFF6B7280),
      route: AppRoutes.home,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Layanan',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
            children: _actions
                .map((a) => _QuickActionItem(item: a))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _QuickActionItem extends StatelessWidget {
  final _ActionItem item;

  const _QuickActionItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(item.route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
