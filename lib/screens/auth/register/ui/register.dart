import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/router/my_routes.dart';
import 'package:takedat_app/screens/auth/register/steps/document_upload_step.dart';
import 'package:takedat_app/screens/auth/register/steps/personal_details_step.dart';
import 'package:takedat_app/screens/auth/register/steps/sign_documents_step.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int step = 2;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),

      body: SafeArea(
        child: Center(
          child: Container(
             width: isWeb ? 500 : double.infinity,
              padding: EdgeInsets.symmetric(horizontal: isWeb ? 0 : 8),
            child: Column(
              children: [
                /// 🔹 HEADER
                _header(),
          
                /// 🔹 STEP CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    child: step == 1
                        ? PersonalDetailsStep(
                            onNext: () {
                              setState(() => step = 2);
                            },
                          )
                        : step == 2
                        ? DocumentUploadStep(
                            onNext: () {
                              setState(() => step = 3);
                            },
                          )
                        : SignDocumentsStep(
                            onComplete: () {
                              context.go(MyRoutes.loginScreen);
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

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Verification",
              style: AppTextStyles.label.copyWith(
                fontSize: 18,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Icon(Icons.help_outline),
        ],
      ),
    );
  }
}
