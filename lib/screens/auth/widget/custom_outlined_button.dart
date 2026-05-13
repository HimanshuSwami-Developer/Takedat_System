import 'package:flutter/material.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';

class CustomOutlinedButton
    extends StatelessWidget {

  final String text;

  final VoidCallback? onTap;

  final bool isLoading;

  final bool isDisabled;

  final bool isFullWidth;

  final IconData? icon;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {

    final bool disabled =
        isDisabled || isLoading;

    return GestureDetector(
      onTap:
          disabled ? null : onTap,

      child: Container(
        height: 45,

        width:
            isFullWidth
                ? double.infinity
                : null,

        padding:
            isFullWidth
                ? null
                : const EdgeInsets.symmetric(
                    horizontal: 14,
                  ),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
            10,
          ),

          border: Border.all(
            color:
                disabled
                    ? Colors
                        .grey
                        .shade300
                    : AppColors.primary
                        .withOpacity(.25),
          ),
        ),

        child: Center(
          child:
              isLoading

                  ? SizedBox(
                      height: 18,
                      width: 18,

                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            AppColors
                                .primary,
                      ),
                    )

                  : Row(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [

                        Text(
                          text,

                          style:
                              AppTextStyles
                                  .label
                                  .copyWith(
                            color:
                                disabled
                                    ? Colors
                                        .grey
                                    : AppColors
                                        .primary,
                          ),
                        ),

                        if (icon != null) ...[

                          const SizedBox(
                            width: 6,
                          ),

                          Icon(
                            icon,

                            size: 16,

                            color:
                                disabled
                                    ? Colors
                                        .grey
                                    : AppColors
                                        .primary,
                          ),
                        ],
                      ],
                    ),
        ),
      ),
    );
  }
}