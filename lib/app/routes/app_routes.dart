import 'package:flutter/material.dart';
import '../../features/home/screens/main_shell.dart';
import '../../features/splash/screens/splash_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const home = '/home';

  static final routes = <String, WidgetBuilder>{
    splash: (_) => const SplashScreen(),
    home: (_) => const MainShell(),
  };
}
