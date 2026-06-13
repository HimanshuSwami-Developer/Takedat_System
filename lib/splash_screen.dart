import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:takedat_app/constant/session_manager.dart';
import 'package:takedat_app/router/my_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;

  // ── Brand colors ───────────────────────────────────────────────────────────
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _red = Color(0xFFCC0000);
  static const Color _lightGrey = Color(0xFFF5F5F5);
  static const Color _darkGrey = Color(0xFF1A1A1A);
  static const Color _softWhite = Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnim = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _slideAnim = Tween<double>(
      begin: 20,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (SessionManager.isLoggedIn()) {
        context.go(MyRoutes.attendanceScreen);
      } else {
        context.go(MyRoutes.loginScreen);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Clean white → very light grey gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_white, _lightGrey, _softWhite],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ── Red accent bar at very top ──────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_red, Color(0xFFFF5252), _red],
                    ),
                  ),
                ),
              ),

              // ── Subtle red circle top-right ─────────────────────────────
              Positioned(
                top: -80,
                right: -80,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _red.withOpacity(0.05),
                  ),
                ),
              ),

              // ── Subtle red circle bottom-left ───────────────────────────
              Positioned(
                bottom: -60,
                left: -60,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _red.withOpacity(0.04),
                  ),
                ),
              ),

              // ── CENTER CONTENT ──────────────────────────────────────────
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) => FadeTransition(
                    opacity: _fadeAnim,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnim.value),
                      child: ScaleTransition(scale: _scaleAnim, child: child),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── LOGO ─────────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: _white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _red.withOpacity(0.12),
                              blurRadius: 40,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/logo.webp',
                          width: 190,
                          height: 88,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── DIVIDER ───────────────────────────────────────────
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 1.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  _red.withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: _red.withOpacity(0.08),
                              shape: BoxShape.circle,
                              border: Border.all(color: _red.withOpacity(0.2)),
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              color: _red,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 48,
                            height: 1.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _red.withOpacity(0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ── TAGLINE ───────────────────────────────────────────
                      Text(
                        "SECURITY SERVICES PROVIDER",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: _darkGrey.withOpacity(0.45),
                          letterSpacing: 2.8,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // ── LOADER ────────────────────────────────────────────
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation(_red),
                          backgroundColor: _red.withOpacity(0.1),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── LOADING TEXT ──────────────────────────────────────
                      Text(
                        "ESTABLISHING SECURE CONNECTION",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: _darkGrey.withOpacity(0.3),
                          letterSpacing: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── TOP-LEFT — SIA badge ────────────────────────────────────
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _red.withOpacity(0.25)),
                    boxShadow: [
                      BoxShadow(color: _red.withOpacity(0.08), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22c55e),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "SIA Licensed",
                        style: TextStyle(
                          fontSize: 10,
                          color: _darkGrey.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── FOOTER LEFT — encrypted ─────────────────────────────────
              Positioned(
                bottom: 20,
                left: 16,
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 13,
                      color: _darkGrey.withOpacity(0.35),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Encrypted via ",
                      style: TextStyle(
                        fontSize: 11,
                        color: _darkGrey.withOpacity(0.35),
                      ),
                    ),
                    const Text(
                      "Quantum256",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _red,
                      ),
                    ),
                  ],
                ),
              ),

              // ── FOOTER RIGHT — icons ────────────────────────────────────
              Positioned(
                bottom: 14,
                right: 16,
                child: Row(
                  children: [
                    _circleIcon(Icons.fingerprint),
                    const SizedBox(width: 8),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _red.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: _red.withOpacity(0.08), blurRadius: 8)],
      ),
      child: Icon(icon, size: 16, color: _red.withOpacity(0.6)),
    );
  }
}
