import 'package:flutter/material.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';


class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;

  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = true, // 👈 default
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = isDisabled || isLoading;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        height: 45,
        width: isFullWidth ? double.infinity : null, // 👈 key change
        padding: isFullWidth
            ? null
            : const EdgeInsets.symmetric(horizontal: 12),

        decoration: BoxDecoration(
          color: disabled ? Colors.grey.shade300 : AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min, // 👈 important
                  children: [
                    Text(
                      text,
                      style: AppTextStyles.label.copyWith(
                        color: disabled ? Colors.grey : Colors.white,
                      ),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: 6),
                      Icon(icon, size: 16, color: Colors.white),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}