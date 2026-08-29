import 'package:flutter_test/flutter_test.dart';
import 'package:safeshake/core/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('creates with default values', () {
      final settings = const AppSettings(userId: 'uid123');
      expect(settings.userId, 'uid123');
      expect(settings.alertMode, AlertMode.immediate);
      expect(settings.shakeSensitivity, ShakeSensitivity.medium);
      expect(settings.countdownSeconds, 10);
      expect(settings.locationSharingEnabled, true);
      expect(settings.emergencyMessage, contains('EMERGENCY ALERT'));
      expect(settings.protectionActive, true);
      expect(settings.hasCompletedOnboarding, false);
    });

    test('copyWith updates specified fields', () {
      final settings = const AppSettings(userId: 'uid');
      final updated = settings.copyWith(alertMode: AlertMode.countdown, countdownSeconds: 15);
      expect(updated.alertMode, AlertMode.countdown);
      expect(updated.countdownSeconds, 15);
      expect(updated.userId, 'uid');
    });

    test('toMap and fromMap roundtrip', () {
      final settings = AppSettings(
        userId: 'uid',
        alertMode: AlertMode.countdown,
        shakeSensitivity: ShakeSensitivity.high,
        countdownSeconds: 20,
        locationSharingEnabled: false,
        emergencyMessage: 'Custom message',
        protectionActive: false,
        hasCompletedOnboarding: true,
      );
      final map = settings.toMap();
      final restored = AppSettings.fromMap('uid', map);
      expect(restored.userId, 'uid');
      expect(restored.alertMode, AlertMode.countdown);
      expect(restored.shakeSensitivity, ShakeSensitivity.high);
      expect(restored.countdownSeconds, 20);
      expect(restored.locationSharingEnabled, false);
      expect(restored.emergencyMessage, 'Custom message');
      expect(restored.protectionActive, false);
      expect(restored.hasCompletedOnboarding, true);
    });

    test('fromMap falls back to defaults for missing fields', () {
      final settings = AppSettings.fromMap('uid', {});
      expect(settings.alertMode, AlertMode.immediate);
      expect(settings.shakeSensitivity, ShakeSensitivity.medium);
      expect(settings.countdownSeconds, 10);
      expect(settings.locationSharingEnabled, true);
      expect(settings.protectionActive, true);
    });
  });
}
