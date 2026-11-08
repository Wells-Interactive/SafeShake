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

    test('builds SMS composer links with the message body', () {
      const contact = EmergencyContact(
        id: '1',
        name: 'Test',
        phoneNumber: '+1234567890',
      );

      final uri = AlertService.smsComposerUri(contact, 'Please help.');

      expect(uri.scheme, 'sms');
      expect(uri.path, '+1234567890');
      expect(uri.queryParameters['body'], 'Please help.');
    });

    test('builds email composer links for fallback', () {
      const contact = EmergencyContact(
        id: '1',
        name: 'Test',
        phoneNumber: '+1234567890',
        email: 'test@example.com',
      );

      final uri = AlertService.emailComposerUri(contact, 'Please help.');

      expect(uri.scheme, 'mailto');
      expect(uri.path, 'test@example.com');
      expect(uri.queryParameters['subject'], 'SafeShake emergency alert');
      expect(uri.queryParameters['body'], 'Please help.');
    });

    test('opens email composer when SMS composer is unavailable', () async {
      final openedUris = <Uri>[];
      final service = AlertService(
        launchComposer: (uri) async {
          openedUris.add(uri);
          return uri.scheme == 'mailto';
        },
      );
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

      expect(openedUris.map((uri) => uri.scheme), ['sms', 'mailto']);
      expect(openedUris.last.path, 'test@example.com');
    });

    test('reports when SMS fails and contact has no email fallback', () async {
      final service = AlertService(launchComposer: (_) async => false);
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
        throwsA(isA<AlertDeliveryException>()),
      );
    });
  });
}
