import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takedat_app/constant/session_manager.dart';

import 'package:takedat_app/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 await Supabase.initialize(
  url:'https://pbgmovxdwfzvgaskwqlt.supabase.co',
  anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBiZ21vdnhkd2Z6dmdhc2t3cWx0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjU3MzM3MiwiZXhwIjoyMDk4MTQ5MzcyfQ.C8msQTaX2ZZ5L062jlPnIQdW_ATYDz7x1NsrPhJdsoQ',
  //  url: 'https://ylrjuvqnajsmfwvsqzsm.supabase.co',
  // anonKey: 'sb_publishable_A_XrAsxrYA2cI1-zP_oY8A_jpJuOAQT',
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
      title: '4 You Solution',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}