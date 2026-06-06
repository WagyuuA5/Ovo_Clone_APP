import 'package:flutter/material.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';

class SuccessDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onButtonPressed;
  final Widget? extra;

  const SuccessDialog({
    super.key,
    this.title = 'Transaksi Berhasil!',
    this.subtitle = 'Transaksi kamu telah berhasil diproses.',
    this.buttonLabel = 'Kembali ke Beranda',
    this.onButtonPressed,
    this.extra,
  });

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withOpacity(0.12),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 64,
            ),
          ),
        ),
        const SizedBox(height: 20),
        FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Text(
                widget.title,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.extra != null) ...[
                const SizedBox(height: 16),
                widget.extra!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
