import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<Map<Permission, PermissionStatus>> requestInitialPermissions() async {
    final permissions = <Permission>[
      Permission.locationWhenInUse,
      Permission.notification,
      Permission.sms,
    ];

    final statuses = <Permission, PermissionStatus>{};
    for (final permission in permissions) {
      final status = await permission.request();
      statuses[permission] = status;
    }
    return statuses;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<bool> isLocationPermissionGranted() async {
    return await Permission.locationWhenInUse.isGranted;
  }

  Future<bool> isNotificationPermissionGranted() async {
    return await Permission.notification.isGranted;
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  Future<bool> shouldShowLocationRationale() async {
    return await Permission.locationWhenInUse.shouldShowRequestRationale;
  }
}
