import 'package:flutter/material.dart';
import '../../core/constants.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool hasShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceElevated,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
        boxShadow: hasShadow ? AppShadows.card : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.card,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.card,
          child: Padding(
            padding: padding ?? AppSpacing.cardPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}
