import 'package:flutter/material.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';

class CustomTextField extends StatefulWidget {

  final String label;
  final String hint;
  final IconData? icon;
  final bool isPassword;
  final bool isTextArea;
  final TextEditingController? controller;

  /// NEW
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.isPassword = false,
    this.isTextArea = false,
    this.controller,

    /// DEFAULT
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomTextField> createState() =>
      _CustomTextFieldState();
}

class _CustomTextFieldState
    extends State<CustomTextField> {

  bool isVisible = false;

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      mainAxisSize: MainAxisSize.min,

      children: [

        /// LABEL
        if (widget.label.isNotEmpty) ...[

          Text(
            widget.label,

            style: AppTextStyles.label.copyWith(
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 6),
        ],

        /// FIELD
        SizedBox(

          height:
              widget.isTextArea
                  ? null
                  : 45,

          child: TextField(

            controller: widget.controller,

            /// KEYBOARD TYPE
            keyboardType:
                widget.keyboardType,

            obscureText:
                widget.isPassword &&
                !isVisible,

            textAlignVertical:
                TextAlignVertical.center,

            maxLines:
                widget.isTextArea
                    ? 4
                    : 1,

            style: AppTextStyles.body.copyWith(
              color: Colors.black,
            ),

            decoration: InputDecoration(

              hintText: widget.hint,

              /// PREFIX ICON
              prefixIcon:
                  widget.icon != null
                      ? Padding(
                          padding:
                              const EdgeInsets.all(12),

                          child: Icon(
                            widget.icon,
                            size: 18,
                          ),
                        )
                      : null,

              /// PASSWORD TOGGLE
              suffixIcon:
                  widget.isPassword
                      ? IconButton(

                          icon: Icon(

                            isVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),

                          onPressed: () {

                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                        )
                      : null,

              filled: true,

              fillColor:
                  Colors.grey.shade100,

              hintStyle:
                  AppTextStyles.label.copyWith(
                    color: Colors.grey,
                  ),

              contentPadding:
                  const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),

              border: OutlineInputBorder(

                borderRadius:
                    BorderRadius.circular(12),

                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),

              enabledBorder: OutlineInputBorder(

                borderRadius:
                    BorderRadius.circular(12),

                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),

              focusedBorder: OutlineInputBorder(

                borderRadius:
                    BorderRadius.circular(12),

                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}