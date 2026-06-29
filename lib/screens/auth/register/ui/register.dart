import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:takedat_app/constant/session_keys.dart';
import 'package:takedat_app/constant/session_manager.dart';

import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/repository/user_repo.dart';
import 'package:takedat_app/router/my_routes.dart';

import 'package:takedat_app/screens/auth/register/steps/document_upload_step.dart';
import 'package:takedat_app/screens/auth/register/steps/personal_details_step.dart';
import 'package:takedat_app/screens/auth/register/steps/sign_documents_step.dart';
import 'package:takedat_app/utils/app_utils.dart';

class RegisterScreen extends StatefulWidget {

  /// When provided, RegisterScreen runs in admin mode:
  /// skips checkUserProgress, restores admin session on completion,
  /// and calls this callback instead of navigating to login.
  final VoidCallback? onComplete;

  const RegisterScreen({
    super.key,
    this.onComplete,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  int step = 1;

  bool isLoading = true;

  final repository = UserRepository();

  // Saved admin session keys — restored after employee registration
  String? _adminUserId;
  String? _adminEmail;
  String? _adminFullName;
  String? _adminEmpId;
  String? _adminPhone;
  String? _adminAddress;
  String? _adminCompanyCode;

  bool get _isAdminMode => widget.onComplete != null;

  @override
  void initState() {
    super.initState();

    if (_isAdminMode) {
      _saveAdminSession();
    } else {
      checkUserProgress();
    }
  }

  void _saveAdminSession() {
    _adminUserId      = SessionManager.getString(SessionKeys.userId);
    _adminEmail       = SessionManager.getString(SessionKeys.email);
    _adminFullName    = SessionManager.getString(SessionKeys.fullName);
    _adminEmpId       = SessionManager.getString(SessionKeys.empId);
    _adminPhone       = SessionManager.getString(SessionKeys.phone);
    _adminAddress     = SessionManager.getString(SessionKeys.address);
    _adminCompanyCode = SessionManager.getString(SessionKeys.companyCode);
    setState(() => isLoading = false);
  }

  Future<void> _restoreAdminSession() async {
    await SessionManager.saveString(SessionKeys.userId,      _adminUserId      ?? '');
    await SessionManager.saveString(SessionKeys.email,       _adminEmail       ?? '');
    await SessionManager.saveString(SessionKeys.fullName,    _adminFullName    ?? '');
    await SessionManager.saveString(SessionKeys.empId,       _adminEmpId       ?? '');
    await SessionManager.saveString(SessionKeys.phone,       _adminPhone       ?? '');
    await SessionManager.saveString(SessionKeys.address,     _adminAddress     ?? '');
    await SessionManager.saveString(SessionKeys.companyCode, _adminCompanyCode ?? '');
  }

  /// =====================================================
  /// CHECK USER FLOW
  /// =====================================================

Future<void> checkUserProgress() async {

  try {

    final userId =
        await SessionManager.getString(
      SessionKeys.userId,
    );

    /// ===============================================
    /// NO USER
    /// ===============================================

    if (userId.isEmpty) {

      setState(() {

        step = 1;

        isLoading = false;
      });

      return;
    }

    /// ===============================================
    /// CHECK SIGNED DOCS
    /// ===============================================

    final hasSignedDocs =
        await repository
            .hasSignedDocuments(
      userId,
    );

    /// ===============================================
    /// USER ALREADY REGISTERED
    /// ===============================================

    if (hasSignedDocs) {

      setState(() {

        isLoading = false;
      });

      WidgetsBinding.instance
          .addPostFrameCallback((_) {

        AppUtils.showDialogMessage(
          context,
          title: 'User Already Registered',
          message: 'You have already completed the registration process.',
          onTap: () {
            context.go(
              MyRoutes.loginScreen,
            );
          },
        );
      });

      return;
    }

    /// ===============================================
    /// CHECK NORMAL DOCS
    /// ===============================================

    final hasDocs =
        await repository
            .hasUploadedDocuments(
      userId,
    );

    setState(() {

      /// DOCS EXIST
      if (hasDocs) {

        step = 3;
      }

      /// ONLY USER EXISTS
      else {

        step = 2;
      }

      isLoading = false;
    });

  } catch (e) {

    setState(() {

      step = 1;

      isLoading = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {

    final size =
        MediaQuery.of(context).size;

    final isWeb =
        size.width > 800;

    return Scaffold(

      backgroundColor:
          const Color(0xFFF4F7F5),

      body: SafeArea(

        child: isLoading

            ? const Center(
                child:
                    CircularProgressIndicator(),
              )

            : Center(

                child: Container(

                  width: isWeb
                      ? 500
                      : double.infinity,

                  padding:
                      EdgeInsets.symmetric(
                    horizontal:
                        isWeb ? 0 : 8,
                  ),

                  child: Column(

                    children: [

                      /// HEADER
                      _header(),

                      /// CONTENT
                      Expanded(

                        child:
                            SingleChildScrollView(

                          child:

                              /// STEP 1
                              step == 1

                                  ? PersonalDetailsStep(

                                      onNext: () {

                                        setState(() {

                                          step = 2;
                                        });
                                      },
                                    )

                                  :

                                  /// STEP 2
                                  step == 2

                                      ? DocumentUploadStep(

                                          onNext: () {

                                            setState(() {

                                              step = 3;
                                            });
                                          },
                                        )

                                      :

                                      /// STEP 3
                                      SignDocumentsStep(

                                          onComplete: () async {

                                            if (_isAdminMode) {
                                              await _restoreAdminSession();
                                              widget.onComplete!();
                                            } else {
                                              context.go(
                                                MyRoutes.loginScreen,
                                              );
                                            }
                                          },
                                        ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// =====================================================
  /// HEADER
  /// =====================================================

  Widget _header() {

    return Padding(

      padding:
          const EdgeInsets.all(16),

      child: Row(

        children: [

          GestureDetector(

            onTap: () => context.pop(),

            child: const Icon(
              Icons.arrow_back,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(

            child: Text(

              "Verification",

              style:
                  AppTextStyles.label
                      .copyWith(
                fontSize: 18,
                color: Colors.black,
              ),

              textAlign: TextAlign.center,
            ),
          ),

          const Icon(
            Icons.help_outline,
          ),
        ],
      ),
    );
  }
}