import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/app_settings.dart';

class ForegroundMonitorService {
  static const MethodChannel _channel = MethodChannel(
    'com.wellsint.brainyte.safeshake/foreground',
  );

  static Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<void> start(AppSettings settings) async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>(
      'startForegroundMonitoring',
      settings.toMap(),
    );
  }

  static Future<void> update(AppSettings settings) async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>(
      'updateForegroundMonitoring',
      settings.toMap(),
    );
  }

  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('stopForegroundMonitoring');
  }
}
