import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MorningReminderService {
  static const _reminderId = 101;
  static const _channelId = 'morning_reminder';
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeAndSchedule() async {
    tz.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));

    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    final permission = await Permission.notification.request();
    if (!permission.isGranted) return;

    final now = tz.TZDateTime.now(tz.local);
    var reminderTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      8,
    );
    if (!reminderTime.isAfter(now)) {
      reminderTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        8,
      );
    }

    await _notifications.zonedSchedule(
      id: _reminderId,
      title: 'SafeShake morning check-in',
      body: 'Open SafeShake this morning to keep your protection ready.',
      scheduledDate: reminderTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Morning reminder',
          channelDescription: 'Daily reminder to open SafeShake',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
