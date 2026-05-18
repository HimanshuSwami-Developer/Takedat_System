import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';

class AppUtils {

static String getInitials(String name) {
  final parts = name
      .trim()
      .split(' ')
      .where((e) => e.isNotEmpty)
      .toList();

  if (parts.isEmpty) return '?';

  if (parts.length == 1) {
    return parts[0][0].toUpperCase();
  }

  return (
    parts[0][0] + parts[1][0]
  ).toUpperCase();
}

static String format(
    String dateTime, {
    String pattern = 'dd MMM yyyy h:mm a',
  }) {
    try {
      final date = DateTime.parse(dateTime).toLocal();
      return DateFormat(pattern).format(date);
    } catch (e) {
      return '';
    }
  }


static Future<bool?> show({
    required BuildContext context,

    required String title,

    required String message,

    String confirmText = "Confirm",

    String cancelText = "Cancel",

    Color confirmColor = Colors.red,

    IconData icon = Icons.warning_amber_rounded,
  }) {
    return showDialog<bool>(
      context: context,

      barrierDismissible: false,

      builder: (ctx) {

        return Dialog(
          backgroundColor: Colors.transparent,

          insetPadding:
              const EdgeInsets.symmetric(
            horizontal: 24,
          ),

          child: Container(
            width: 420,

            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(26),

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(.08),

                  blurRadius: 30,

                  offset: const Offset(0, 10),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [

                /// ICON
                Container(
                  height: 74,
                  width: 74,

                  decoration: BoxDecoration(
                    color:
                        confirmColor.withOpacity(.1),

                    shape: BoxShape.circle,
                  ),

                  child: Icon(
                    icon,

                    color: confirmColor,

                    size: 38,
                  ),
                ),

                const SizedBox(height: 20),

                /// TITLE
                Text(
                  title,

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 12),

                /// MESSAGE
                Text(
                  message,

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,

                    color: Colors.black.withOpacity(.6),
                  ),
                ),

                const SizedBox(height: 28),

                /// BUTTONS
                Row(
                  children: [

                    /// CANCEL
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            ctx,
                            false,
                          );
                        },

                        style:
                            OutlinedButton.styleFrom(
                          minimumSize:
                              const Size(
                            double.infinity,
                            50,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),

                          side: BorderSide(
                            color:
                                Colors.grey.shade300,
                          ),
                        ),

                        child: Text(
                          cancelText,

                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// CONFIRM
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            ctx,
                            true,
                          );
                        },

                        style:
                            ElevatedButton.styleFrom(
                          elevation: 0,

                          backgroundColor:
                              confirmColor,

                          minimumSize:
                              const Size(
                            double.infinity,
                            50,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),

                        child: Text(
                          confirmText,

                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  static Future<void> showDialogMessage(
    BuildContext context, {

    required String title,

    required String message,

    VoidCallback? onTap,

    String buttonText = "Continue",

    bool barrierDismissible = false,
  }) async {
    await showDialog(
      context: context,

      barrierDismissible: barrierDismissible,

      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,

          insetPadding: const EdgeInsets.symmetric(horizontal: 24),

          child: Container(
            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(28),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),

                  blurRadius: 30,

                  offset: const Offset(0, 10),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                /// =========================================
                /// ICON
                /// =========================================
                Container(
                  height: 90,
                  width: 90,

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.15),

                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),

                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.verified_rounded,

                    color: AppColors.primary,

                    size: 50,
                  ),
                ),

                const SizedBox(height: 24),

                /// =========================================
                /// TITLE
                /// =========================================
                Text(
                  title,

                  textAlign: TextAlign.center,

                  style: AppTextStyles.headline.copyWith(
                    color: Colors.black,

                    fontSize: 22,

                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                /// =========================================
                /// MESSAGE
                /// =========================================
                Text(
                  message,

                  textAlign: TextAlign.center,

                  style: AppTextStyles.label.copyWith(
                    color: Colors.black54,

                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                /// =========================================
                /// BUTTON
                /// =========================================
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);

                      onTap?.call();
                    },

                    style: ElevatedButton.styleFrom(
                      elevation: 0,

                      backgroundColor: AppColors.primary,

                      minimumSize: const Size(double.infinity, 54),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    child: Text(
                      buttonText,

                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
