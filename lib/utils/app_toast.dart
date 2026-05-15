import 'package:flutter/material.dart';

class AppToast {

  /// SUCCESS
  static void success(
    BuildContext context,
    String message,
  ) {
    _showToast(
      context: context,
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  /// ERROR
  static void error(
    BuildContext context,
    String message,
  ) {
    _showToast(
      context: context,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  /// WARNING
  static void warning(
    BuildContext context,
    String message,
  ) {
    _showToast(
      context: context,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
    );
  }

  /// INFO
  static void info(
    BuildContext context,
    String message,
  ) {
    _showToast(
      context: context,
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
    );
  }

  /// COMMON TOAST
  static void _showToast({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()

      ..showSnackBar(

        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,

          content: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),

              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Row(
              children: [

                Icon(
                  icon,
                  color: Colors.white,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    message,

                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          duration: const Duration(seconds: 2),
        ),
      );
  }
}