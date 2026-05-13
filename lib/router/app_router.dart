
import 'package:go_router/go_router.dart';
import 'package:takedat_app/router/my_routes.dart';
import 'package:takedat_app/screens/attendance/ui/attendance_screen.dart';
import 'package:takedat_app/screens/auth/login/ui/login_screen.dart';
import 'package:takedat_app/screens/auth/register/ui/register.dart';
import 'package:takedat_app/screens/contractor/ui/contractor_screen.dart';
import 'package:takedat_app/screens/employees/ui/employees_screen.dart';
import 'package:takedat_app/screens/mainLayout/main_layout.dart';
import 'package:takedat_app/screens/payment/ui/payment_screen.dart';
import 'package:takedat_app/screens/settings/setting.dart';
import 'package:takedat_app/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: MyRoutes.splashScreen,
  routes: [
    GoRoute(
      path: MyRoutes.splashScreen,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path:MyRoutes.loginScreen,
      builder: (context, state) => const LoginScreen(),
    ),
      GoRoute(
      path:MyRoutes.registerScreen,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path:MyRoutes.settingScreen,
      builder: (context, state) => const ManageStatusScreen(),
    ),

     /// 🔥 MAIN APP WITH HEADER + BOTTOM NAV
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [

        GoRoute(
          path: MyRoutes.attendanceScreen,
          builder: (context, state) => const AttendanceScreen(),
        ),

        GoRoute(
          path: MyRoutes.employeeScreen,
          builder: (context, state) => const EmployeeComplianceScreen(),
        ),

        GoRoute(
          path: MyRoutes.paymentScreen,
          builder: (context, state) => const PaymentScreen(),
        ),

        GoRoute(
          path: MyRoutes.contractorScreen,
          builder: (context, state) => const ContractorScreen(),
        ),
      ],
    ),
  ],
);
