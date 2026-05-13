import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/router/my_routes.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

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

                        child: _header(isDesktop, context),
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

                  child: _header(isDesktop, context),
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

  Widget _header(bool isDesktop, BuildContext context) {
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

            const Text(
              "Admin",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            InkWell(
              onTap: () {
                context.push(MyRoutes.settingScreen);
              },
              child: Icon(Icons.settings),
            ),
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

          _navItem(
            context,

            icon: Icons.work,

            label: "Contractors",

            route: MyRoutes.contractorScreen,

            active: location == MyRoutes.contractorScreen,
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
            height: 90,

            padding: const EdgeInsets.symmetric(horizontal: 20),

            alignment: Alignment.centerLeft,

            child: const Text(
              "TAKEDAT",

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,

                color: AppColors.primary,
              ),
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

          _sideItem(
            context,

            icon: Icons.work,

            label: "Contractors",

            route: MyRoutes.contractorScreen,

            active: location == MyRoutes.contractorScreen,
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
