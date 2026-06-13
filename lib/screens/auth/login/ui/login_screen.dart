import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/router/my_routes.dart';
import 'package:takedat_app/screens/auth/login/bloc/auth_bloc.dart';
import 'package:takedat_app/screens/auth/login/bloc/auth_event.dart';
import 'package:takedat_app/screens/auth/login/bloc/auth_state.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';
import 'package:takedat_app/utils/app_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int selectedTab = 0;
  bool showOtpVerify = false;

  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpEmailController = TextEditingController();
  final TextEditingController _otpController      = TextEditingController();

  String? _verificationId;

  // ── Resend timer ─────────────────────────────────────────────────────────
  Timer?  _resendTimer;
  int     _secondsLeft  = 30;
  bool    _canResend    = false;

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _secondsLeft = 30;
      _canResend   = false;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
        } else {
          _secondsLeft = 0;
          _canResend   = true;
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _otpEmailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.of(context).size;
    final isWeb = size.width > 800;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          AppToast.success(context, "Login successful! Welcome.");
          context.go(MyRoutes.attendanceScreen);
        } else if (state is AuthFailure) {
          AppToast.error(context, state.message);
        } else if (state is OtpSentState) {
          _verificationId = state.verificationId;
          AppToast.success(context, "OTP sent to your email!");
          setState(() => showOtpVerify = true);
          _startResendTimer(); // ← start timer whenever OTP is sent/resent
        }
      },
      child: Scaffold(
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

                    Text(
                      "Secure Login",
                      style: AppTextStyles.headline.copyWith(
                        color: Colors.black,
                        fontSize: 26,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Enter your details to access your vault.",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(color: Colors.black54),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildTab("Login", 0),
                          _buildTab("OTP", 1),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

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

                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text("Or continue with",
                              style: AppTextStyles.small),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                context.push(MyRoutes.registerScreen),
                            child: _socialButton(
                              "Register New Employees",
                              Icons.fingerprint,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text.rich(
                      TextSpan(
                        text: "By continuing, you agree to our ",
                        style: AppTextStyles.small
                            .copyWith(color: Colors.black54),
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield, size: 14),
                        const SizedBox(width: 6),
                        Text("END-TO-END ENCRYPTED",
                            style: AppTextStyles.small),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── TAB BUILDER ──────────────────────────────────────────────────────────────
  Widget _buildTab(String label, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          selectedTab  = index;
          showOtpVerify = false;
          _otpController.clear();
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selectedTab == index ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: selectedTab == index
                    ? AppColors.primary
                    : Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── EMAIL + PASSWORD LOGIN FORM ──────────────────────────────────────────────
  Widget _emailLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Email Address",
          hint: "name@example.com",
          icon: Icons.email_outlined,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: "Password",
          hint: "••••••••",
          icon: Icons.lock_outline,
          isPassword: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 20),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return CustomButton(
              text: isLoading ? "Verifying..." : "Continue to Vault",
              icon: Icons.arrow_forward,
              onTap: isLoading
                  ? null
                  : () {
                      final email    = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      if (email.isEmpty || password.isEmpty) {
                        AppToast.warning(
                            context, "Please enter email and password.");
                        return;
                      }
                      context.read<AuthBloc>().add(
                            AdminLoginEvent(
                              email: email,
                              password: password,
                            ),
                          );
                    },
            );
          },
        ),
      ],
    );
  }

  // ── EMAIL OTP REQUEST FORM ───────────────────────────────────────────────────
  Widget _otpRequestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Email Address",
          hint: "name@example.com",
          icon: Icons.email_outlined,
          controller: _otpEmailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return CustomButton(
              text: isLoading ? "Sending OTP..." : "Send OTP",
              onTap: isLoading
                  ? null
                  : () {
                      final email = _otpEmailController.text.trim();
                      if (email.isEmpty) {
                        AppToast.warning(
                            context, "Please enter your email.");
                        return;
                      }
                      context.read<AuthBloc>().add(SendOtpEvent(email));
                    },
            );
          },
        ),
      ],
    );
  }

  // ── EMAIL OTP VERIFY FORM ────────────────────────────────────────────────────
  Widget _otpVerifyForm() {
    // Format seconds as "0:30", "0:09" etc.
    final String countdown =
        "0:${_secondsLeft.toString().padLeft(2, '0')}";

    return Column(
      children: [
        /// HEADER
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_read,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              "Email Verification",
              style: AppTextStyles.headline
                  .copyWith(color: Colors.black, fontSize: 16),
            ),
          ],
        ),

        const SizedBox(height: 6),

        /// EMAIL MASK
        Wrap(
          children: [
            Text(
              "We've sent a 6-digit code to",
              textAlign: TextAlign.center,
              style: AppTextStyles.small.copyWith(color: Colors.black54),
            ),
            const SizedBox(width: 6),
            Text(
              _otpEmailController.text.isNotEmpty
                  ? _otpEmailController.text
                  : "your email",
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ],
        ),

        const SizedBox(height: 12),

        /// PIN INPUT
        Pinput(
          length: 6,
          controller: _otpController,
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

        /// VERIFY BUTTON
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return CustomButton(
              text: isLoading ? "Verifying..." : "Verify Code",
              onTap: isLoading
                  ? null
                  : () {
                      final otp = _otpController.text.trim();
                      if (otp.length < 6) {
                        AppToast.warning(
                            context, "Please enter the 6-digit OTP.");
                        return;
                      }
                      if (_verificationId == null) {
                        AppToast.error(context,
                            "Session expired. Please resend OTP.");
                        return;
                      }
                      context.read<AuthBloc>().add(
                            VerifyOtpEvent(
                              verificationId: _verificationId!,
                              otp: otp,
                              email: _otpEmailController.text.trim(),
                            ),
                          );
                    },
            );
          },
        ),

        const SizedBox(height: 16),

        /// RESEND ROW — disabled with countdown OR enabled as tappable text
        if (_canResend)
          GestureDetector(
            onTap: () {
              final email = _otpEmailController.text.trim();
              if (email.isEmpty) return;
              _otpController.clear();
              setState(() => showOtpVerify = false);
              context.read<AuthBloc>().add(SendOtpEvent(email));
              // timer restarts via OtpSentState listener above
            },
            child: Text(
              "Didn't receive the code? Resend OTP",
              style: AppTextStyles.small.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          // Greyed-out resend + live countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Resend OTP in ",
                style: AppTextStyles.small.copyWith(color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      countdown,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

        const SizedBox(height: 6),
      ],
    );
  }

  // ── SOCIAL BUTTON ─────────────────────────────────────────────────────────────
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