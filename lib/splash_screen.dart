import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:takedat_app/constant/session_manager.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/router/my_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    /// ⏱ 2 sec delay → GoRouter navigation
    Timer(const Duration(seconds: 2), () {
      if (SessionManager.isLoggedIn()) {
        context.go(MyRoutes.attendanceScreen);
      } else {
        context.go(MyRoutes.loginScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// 🌈 Gradient using your colors
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.background,
              AppColors.secondary,
              AppColors.background,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Stack(
            children: [
              /// 🔹 CENTER CONTENT
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// ICON BOX
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.shield,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// APP NAME
                    Text(
                      "Takedat",
                      style: AppTextStyles.headline.copyWith(fontSize: 28),
                    ),

                    const SizedBox(height: 6),

                    /// TAGLINE
                    Text(
                      "Secure Your Future",
                      style: AppTextStyles.body.copyWith(fontSize: 14),
                    ),

                    const SizedBox(height: 30),

                    /// LOADER
                    SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// LOADING TEXT
                    Text(
                      "ESTABLISHING SECURE CONNECTION",
                      style: AppTextStyles.small.copyWith(
                        letterSpacing: 1.5,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),

              /// 🔹 FOOTER LEFT
              Positioned(
                bottom: 20,
                left: 20,
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: Colors.white54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Encrypted via ",
                      style: AppTextStyles.small.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                    Text(
                      "Quantum256",
                      style: AppTextStyles.label.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),

              /// 🔹 FOOTER RIGHT
              Positioned(
                bottom: 16,
                right: 20,
                child: Row(
                  children: [
                    _circleIcon(Icons.fingerprint),
                    const SizedBox(width: 10),
                    _circleIcon(Icons.security),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, size: 18, color: Colors.white70),
    );
  }
}
