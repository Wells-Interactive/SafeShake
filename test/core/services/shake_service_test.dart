import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:safeshake/core/models/app_settings.dart';
import 'package:safeshake/core/services/shake_service.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  group('ShakeService', () {
    test('detects motion above the medium sensitivity threshold', () async {
      final events = StreamController<UserAccelerometerEvent>(sync: true);
      var detected = 0;
      final service = ShakeService(
        onShakeDetected: () => detected++,
        userAccelerationStream: () => events.stream,
      );

      service.start();
      events.add(UserAccelerometerEvent(3, 0, 0, DateTime.now()));

      expect(detected, 1);
      service.stop();
      await events.close();
    });

    test('uses the configured sensitivity threshold', () {
      final low = ShakeService(
        sensitivity: ShakeSensitivity.low,
        onShakeDetected: () {},
      );
      final medium = ShakeService(
        sensitivity: ShakeSensitivity.medium,
        onShakeDetected: () {},
      );
      final high = ShakeService(
        sensitivity: ShakeSensitivity.high,
        onShakeDetected: () {},
      );

      expect(low.currentThreshold, greaterThan(medium.currentThreshold));
      expect(high.currentThreshold, lessThan(medium.currentThreshold));
    });
  });
}
