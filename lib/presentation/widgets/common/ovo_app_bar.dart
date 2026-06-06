import 'package:flutter/material.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';

class OvoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;
  final Widget? bottom;
  final double bottomHeight;

  const OvoAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = Colors.white,
    this.elevation = 0,
    this.bottom,
    this.bottomHeight = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: foregroundColor, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      automaticallyImplyLeading: showBackButton,
      actions: actions,
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: false,
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight),
              child: bottom!,
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + bottomHeight);
}
