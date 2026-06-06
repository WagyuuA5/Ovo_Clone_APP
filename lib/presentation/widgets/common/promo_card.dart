import 'package:flutter/material.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../data/models/promo_model.dart';

class PromoCard extends StatelessWidget {
  final PromoModel promo;
  final VoidCallback? onTap;

  const PromoCard({
    super.key,
    required this.promo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 110,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: promo.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: promo.color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: -10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PROMO',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    promo.title,
                    style: AppTextStyles.titleMediumWhite.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    promo.subtitle,
                    style: AppTextStyles.bodySmallWhite.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
