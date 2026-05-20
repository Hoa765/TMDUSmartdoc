import 'package:flutter/material.dart';
import '../../core/constants.dart';

enum ButtonVariant { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color contentColor = switch (variant) {
      ButtonVariant.primary => Colors.white,
      ButtonVariant.secondary || ButtonVariant.text => AppColors.primary,
      ButtonVariant.outline => AppColors.textPrimary,
    };

    final labelText = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: contentColor,
      ),
    );

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == ButtonVariant.primary
                  ? Colors.white
                  : AppColors.primary,
            ),
          ),
          AppSpacing.hSm,
        ] else if (icon != null) ...[
          Icon(icon, size: 20),
          AppSpacing.hSm,
        ],
        Flexible(child: labelText),
      ],
    );

    Widget button;

    switch (variant) {
      case ButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: AppSpacing.buttonPadding,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.control),
          ),
          child: buttonContent,
        );
        break;
      case ButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: AppColors.primary,
            elevation: 0,
            padding: AppSpacing.buttonPadding,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.control),
          ),
          child: buttonContent,
        );
        break;
      case ButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: BorderSide(color: AppColors.border),
            padding: AppSpacing.buttonPadding,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.control),
          ),
          child: buttonContent,
        );
        break;
      case ButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.control),
          ),
          child: buttonContent,
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, height: 54, child: button);
    }
    return SizedBox(height: 54, child: button);
  }
}
