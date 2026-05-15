import 'package:flutter/material.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';

class AppUtils {

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

    barrierDismissible:
        barrierDismissible,

    builder: (_) {

      return Dialog(

        backgroundColor: Colors.transparent,

        insetPadding:
            const EdgeInsets.symmetric(
          horizontal: 24,
        ),

        child: Container(

          padding:
              const EdgeInsets.all(24),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
                BorderRadius.circular(
              28,
            ),

            boxShadow: [

              BoxShadow(

                color:
                    Colors.black.withOpacity(
                  0.08,
                ),

                blurRadius: 30,

                offset:
                    const Offset(0, 10),
              ),
            ],
          ),

          child: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              /// =========================================
              /// ICON
              /// =========================================

              Container(

                height: 90,
                width: 90,

                decoration: BoxDecoration(

                  gradient:
                      LinearGradient(

                    colors: [

                      AppColors.primary
                          .withOpacity(
                        0.15,
                      ),

                      AppColors.primary
                          .withOpacity(
                        0.05,
                      ),
                    ],
                  ),

                  shape: BoxShape.circle,
                ),

                child: const Icon(

                  Icons.verified_rounded,

                  color:
                      AppColors.primary,

                  size: 50,
                ),
              ),

              const SizedBox(height: 24),

              /// =========================================
              /// TITLE
              /// =========================================

              Text(

                title,

                textAlign:
                    TextAlign.center,

                style:
                    AppTextStyles.headline
                        .copyWith(

                  color: Colors.black,

                  fontSize: 22,

                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              /// =========================================
              /// MESSAGE
              /// =========================================

              Text(

                message,

                textAlign:
                    TextAlign.center,

                style:
                    AppTextStyles.label
                        .copyWith(

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

                    Navigator.pop(
                      context,
                    );

                    onTap?.call();
                  },

                  style:
                      ElevatedButton.styleFrom(

                    elevation: 0,

                    backgroundColor:
                        AppColors.primary,

                    minimumSize:
                        const Size(
                      double.infinity,
                      54,
                    ),

                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),

                  child: Text(

                    buttonText,

                    style:
                        AppTextStyles.label
                            .copyWith(

                      color: Colors.white,

                      fontWeight:
                          FontWeight.w600,
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
