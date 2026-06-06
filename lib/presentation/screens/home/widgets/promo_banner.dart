import 'package:flutter/material.dart';

import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_text_styles.dart';
import '../../../../core/constants/dummy_data.dart';
import '../../../widgets/common/promo_card.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final promos = DummyData.promos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Promo untuk Kamu',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: promos.length,
            itemBuilder: (context, index) {
              return PromoCard(
                promo: promos[index],
                onTap: () {
                  _showPromoDetail(context, promos[index].title);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showPromoDetail(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Promo: $title',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
