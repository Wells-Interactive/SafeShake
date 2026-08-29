import 'package:flutter_test/flutter_test.dart';
import 'package:safeshake/core/models/emergency_contact.dart';

void main() {
  group('EmergencyContact', () {
    test('creates contact with required fields', () {
      final contact = const EmergencyContact(
        id: '1',
        name: 'John Doe',
        phoneNumber: '+1234567890',
      );
      expect(contact.id, '1');
      expect(contact.name, 'John Doe');
      expect(contact.phoneNumber, '+1234567890');
      expect(contact.enabled, true);
    });

    test('copyWith updates specified fields', () {
      final contact = const EmergencyContact(id: '1', name: 'John', phoneNumber: '123');
      final updated = contact.copyWith(name: 'Jane', enabled: false);
      expect(updated.name, 'Jane');
      expect(updated.phoneNumber, '123');
      expect(updated.enabled, false);
      expect(updated.id, '1');
    });

    test('toMap serializes correctly', () {
      final contact = const EmergencyContact(id: '1', name: 'John', phoneNumber: '123', enabled: false);
      final map = contact.toMap();
      expect(map['name'], 'John');
      expect(map['phoneNumber'], '123');
      expect(map['enabled'], false);
    });

    test('fromMap deserializes correctly', () {
      final contact = EmergencyContact.fromMap('1', {
        'name': 'John',
        'phoneNumber': '123',
        'enabled': false,
      });
      expect(contact.id, '1');
      expect(contact.name, 'John');
      expect(contact.phoneNumber, '123');
      expect(contact.enabled, false);
    });

    test('fromMap handles missing fields with defaults', () {
      final contact = EmergencyContact.fromMap('1', {});
      expect(contact.id, '1');
      expect(contact.name, '');
      expect(contact.phoneNumber, '');
      expect(contact.enabled, true);
    });
  });
}
