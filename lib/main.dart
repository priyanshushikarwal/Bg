import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'core/services/settings_service.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    // Use a stable, permanent path for Hive to avoid hot-restart data loss
    final docsDir = await getApplicationDocumentsDirectory();
    final hivePath = '${docsDir.path}${Platform.pathSeparator}BgManagerData';
    final hiveDir = Directory(hivePath);
    if (!hiveDir.existsSync()) {
      hiveDir.createSync(recursive: true);
    }

    // Clean up stale lock files to prevent hot-restart lock errors
    try {
      final lockFile = File('$hivePath${Platform.pathSeparator}app_settings.lock');
      if (lockFile.existsSync()) {
        lockFile.deleteSync();
      }
    } catch (_) {}

    Hive.init(hivePath);
  }

  await SettingsService.init();
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: SupabaseService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        final authState = snapshot.data;

        if (authState?.event == AuthChangeEvent.signedIn ||
            SupabaseService.isLoggedIn) {
          return const HomeScreen();
        }

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
