import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;
  Timer? _failsafe;

  @override
  void initState() {
    super.initState();
    _failsafe = Timer(const Duration(seconds: 8), () => _goToLoginOrHome(false));
    _initializeAndNavigate();
  }

  @override
  void dispose() {
    _failsafe?.cancel();
    super.dispose();
  }

  void _goToLoginOrHome(bool authenticated) {
    if (!mounted || _navigated) return;
    _navigated = true;
    _failsafe?.cancel();
    Navigator.pushReplacementNamed(
      context,
      authenticated ? AppRoutes.home : '/login',
    );
  }

  Future<void> _initializeAndNavigate() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted || _navigated) return;

    var authenticated = false;
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.initialize().timeout(const Duration(seconds: 5));
      authenticated = authProvider.isAuthenticated;
    } catch (_) {
      authenticated = false;
    }
    _goToLoginOrHome(authenticated);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.safety,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.health_and_safety_rounded,
                size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text('SafeShake',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 8),
            Text('Safety in the Shake of Your Hand',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
