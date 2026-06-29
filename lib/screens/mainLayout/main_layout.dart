import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takedat_app/constant/session_keys.dart';
import 'package:takedat_app/constant/session_manager.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/router/my_routes.dart';
import 'package:takedat_app/utils/app_utils.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;
    final role = SessionManager.getString(SessionKeys.role);

    final fullName = SessionManager.getString(SessionKeys.fullName);

    final empId = SessionManager.getString(SessionKeys.empId);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),

      /// =========================
      /// DESKTOP/TABLET
      /// =========================
      body: isDesktop
          ? Row(
              children: [
                /// SIDEBAR
                _sideBar(context),

                /// CONTENT
                Expanded(
                  child: Column(
                    children: [
                      /// HEADER
                      PreferredSize(
                        preferredSize: const Size.fromHeight(60),

                        child: _header(
                          isDesktop,
                          fullName,
                          empId,
                          role,
                          context,
                        ),
                      ),

                      /// BODY
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            )
          /// =========================
          /// MOBILE
          /// =========================
          : Column(
              children: [
                /// HEADER
                PreferredSize(
                  preferredSize: const Size.fromHeight(90),

                  child: _header(isDesktop, fullName, empId, role, context),
                ),

                /// BODY
                Expanded(child: child),
              ],
            ),

      /// MOBILE ONLY
      bottomNavigationBar: isDesktop ? null : _bottomNav(context),
    );
  }

  /// ============================
  /// HEADER
  /// ============================

  Widget _header(
    bool isDesktop,
    String fullName,
    String empId,
    String role,
    BuildContext context,
  ) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),

        decoration: BoxDecoration(
          border: Border.symmetric(horizontal: BorderSide(width: 0.2)),
          color: Colors.white,
        ),

        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.person_2_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text(
                  fullName,

                  style: const TextStyle(
                    fontSize: 12,

                    fontWeight: FontWeight.w700,
                  ),
                ),

                Text(
                  "Employee ID: $empId",

                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),

            const Spacer(),

            /// LOGOUT BUTTON
            InkWell(
              onTap: () async {
                final confirm = await AppUtils.show(
                  context: context,

                  title: "Logout",

                  message: "Are you sure you want to logout from your account?",

                  confirmText: "Logout",

                  confirmColor: Colors.red,

                  icon: Icons.logout_rounded,
                );

                if (confirm == true) {
                  /// SIGN OUT
                  await Supabase.instance.client.auth.signOut();

                  /// CLEAR LOCAL SESSION
                  await SessionManager.clear();

                  /// CLEAR IMAGE CACHE
                  PaintingBinding.instance.imageCache.clear();
                  PaintingBinding.instance.imageCache.clearLiveImages();

                  context.go(MyRoutes.loginScreen);
                }
              },

              child: const Icon(Icons.logout_rounded),
            ),
            const SizedBox(width: 12),
            if (role == "admin") ...[
              InkWell(
                onTap: () {
                  context.push(MyRoutes.settingScreen);
                },
                child: Icon(Icons.settings),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// ============================
  /// MOBILE BOTTOM NAV
  /// ============================

  Widget _bottomNav(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),

      decoration: const BoxDecoration(
        color: Colors.white,

        border: Border(top: BorderSide(color: Colors.black12)),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [
          _navItem(
            context,

            icon: Icons.calendar_today,

            label: "Attendance",

            route: MyRoutes.attendanceScreen,

            active: location == MyRoutes.attendanceScreen,
          ),

          if (SessionManager.getString(SessionKeys.role) == "admin")
            _navItem(
              context,

              icon: Icons.people,

              label: "Employees",

              route: MyRoutes.employeeScreen,

              active: location == MyRoutes.employeeScreen,
            ),

          _navItem(
            context,

            icon: Icons.payments,

            label: "Payments",

            route: MyRoutes.paymentScreen,

            active: location == MyRoutes.paymentScreen,
          ),

          if (SessionManager.getString(SessionKeys.role) == "admin")
            _navItem(
              context,

              icon: Icons.work,

              label: "Contractors",

              route: MyRoutes.contractorScreen,

              active: location == MyRoutes.contractorScreen,
            ),

          if (SessionManager.getString(SessionKeys.role) == "user")
            _navItem(
              context,

              icon: Icons.work,

              label: "Profile",

              route: MyRoutes.profileScreen,

              active: location == MyRoutes.profileScreen,
            ),
        ],
      ),
    );
  }

  /// ============================
  /// DESKTOP SIDEBAR
  /// ============================

  Widget _sideBar(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Container(
      width: 250,

      decoration: BoxDecoration(
        color: Colors.white,

        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),

      child: Column(
        children: [
          /// LOGO
          Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                        child: Image.asset(
                          'assets/logo.webp',
                          width: 100,
                          height: 88,
                          fit: BoxFit.contain,
                        ),
                      ),


          const SizedBox(height: 10),

          /// MENU
          _sideItem(
            context,

            icon: Icons.calendar_today,

            label: "Attendance",

            route: MyRoutes.attendanceScreen,

            active: location == MyRoutes.attendanceScreen,
          ),

          if (SessionManager.getString(SessionKeys.role) == "admin")
            _sideItem(
              context,

              icon: Icons.people,

              label: "Employees",

              route: MyRoutes.employeeScreen,

              active: location == MyRoutes.employeeScreen,
            ),

          _sideItem(
            context,

            icon: Icons.payments,

            label: "Payments",

            route: MyRoutes.paymentScreen,

            active: location == MyRoutes.paymentScreen,
          ),

          if (SessionManager.getString(SessionKeys.role) == "admin")
            _sideItem(
              context,

              icon: Icons.work,

              label: "Contractors",

              route: MyRoutes.contractorScreen,

              active: location == MyRoutes.contractorScreen,
            ),


          if (SessionManager.getString(SessionKeys.role) == "user")
            _sideItem(
              context,

              icon: Icons.work,

              label: "Profile",

              route: MyRoutes.profileScreen,

              active: location == MyRoutes.profileScreen,
            ),


        ],
      ),
    );
  }

  /// ============================
  /// MOBILE ITEM
  /// ============================

  Widget _navItem(
    BuildContext context, {

    required IconData icon,
    required String label,
    required String route,
    required bool active,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),

      onTap: () {
        context.go(route);
      },

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(icon, color: active ? AppColors.primary : Colors.grey),

            const SizedBox(height: 4),

            Text(
              label,

              style: TextStyle(
                color: active ? AppColors.primary : Colors.grey,

                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ============================
  /// SIDEBAR ITEM
  /// ============================

  Widget _sideItem(
    BuildContext context, {

    required IconData icon,
    required String label,
    required String route,
    required bool active,
  }) {
    return GestureDetector(
      onTap: () {
        context.go(route);
      },

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),

        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withOpacity(.08)
              : Colors.transparent,

          borderRadius: BorderRadius.circular(14),
        ),

        child: Row(
          children: [
            Icon(icon, color: active ? AppColors.primary : Colors.grey),

            const SizedBox(width: 14),

            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.primary : Colors.grey,

                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
