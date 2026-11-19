import 'dart:async';

import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/firebase_service.dart';
import 'core/services/morning_reminder_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SafeShakeApp());
  unawaited(_bootstrapServices());
}

Future<void> _bootstrapServices() async {
  // Never block the first frame on Firebase. On low-end devices this can be slow.
  try {
    await FirebaseService().initialize(timeout: const Duration(seconds: 30));
  } catch (_) {}
  try {
    await Future<void>.delayed(const Duration(seconds: 6));
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
