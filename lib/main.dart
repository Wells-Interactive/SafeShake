import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'core/services/morning_reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SafeShakeApp());
  unawaited(_initializeMorningReminder());
}

Future<void> _initializeMorningReminder() async {
  try {
    await MorningReminderService().initializeAndSchedule();
  } on Exception catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'morning reminder initialization',
      ),
    );
  }
}
