import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import '../shared/providers/auth_provider.dart';
import '../shared/providers/settings_provider.dart';
import '../shared/providers/contacts_provider.dart';
import '../shared/providers/shake_provider.dart';
import '../core/services/alert_service.dart';
import '../features/authentication/screens/login_screen.dart';
import '../features/authentication/screens/register_screen.dart';
import '../features/authentication/screens/forgot_password_screen.dart';
import '../features/authentication/screens/phone_auth_screen.dart';
import '../features/authentication/screens/profile_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';

class SafeShakeApp extends StatelessWidget {
  const SafeShakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final alertService = AlertService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider.value(value: alertService),
        ChangeNotifierProxyProvider<AuthProvider, SettingsProvider>(
          create: (_) => SettingsProvider(null),
          update: (_, authProvider, __) {
            return SettingsProvider(authProvider.user?.uid)..loadSettings();
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ContactsProvider>(
          create: (_) => ContactsProvider(null),
          update: (_, authProvider, __) {
            return ContactsProvider(authProvider.user?.uid)..loadContacts();
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ShakeProvider>(
          create: (_) => ShakeProvider(alertService),
          update: (_, authProvider, __) {
            return ShakeProvider(alertService);
          },
        ),
      ],
      child: MaterialApp(
        title: 'SafeShake',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.splash,
        routes: {
          ...AppRoutes.routes,
          '/register': (_) => const RegisterScreen(),
          '/login': (_) => const LoginScreen(),
          '/forgot-password': (_) => const ForgotPasswordScreen(),
          '/phone-auth': (_) => const PhoneAuthScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/onboarding': (_) => const OnboardingScreen(),
        },
      ),
    );
  }
}
