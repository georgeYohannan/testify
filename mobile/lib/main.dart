import 'package:flutter/material.dart';
import 'package:testify/theme.dart';
import 'package:testify/supabase/supabase_config.dart';
import 'package:testify/screens/splash_screen.dart';
import 'package:testify/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    print('Supabase initialization failed: \$e');
  }
  
  runApp(const TestifyApp());
}

class TestifyApp extends StatelessWidget {
  const TestifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Testify',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/splash': (context) => const SplashScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: SupabaseAuth.authStream,
      builder: (context, snapshot) {
        final session = SupabaseAuth.currentUser;
        
        if (session != null) {
          return const DashboardScreen();
        } else {
          return const SplashScreen();
        }
      },
    );
  }
}
