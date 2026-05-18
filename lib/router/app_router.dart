import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:takedat_app/repository/attendance_repo.dart';
import 'package:takedat_app/repository/auth_repo.dart';
import 'package:takedat_app/repository/contractor_repo.dart';
import 'package:takedat_app/repository/payment_repo.dart';
import 'package:takedat_app/repository/user_repo.dart';
import 'package:takedat_app/router/my_routes.dart';
import 'package:takedat_app/screens/attendance/bloc/attendance_bloc.dart';
import 'package:takedat_app/screens/attendance/bloc/attendance_event.dart';
import 'package:takedat_app/screens/attendance/ui/attendance_screen.dart';
import 'package:takedat_app/screens/auth/login/bloc/auth_bloc.dart';
import 'package:takedat_app/screens/auth/login/ui/login_screen.dart';
import 'package:takedat_app/screens/auth/register/bloc/register_bloc.dart';
import 'package:takedat_app/screens/auth/register/ui/register.dart';
import 'package:takedat_app/screens/contractor/bloc/contractor_bloc.dart';
import 'package:takedat_app/screens/contractor/ui/contractor_screen.dart';
import 'package:takedat_app/screens/employees/ui/employees_screen.dart';
import 'package:takedat_app/screens/mainLayout/main_layout.dart';
import 'package:takedat_app/screens/payment/bloc/payment_bloc.dart';
import 'package:takedat_app/screens/payment/ui/payment_screen.dart';
import 'package:takedat_app/screens/settings/bloc/settings_bloc.dart';
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
      path: MyRoutes.loginScreen,

      builder: (context, state) {
        return BlocProvider(
          create: (_) => AuthBloc(AuthRepository()),

          child: const LoginScreen(),
        );
      },
    ),
    GoRoute(
      path: MyRoutes.registerScreen,

      builder: (context, state) {
        return BlocProvider(
          create: (_) => RegisterBloc(UserRepository()),

          child: const RegisterScreen(),
        );
      },
    ),
    GoRoute(
      path: MyRoutes.settingScreen,
      builder: (context, state) => BlocProvider(
        create: (context) => ManageStatusBloc(UserRepository()),
        child: ManageStatusScreen(),
      ),
    ),

    /// 🔥 MAIN APP WITH HEADER + BOTTOM NAV
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: MyRoutes.attendanceScreen,
          builder: (context, state) => BlocProvider(
            create: (context) => AttendanceBloc(AttendanceRepository()),
            child: AttendanceScreen(),
          ),
        ),

        GoRoute(
          path: MyRoutes.employeeScreen,
          builder: (context, state) => const EmployeeComplianceScreen(),
        ),

        GoRoute(
          path: MyRoutes.paymentScreen,
          builder: (context, state) => BlocProvider(
            create: (context) => PaymentBloc(repository: PaymentTrackRepository()),
            child: PaymentScreen(),
          ),
        ),

        GoRoute(
          path: MyRoutes.contractorScreen,
          builder: (context, state) => BlocProvider(
            create: (_) => ContractorBloc(ContractorRepository()),
            child: const ContractorScreen(),
          ),
        ),
      ],
    ),
  ],
);
