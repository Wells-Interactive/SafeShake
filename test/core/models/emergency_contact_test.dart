import 'package:flutter_test/flutter_test.dart';
import 'package:safeshake/core/models/emergency_contact.dart';

void main() {
  group('EmergencyContact', () {
    test('creates contact with required fields', () {
      const contact = EmergencyContact(
        id: '1',
        name: 'John Doe',
        phoneNumber: '+1234567890',
      );
      expect(contact.id, '1');
      expect(contact.name, 'John Doe');
      expect(contact.phoneNumber, '+1234567890');
      expect(contact.email, '');
      expect(contact.enabled, true);
    });

    test('copyWith updates specified fields', () {
      const contact =
          EmergencyContact(id: '1', name: 'John', phoneNumber: '123');
      final updated = contact.copyWith(name: 'Jane', enabled: false);
      expect(updated.name, 'Jane');
      expect(updated.phoneNumber, '123');
      expect(updated.email, '');
      expect(updated.enabled, false);
      expect(updated.id, '1');
    });

    test('toMap serializes correctly', () {
      const contact = EmergencyContact(
        id: '1',
        name: 'John',
        phoneNumber: '123',
        email: 'john@example.com',
        enabled: false,
      );
      final map = contact.toMap();
      expect(map['name'], 'John');
      expect(map['phoneNumber'], '123');
      expect(map['email'], 'john@example.com');
      expect(map['enabled'], false);
    });

    test('fromMap deserializes correctly', () {
      final contact = EmergencyContact.fromMap('1', {
        'name': 'John',
        'phoneNumber': '123',
        'email': 'john@example.com',
        'enabled': false,
      });
      expect(contact.id, '1');
      expect(contact.name, 'John');
      expect(contact.phoneNumber, '123');
      expect(contact.email, 'john@example.com');
      expect(contact.enabled, false);
    });

    test('fromMap handles missing fields with defaults', () {
      final contact = EmergencyContact.fromMap('1', {});
      expect(contact.id, '1');
      expect(contact.name, '');
      expect(contact.phoneNumber, '');
      expect(contact.email, '');
      expect(contact.enabled, true);
    });
  });
}
