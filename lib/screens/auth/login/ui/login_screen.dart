import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/router/my_routes.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int selectedTab = 0; // 0 = Email, 1 = OTP
  bool showOtpVerify = false;
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: isWeb ? 500 : double.infinity,
              padding: EdgeInsets.symmetric(horizontal: isWeb ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
          
                  /// 🔹 ICON
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
          
                  const SizedBox(height: 20),
          
                  /// 🔹 TITLE
                  Text(
                    "Secure Login",
                    style: AppTextStyles.headline.copyWith(
                      color: Colors.black,
                      fontSize: 26,
                    ),
                  ),
          
                  const SizedBox(height: 8),
          
                  /// 🔹 SUBTITLE
                  Text(
                    "Enter your details to access your vault.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(color: Colors.black54),
                  ),
          
                  const SizedBox(height: 20),
          
                  /// 🔹 TAB SWITCH
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTab = 0;
                                showOtpVerify = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedTab == 0
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Login",
                                  style: AppTextStyles.label.copyWith(
                                    color: selectedTab == 0
                                        ? AppColors.primary
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
          
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTab = 1;
                                showOtpVerify = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedTab == 1
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "OTP",
                                  style: AppTextStyles.label.copyWith(
                                    color: selectedTab == 1
                                        ? AppColors.primary
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          
                  const SizedBox(height: 12),
          
                  /// 🔹 FORM CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 🔥 FORM SWITCHING
                        if (showOtpVerify)
                          _otpVerifyForm()
                        else if (selectedTab == 0)
                          _emailLoginForm()
                        else
                          _otpRequestForm(),
                      ],
                    ),
                  ),
          
                  const SizedBox(height: 12),
          
                  /// 🔹 DIVIDER
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Or continue with",
                          style: AppTextStyles.small,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
          
                  const SizedBox(height: 12),
          
                  /// 🔹 SOCIAL
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            context.push(MyRoutes.registerScreen);
                          },
                          child: _socialButton(
                            "Register New Employees",
                            Icons.fingerprint,
                          ),
                        ),
                      ),
                    ],
                  ),
          
                  const SizedBox(height: 12),
          
                  /// 🔹 TERMS
                  Text.rich(
                    TextSpan(
                      text: "By continuing, you agree to our ",
                      style: AppTextStyles.small.copyWith(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: "Terms of Service",
                          style: TextStyle(color: AppColors.primary),
                        ),
                        const TextSpan(text: " and "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
          
                  const SizedBox(height: 10),
          
                  /// 🔹 FOOTER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield, size: 14),
                      const SizedBox(width: 6),
                      Text("END-TO-END ENCRYPTED", style: AppTextStyles.small),
                    ],
                  ),
          
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ============================
  /// 🔹 EMAIL LOGIN FORM
  /// ============================
  Widget _emailLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Email Address",
          hint: "name@example.com",
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),

        CustomTextField(
          label: "Password",
          hint: "••••••••",
          icon: Icons.lock_outline,
          isPassword: true,
        ),

        const SizedBox(height: 20),

        CustomButton(
          text: "Continue to Vault",
          icon: Icons.arrow_forward,
          onTap: () {
            context.go(MyRoutes.attendanceScreen);
          },
        ),
      ],
    );
  }

  /// ============================
  /// 🔹 OTP REQUEST FORM
  /// ============================
  Widget _otpRequestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Email Address",
          hint: "name@example.com",
          icon: Icons.email_outlined,
        ),

        const SizedBox(height: 20),

        CustomButton(
          text: "Send OTP",
          onTap: () {
            setState(() {
              showOtpVerify = true;
            });
          },
        ),
      ],
    );
  }

  /// ============================
  /// 🔹 OTP VERIFY FORM
  /// ============================
  Widget _otpVerifyForm() {
    return Column(
      children: [
        /// 🔹 ICON
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_user,
                color: AppColors.primary,
                size: 20,
              ),
            ),

            const SizedBox(width: 16),

            /// 🔹 TITLE
            Text(
              "Verification",
              style: AppTextStyles.headline.copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        /// 🔹 DESCRIPTION
        Wrap(
          children: [
            Text(
              "We've sent a 6-digit code to your email",
              textAlign: TextAlign.center,
              style: AppTextStyles.small.copyWith(color: Colors.black54),
            ),

            const SizedBox(width: 6),

            /// 🔹 EMAIL MASK
            Text(
              "m***a@infisecure.com",
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ],
        ),

        const SizedBox(height: 12),

        /// 🔹 PIN INPUT (Styled)
        Pinput(
          length: 6,
          defaultPinTheme: PinTheme(
            width: 50,
            height: 55,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          focusedPinTheme: PinTheme(
            width: 50,
            height: 55,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
          ),
        ),

        const SizedBox(height: 24),

        /// 🔹 VERIFY BUTTON
        CustomButton(text: "Verify Code", onTap: () {context.go(MyRoutes.attendanceScreen);}),

        const SizedBox(height: 14),

        /// 🔹 RESEND TEXT
        Text(
          "Didn't receive the code? Resend Code",
          style: AppTextStyles.small.copyWith(color: Colors.black54),
        ),

        const SizedBox(height: 6),

        /// 🔹 TIMER
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              "Resend in 00:54",
              style: AppTextStyles.small.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  /// ============================
  /// 🔹 SOCIAL BUTTON
  /// ============================
  Widget _socialButton(String text, IconData icon) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(
              text,
              style: AppTextStyles.label.copyWith(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
