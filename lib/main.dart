import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'core/services/morning_reminder_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SafeShakeApp());
  unawaited(_bootstrapServices());
}

Future<void> _bootstrapServices() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
          .timeout(const Duration(seconds: 20));
    }
  } catch (_) {}
  unawaited(_initializeMorningReminder());
}

Future<void> _initializeMorningReminder() async {
  try {
    await Future<void>.delayed(const Duration(seconds: 3));
    await MorningReminderService().initializeAndSchedule();
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'morning reminder initialization',
      ),
    );
  }
}
