import 'package:flutter_test/flutter_test.dart';
import 'package:safeshake/core/services/alert_service.dart';
import 'package:safeshake/core/models/app_settings.dart';
import 'package:safeshake/core/models/emergency_contact.dart';

void main() {
  group('AlertService', () {
    test('triggerAlert does nothing with empty contacts', () async {
      final service = AlertService();
      const settings = AppSettings(userId: 'uid');
      await service
          .triggerAlert(testMode: true, settings: settings, contacts: []);
      expect(service.isAlerting, false);
    });

    test('triggerAlert guards concurrent activation', () async {
      final service = AlertService();
      const settings = AppSettings(
          userId: 'uid', alertMode: AlertMode.countdown, countdownSeconds: 1);
      final contacts = [
        const EmergencyContact(id: '1', name: 'Test', phoneNumber: '123')
      ];
      final future1 = service.triggerAlert(
          testMode: true, settings: settings, contacts: contacts);
      final future2 = service.triggerAlert(
          testMode: true, settings: settings, contacts: contacts);
      await future1;
      await future2;
      expect(service.isAlerting, false);
    });

    test('cancelAlert stops countdown', () async {
      final service = AlertService();
      const settings = AppSettings(
          userId: 'uid', alertMode: AlertMode.countdown, countdownSeconds: 5);
      final contacts = [
        const EmergencyContact(id: '1', name: 'Test', phoneNumber: '123')
      ];
      await service.triggerAlert(
          testMode: true, settings: settings, contacts: contacts);
      await service.cancelAlert();
      expect(service.isAlerting, false);
      expect(service.remainingSeconds, null);
    });

    test('immediate mode executes immediately', () async {
      final service = AlertService();
      const settings =
          AppSettings(userId: 'uid', alertMode: AlertMode.immediate);
      final contacts = [
        const EmergencyContact(id: '1', name: 'Test', phoneNumber: '123')
      ];
      await service.triggerAlert(
          testMode: true, settings: settings, contacts: contacts);
      expect(service.isAlerting, false);
    });

    test('composes the emergency message with current coordinates', () {
      const settings = AppSettings(userId: 'uid');
      const locationLink = 'https://maps.google.com/?q=51.5072,-0.1276';

      final message = AlertService.composeEmergencyMessage(
        settings: settings,
        locationLink: locationLink,
      );

      expect(message, contains('51.5072,-0.1276'));
      expect(message, contains(locationLink));
      expect(message, isNot(contains('[LOCATION LINK]')));
    });

    test('adds location when a custom emergency message has no location token',
        () {
      const settings = AppSettings(
        userId: 'uid',
        emergencyMessage: 'Please help me.',
      );

      final message = AlertService.composeEmergencyMessage(
        settings: settings,
        locationLink: 'https://maps.google.com/?q=51.5072,-0.1276',
      );

      expect(message,
          'Please help me.\n\nMy location: https://maps.google.com/?q=51.5072,-0.1276');
    });

    test('sends email automatically without opening a composer', () async {
      final sentMessages = <String>[];
      final service = AlertService(sendEmail: (message) async {
        sentMessages.add(message);
      });
      const settings = AppSettings(
        userId: 'uid',
        locationSharingEnabled: false,
      );
      const contact = EmergencyContact(
        id: '1',
        name: 'Test',
        phoneNumber: '+1234567890',
        email: 'test@example.com',
      );

      await service.triggerAlert(
        testMode: false,
        settings: settings,
        contacts: const [contact],
      );

      expect(
        sentMessages,
        [AlertService.composeEmergencyMessage(settings: settings)],
      );
    });

    test('reports when no enabled contact has an email address', () async {
      var sendAttempted = false;
      final service = AlertService(sendEmail: (_) async {
        sendAttempted = true;
      });
      const settings = AppSettings(
        userId: 'uid',
        locationSharingEnabled: false,
      );
      const contact = EmergencyContact(
        id: '1',
        name: 'Test',
        phoneNumber: '+1234567890',
      );

      await expectLater(
        service.triggerAlert(
          testMode: false,
          settings: settings,
          contacts: const [contact],
        ),
        throwsA(
          isA<AlertDeliveryException>().having(
            (error) => error.message,
            'message',
            contains('No enabled emergency contact'),
          ),
        ),
      );
      expect(sendAttempted, isFalse);
    });

    test('test mode never sends email', () async {
      var sendAttempted = false;
      final service = AlertService(sendEmail: (_) async {
        sendAttempted = true;
      });
      const settings = AppSettings(userId: 'uid');
      const contact = EmergencyContact(
        id: '1',
        name: 'Test',
        phoneNumber: '+1234567890',
        email: 'test@example.com',
      );

      await service.triggerAlert(
        testMode: true,
        settings: settings,
        contacts: const [contact],
      );

      expect(sendAttempted, isFalse);
    });
  });
}
