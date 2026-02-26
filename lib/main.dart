import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.init();

  runApp(const ProviderScope(child: BgManagerApp()));
}

class BgManagerApp extends StatelessWidget {
  const BgManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BG Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

/// Auth wrapper - decides between Login screen and Home screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: SupabaseService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth status
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        final authState = snapshot.data;

        // If user is logged in, show main app
        if (authState?.event == AuthChangeEvent.signedIn ||
            SupabaseService.isLoggedIn) {
          return const HomeScreen();
        }

        // Otherwise show login screen
        return const LoginScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1E293B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              'BG Manager',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
