import 'package:flutter/material.dart';
import '../../core/constants.dart';

class CitationChip extends StatefulWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const CitationChip({
    super.key,
    this.label = 'Page',
    required this.value,
    this.onTap,
  });

  @override
  State<CitationChip> createState() => _CitationChipState();
}

class _CitationChipState extends State<CitationChip> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: AppMotion.curve,
          transform: Matrix4.diagonal3Values(
            _isPressed ? 0.92 : 1.0,
            _isPressed ? 0.92 : 1.0,
            1.0,
          ),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.only(left: 4, right: 12, top: 4, bottom: 4),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.surfaceMuted : AppColors.surface,
            borderRadius: AppRadius.chip,
            border: Border.all(
              color: _isHovered
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
            boxShadow: _isHovered ? AppShadows.soft : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.chip,
                ),
                child: Text(
                  widget.label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                    fontSize: 10,
                  ),
                ),
              ),
              AppSpacing.hSm,
              Text(
                widget.value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
