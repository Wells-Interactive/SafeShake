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
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.initialize();
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      authProvider.isAuthenticated ? AppRoutes.home : '/login',
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.brand,
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
