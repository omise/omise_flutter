import 'package:flutter_test/flutter_test.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/utils/validation_utils.dart';

void main() {
  group('ValidationUtils - Card Number', () {
    test('Card number is required', () {
      final result = ValidationUtils.validateCardNumber(null);
      expect(result, 'Card number is required');
    });

    test('Empty card number returns error', () {
      final result = ValidationUtils.validateCardNumber('');
      expect(result, 'Card number is required');
    });

    test('Card number with non-digit characters returns error', () {
      final result = ValidationUtils.validateCardNumber('1234a567890');
      expect(result, 'Invalid card number');
    });

    test('Invalid Luhn check fails', () {
      final result = ValidationUtils.validateCardNumber(
          '1234567890123456'); // Invalid card
      expect(result, 'Invalid card number');
    });

    test('Valid card number passes Luhn check', () {
      final result =
          ValidationUtils.validateCardNumber('4242424242424242'); // Valid card
      expect(result, null);
    });

    test('Card number with spaces and dashes is sanitized and passes', () {
      final result = ValidationUtils.validateCardNumber(
          '4242 4242-4242 4242'); // Valid with spaces and dashes
      expect(result, null);
    });
  });

  group('ValidationUtils - Name', () {
    test('Name is required', () {
      final result = ValidationUtils.validateName(null, fieldName: 'Full Name');
      expect(result, 'Full Name is required');
    });

    test('Empty name returns error', () {
      final result = ValidationUtils.validateName('', fieldName: 'Full Name');
      expect(result, 'Full Name is required');
    });

    test('Valid name passes', () {
      final result = ValidationUtils.validateName('John Doe');
      expect(result, null);
    });
  });

  group('ValidationUtils - Expiry Date', () {
    test('Expiry date is required', () {
      final result = ValidationUtils.validateExpiryDate(null);
      expect(result, 'Expiry date is required');
    });

    test('Empty expiry date returns error', () {
      final result = ValidationUtils.validateExpiryDate('');
      expect(result, 'Expiry date is required');
    });

    test('Invalid expiry date format returns error', () {
      final result =
          ValidationUtils.validateExpiryDate('13/25'); // Invalid month
      expect(result, 'MM/YY format');
    });

    test('Valid expiry date passes', () {
      final result = ValidationUtils.validateExpiryDate('12/25'); // Valid MM/YY
      expect(result, null);
    });
  });

  group('ValidationUtils - CVV', () {
    test('CVV is required', () {
      final result = ValidationUtils.validateCVV(null);
      expect(result, 'CVV is required');
    });

    test('Empty CVV returns error', () {
      final result = ValidationUtils.validateCVV('');
      expect(result, 'CVV is required');
    });

    test('CVV with non-digit characters returns error', () {
      final result = ValidationUtils.validateCVV('12a');
      expect(result, 'Only digits are allowed');
    });

    test('Invalid CVV length returns error', () {
      final result = ValidationUtils.validateCVV('12'); // Too short
      expect(result, 'CVV must be 3 or 4 digits');
    });

    test('Valid 3-digit CVV passes', () {
      final result = ValidationUtils.validateCVV('123'); // Valid 3-digit CVV
      expect(result, null);
    });

    test('Valid 4-digit CVV (AMEX) passes', () {
      final result =
          ValidationUtils.validateCVV('1234'); // Valid 4-digit CVV (AMEX)
      expect(result, null);
    });
  });

  group('ValidationUtils - validateInput', () {
    test('Validates card number correctly', () {
      final result = ValidationUtils.validateInput(
          ValidationType.cardNumber, '4242424242424242');
      expect(result, null); // Valid card number
    });

    test('Validates name correctly', () {
      final result =
          ValidationUtils.validateInput(ValidationType.name, 'John Doe');
      expect(result, null); // Valid name
    });

    test('Validates expiry date correctly', () {
      final result =
          ValidationUtils.validateInput(ValidationType.expiryDate, '12/25');
      expect(result, null); // Valid expiry date
    });

    test('Validates CVV correctly', () {
      final result = ValidationUtils.validateInput(ValidationType.cvv, '123');
      expect(result, null); // Valid CVV
    });
  });
}
