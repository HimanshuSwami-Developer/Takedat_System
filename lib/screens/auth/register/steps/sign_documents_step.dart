import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';

import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/signature_bottom_sheet.dart';

import '../../../../constant/session_keys.dart';
import '../../../../constant/session_manager.dart';

import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';

class SignDocumentsStep
    extends StatefulWidget {

  final VoidCallback onComplete;

  const SignDocumentsStep({
    super.key,
    required this.onComplete,
  });

  @override
  State<SignDocumentsStep> createState() =>
      _SignDocumentsStepState();
}

class _SignDocumentsStepState
    extends State<SignDocumentsStep> {

  /// =====================================================
  /// SIGNED IMAGE BYTES
  /// =====================================================

  Uint8List? authBytes;

  Uint8List? screeningBytes;

  /// =====================================================
  /// FLAGS
  /// =====================================================

  bool authSigned = false;

  bool screeningSigned = false;

  bool isLoading = false;

  String userId = "";

  String userEmail = "";

  bool get allSigned {

    return authSigned &&
        screeningSigned;
  }

  @override
  void initState() {

    super.initState();

    loadSession();
  }

  /// =====================================================
  /// LOAD SESSION
  /// =====================================================

  Future<void> loadSession() async {

    userId = await SessionManager
        .getString(
      SessionKeys.userId,
    );

    userEmail = await SessionManager
        .getString(
      SessionKeys.email,
    );

    setState(() {});
  }

  /// =====================================================
  /// SAVE
  /// =====================================================

  Future<void> saveSignedDocuments()
  async {

    setState(() {

      isLoading = true;
    });

    context.read<RegisterBloc>().add(

      SaveSignedDocumentsEvent(

        userId: userId,

        userEmail: userEmail,

        authBytes: authBytes,

        authFileName:
            "signed_authentication.png",

        screeningBytes:
            screeningBytes,

        screeningFileName:
            "signed_screening.png",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return BlocListener<
        RegisterBloc,
        RegisterState>(

      listener: (context, state) {

        if (state is RegisterLoading) {

          setState(() {

            isLoading = true;
          });
        }

        if (state is RegisterSuccess) {

          setState(() {

            isLoading = false;
          });

          widget.onComplete();
        }

        if (state is RegisterFailure) {

          setState(() {

            isLoading = false;
          });

          ScaffoldMessenger.of(context)
              .showSnackBar(

            SnackBar(
              content: Text(
                state.error,
              ),
            ),
          );
        }
      },

      child: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            /// =================================================
            /// HEADER
            /// =================================================

            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                Text(

                  "STEP 3 OF 3",

                  style:
                      AppTextStyles.small
                          .copyWith(
                    color:
                        AppColors.primary,
                  ),
                ),

                Text(

                  "Finalizing Account",

                  style:
                      AppTextStyles.small
                          .copyWith(
                    color:
                        Colors.black54,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            ClipRRect(

              borderRadius:
                  BorderRadius.circular(
                10,
              ),

              child:
                  const LinearProgressIndicator(

                value: 1,

                minHeight: 6,

                color:
                    AppColors.primary,

                backgroundColor:
                    Color(0xFFE0E0E0),
              ),
            ),

            const SizedBox(height: 16),

            /// =================================================
            /// TITLE
            /// =================================================

            Text(

              "Sign Documents",

              style:
                  AppTextStyles.headline
                      .copyWith(
                color: Colors.black,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            Text(

              "Please review and electronically sign the agreements.",

              style:
                  AppTextStyles.label
                      .copyWith(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            /// =================================================
            /// AUTH DOC
            /// =================================================

            _docCard(

              title:
                  "Customer Agreement",

              signed:
                  authSigned,

              description:
                  "The terms and conditions governing your account.",

              onTap: () async {

                final Uint8List? result =
                    await showSignatureSheet(

                  context,

                  title:
                      "Customer Agreement",

                  documentPath:
                      "assets/signature/auth.png",
                );

                if (result != null) {

                  authBytes = result;

                  setState(() {

                    authSigned =
                        true;
                  });
                }
              },
            ),

            /// =================================================
            /// PRIVACY DOC
            /// =================================================

            _docCard(

              title:
                  "Privacy Policy",

              signed:
                  screeningSigned,

              description:
                  "How we collect and protect your personal data.",

              onTap: () async {

                final Uint8List? result =
                    await showSignatureSheet(

                  context,

                  title:
                      "Privacy Policy",

                  documentPath:
                      "assets/signature/auth.png",
                );

                if (result != null) {

                  screeningBytes =
                      result;

                  setState(() {

                    screeningSigned =
                        true;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            /// =================================================
            /// SECURITY CARD
            /// =================================================

            Container(

              padding:
                  const EdgeInsets.all(
                14,
              ),

              decoration:
                  BoxDecoration(

                color:
                    AppColors.primary,

                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),

              child: Row(

                children: [

                  Expanded(

                    child: Text(

                      "Encryption Secured\n256-bit AES Digital Signatures",

                      style:
                          AppTextStyles.label
                              .copyWith(
                        color:
                            Colors.white,
                      ),
                    ),
                  ),

                  const Icon(

                    Icons.verified,

                    color: Colors.white,

                    size: 42,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// =================================================
            /// COMPLETE BUTTON
            /// =================================================

            CustomButton(

              text: isLoading
                  ? "Saving..."
                  : "Complete Registration",

              onTap:
                  allSigned &&
                          !isLoading

                      ? saveSignedDocuments

                      : null,
            ),
          ],
        ),
      ),
    );
  }

  /// =====================================================
  /// DOC CARD
  /// =====================================================

  Widget _docCard({

    required String title,

    required String description,

    required VoidCallback onTap,

    required bool signed,
  }) {

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        boxShadow: [

          BoxShadow(

            color:
                Colors.black.withOpacity(
              0.04,
            ),

            blurRadius: 8,
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Container(

                height: 38,
                width: 38,

                decoration:
                    BoxDecoration(

                  color:
                      signed

                          ? Colors.green
                              .withOpacity(
                            0.1,
                          )

                          : Colors.grey
                              .shade200,

                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),

                child: Icon(

                  signed

                      ? Icons.check_circle

                      : Icons.description,

                  color:

                      signed

                          ? Colors.green

                          : Colors.black54,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(

                child: Text(

                  title,

                  style:
                      AppTextStyles.label
                          .copyWith(
                    color:
                        Colors.black,
                  ),
                ),
              ),

              Container(

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),

                decoration:
                    BoxDecoration(

                  color:

                      signed

                          ? Colors.green
                              .withOpacity(
                            0.1,
                          )

                          : Colors.red
                              .withOpacity(
                            0.1,
                          ),

                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                ),

                child: Text(

                  signed
                      ? "SIGNED"
                      : "REQUIRED",

                  style:
                      AppTextStyles.small
                          .copyWith(

                    color:
                        signed
                            ? Colors.green
                            : Colors.red,

                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(

            description,

            style:
                AppTextStyles.small
                    .copyWith(
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 14),

          InkWell(

            onTap: onTap,

            child: Container(

              height: 44,

              decoration:
                  BoxDecoration(

                color:
                    Colors.grey.shade100,

                borderRadius:
                    BorderRadius.circular(
                  12,
                ),

                border: Border.all(
                  color: Colors.black12,
                ),
              ),

              child: Center(

                child: Text(

                  signed
                      ? "Signed Successfully"
                      : "Review & Sign",

                  style:
                      AppTextStyles.label
                          .copyWith(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}