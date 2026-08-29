import 'package:flutter_test/flutter_test.dart';
import 'package:safeshake/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('isValidEmail returns true for valid emails', () {
      expect(Validators.isValidEmail('user@example.com'), true);
      expect(Validators.isValidEmail('test.user+tag@domain.co'), true);
    });

    test('isValidEmail returns false for invalid emails', () {
      expect(Validators.isValidEmail('invalid'), false);
      expect(Validators.isValidEmail('missing@domain'), false);
      expect(Validators.isValidEmail('@nodomain.com'), false);
    });

    test('isValidPhone returns true for valid phones', () {
      expect(Validators.isValidPhone('+1234567890'), true);
      expect(Validators.isValidPhone('123-456-7890'), true);
    });

    test('isValidPhone returns false for invalid phones', () {
      expect(Validators.isValidPhone('abc'), false);
      expect(Validators.isValidPhone('123'), false);
    });

    test('isValidName returns true for valid names', () {
      expect(Validators.isValidName('John Doe'), true);
      expect(Validators.isValidName('A'), false);
      expect(Validators.isValidName(''), false);
    });

    test('isStrongPassword returns true for strong passwords', () {
      expect(Validators.isStrongPassword('Strong1!'), true);
      expect(Validators.isStrongPassword('weak'), false);
      expect(Validators.isStrongPassword('NoDigits!'), false);
    });

    test('validateEmail returns error for empty input', () {
      expect(Validators.validateEmail(null), 'Email is required');
      expect(Validators.validateEmail(''), 'Email is required');
      expect(Validators.validateEmail('bad'), 'Please enter a valid email');
    });

    test('validatePassword returns error for weak password', () {
      expect(Validators.validatePassword(null), 'Password is required');
      expect(Validators.validatePassword('short'), 'Password must be at least 8 characters');
    });

    test('validateName returns error for short name', () {
      expect(Validators.validateName(null), 'Name is required');
      expect(Validators.validateName('A'), 'Please enter a valid name');
    });

    test('validatePhone returns null for empty optional phone', () {
      expect(Validators.validatePhone(null), null);
      expect(Validators.validatePhone(''), null);
    });

    test('validatePhone returns error for invalid optional phone', () {
      expect(Validators.validatePhone('abc'), 'Please enter a valid phone number');
    });
  });
}
