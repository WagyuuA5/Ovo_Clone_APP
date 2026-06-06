import 'package:flutter/material.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';

enum OvoButtonVariant { primary, secondary, ghost }

class OvoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final OvoButtonVariant variant;
  final double? width;
  final double height;
  final IconData? prefixIcon;
  final double borderRadius;

  const OvoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = OvoButtonVariant.primary,
    this.width,
    this.height = 52,
    this.prefixIcon,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (variant) {
      case OvoButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primaryLight.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: 2,
            shadowColor: AppColors.cardShadow,
          ),
          child: _buildChild(Colors.white),
        );

      case OvoButtonVariant.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: _buildChild(AppColors.primary),
        );

      case OvoButtonVariant.ghost:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: _buildChild(AppColors.primary),
        );
    }
  }

  Widget _buildChild(Color iconColor) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
        ),
      );
    }
    if (prefixIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(prefixIcon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.labelLarge.copyWith(color: iconColor)),
        ],
      );
    }
    return Text(
      label,
      style: AppTextStyles.labelLarge.copyWith(
        color: variant == OvoButtonVariant.primary ? Colors.white : AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
