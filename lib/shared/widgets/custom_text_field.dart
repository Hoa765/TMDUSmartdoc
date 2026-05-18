import 'package:flutter/material.dart';
import '../../core/constants.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 22, color: AppColors.textSecondary)
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 22,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : (widget.suffixIcon != null
                  ? Icon(
                      widget.suffixIcon,
                      size: 22,
                      color: AppColors.textSecondary,
                    )
                  : null),
        border: OutlineInputBorder(
          borderRadius: AppRadius.control,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.control,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.control,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: AppSpacing.inputPadding,
      ),
    );
  }
}
