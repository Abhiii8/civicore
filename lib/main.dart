/// CiviCore - Main Application Entry Point
/// 
/// E-Governance Platform
/// Supports transparency, accountability, and efficiency in government services

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';

void main() {
  runApp(const CiviCoreApp());
}

class CiviCoreApp extends StatelessWidget {
  const CiviCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CiviCore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    final isLoggedIn = await _authService.isLoggedIn();
    
    if (!mounted) return;

    if (isLoggedIn) {
      // Get user data and navigate to appropriate dashboard
      // For now, redirect to login
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance,
              size: 100,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'CiviCore',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'E-Governance Platform',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
