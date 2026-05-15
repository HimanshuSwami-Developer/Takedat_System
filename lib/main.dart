import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takedat_app/constant/session_manager.dart';

import 'package:takedat_app/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 await Supabase.initialize(
   url: 'https://ylrjuvqnajsmfwvsqzsm.supabase.co',
  anonKey: 'sb_publishable_A_XrAsxrYA2cI1-zP_oY8A_jpJuOAQT',
   authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
  ),
  );
  await SessionManager.init();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Takedat',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}