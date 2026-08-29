import 'package:flutter_test/flutter_test.dart';
import 'package:safeshake/core/services/alert_service.dart';
import 'package:safeshake/core/models/app_settings.dart';
import 'package:safeshake/core/models/emergency_contact.dart';

void main() {
  group('AlertService', () {
    test('triggerAlert does nothing with empty contacts', () async {
      final service = AlertService();
      final settings = const AppSettings(userId: 'uid');
      await service.triggerAlert(testMode: true, settings: settings, contacts: []);
      expect(service.isAlerting, false);
    });

    test('triggerAlert guards concurrent activation', () async {
      final service = AlertService();
      final settings = const AppSettings(userId: 'uid', alertMode: AlertMode.countdown, countdownSeconds: 1);
      final contacts = [const EmergencyContact(id: '1', name: 'Test', phoneNumber: '123')];
      final future1 = service.triggerAlert(testMode: true, settings: settings, contacts: contacts);
      final future2 = service.triggerAlert(testMode: true, settings: settings, contacts: contacts);
      await future1;
      await future2;
      expect(service.isAlerting, false);
    });

    test('cancelAlert stops countdown', () async {
      final service = AlertService();
      final settings = const AppSettings(userId: 'uid', alertMode: AlertMode.countdown, countdownSeconds: 5);
      final contacts = [const EmergencyContact(id: '1', name: 'Test', phoneNumber: '123')];
      await service.triggerAlert(testMode: true, settings: settings, contacts: contacts);
      await service.cancelAlert();
      expect(service.isAlerting, false);
      expect(service.remainingSeconds, null);
    });

    test('immediate mode executes immediately', () async {
      final service = AlertService();
      final settings = const AppSettings(userId: 'uid', alertMode: AlertMode.immediate);
      final contacts = [const EmergencyContact(id: '1', name: 'Test', phoneNumber: '123')];
      await service.triggerAlert(testMode: true, settings: settings, contacts: contacts);
      expect(service.isAlerting, false);
    });
  });
}
