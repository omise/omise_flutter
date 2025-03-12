import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:omise_flutter/src/utils/validation_utils.dart';

import '../mocks.dart';

void main() {
  final MockBuildContext mockBuildContext = MockBuildContext();

  setUpAll(() {
    Translations.testLocale = const Locale('en');
  });
  tearDownAll(() {
    Translations.testLocale = null;
  });

  group('ValidationUtils', () {
    group('ValidationUtils - Card Number', () {
      test('Card number is required', () {
        final result = ValidationUtils.validateCardNumber(
            value: null, context: mockBuildContext);
        expect(result, 'Card number is required');
      });

      test('Empty card number returns error', () {
        final result = ValidationUtils.validateCardNumber(
            value: '', context: mockBuildContext);
        expect(result, 'Card number is required');
      });

      test('Card number with non-digit characters returns error', () {
        final result = ValidationUtils.validateCardNumber(
            value: '1234a567890', context: mockBuildContext);
        expect(result, 'Invalid card number');
      });

      test('Invalid Luhn check fails', () {
        final result = ValidationUtils.validateCardNumber(
            value: '1234567890123456',
            context: mockBuildContext); // Invalid card
        expect(result, 'Invalid card number');
      });

      test('Valid card number passes Luhn check', () {
        final result = ValidationUtils.validateCardNumber(
            value: '4242424242424242', context: mockBuildContext); // Valid card
        expect(result, null);
      });

      test('Card number with spaces and dashes is sanitized and passes', () {
        final result = ValidationUtils.validateCardNumber(
            value: '4242 4242-4242 4242',
            context: mockBuildContext); // Valid with spaces and dashes
        expect(result, null);
      });
    });

    group('ValidationUtils - Name', () {
      test('Name is required', () {
        final result = ValidationUtils.validateName(null,
            fieldName: 'Full Name',
            context: mockBuildContext,
            isOptional: false);
        expect(result, 'Full Name is required');
      });

      test('Empty name returns error', () {
        final result = ValidationUtils.validateName('',
            fieldName: 'Full Name',
            context: mockBuildContext,
            isOptional: false);
        expect(result, 'Full Name is required');
      });

      test('Valid name passes', () {
        final result = ValidationUtils.validateName('John Doe',
            context: mockBuildContext,
            fieldName: 'Full Name',
            isOptional: false);
        expect(result, null);
      });
    });

    group('ValidationUtils - Expiry Date', () {
      test('Expiry date is required', () {
        final result = ValidationUtils.validateExpiryDate(
            value: null, context: mockBuildContext);
        expect(result, 'Expiry date is required');
      });

      test('Empty expiry date returns error', () {
        final result = ValidationUtils.validateExpiryDate(
            value: '', context: mockBuildContext);
        expect(result, 'Expiry date is required');
      });

      test('Invalid expiry date format returns error', () {
        final result = ValidationUtils.validateExpiryDate(
            value: '13/25', context: mockBuildContext); // Invalid month
        expect(result, 'MM/YY format');
      });

      test('Valid expiry date passes', () {
        final result = ValidationUtils.validateExpiryDate(
            value: '12/25', context: mockBuildContext); // Valid MM/YY
        expect(result, null);
      });
    });

    group('ValidationUtils - CVV', () {
      test('CVV is required', () {
        final result =
            ValidationUtils.validateCVV(value: null, context: mockBuildContext);
        expect(result, 'CVV is required');
      });

      test('Empty CVV returns error', () {
        final result =
            ValidationUtils.validateCVV(value: '', context: mockBuildContext);
        expect(result, 'CVV is required');
      });

      test('CVV with non-digit characters returns error', () {
        final result = ValidationUtils.validateCVV(
            value: '12a', context: mockBuildContext);
        expect(result, 'Only digits are allowed');
      });

      test('Invalid CVV length returns error', () {
        final result = ValidationUtils.validateCVV(
            value: '12', context: mockBuildContext); // Too short
        expect(result, 'CVV must be 3 or 4 digits');
      });

      test('Valid 3-digit CVV passes', () {
        final result = ValidationUtils.validateCVV(
            value: '123', context: mockBuildContext); // Valid 3-digit CVV
        expect(result, null);
      });

      test('Valid 4-digit CVV (AMEX) passes', () {
        final result = ValidationUtils.validateCVV(
            value: '1234',
            context: mockBuildContext); // Valid 4-digit CVV (AMEX)
        expect(result, null);
      });
    });

    group('ValidationUtils - validateInput', () {
      test('Validates card number correctly', () {
        final result = ValidationUtils.validateInput(
            validationType: ValidationType.cardNumber,
            value: '4242424242424242',
            context: mockBuildContext);
        expect(result, null); // Valid card number
      });

      test('Validates name correctly', () {
        final result = ValidationUtils.validateInput(
            validationType: ValidationType.name,
            value: 'John Doe',
            context: mockBuildContext);
        expect(result, null); // Valid name
      });

      test('Validates expiry date correctly', () {
        final result = ValidationUtils.validateInput(
            validationType: ValidationType.expiryDate,
            value: '12/25',
            context: mockBuildContext);
        expect(result, null); // Valid expiry date
      });

      test('Validates CVV correctly', () {
        final result = ValidationUtils.validateInput(
            validationType: ValidationType.cvv,
            value: '123',
            context: mockBuildContext);
        expect(result, null); // Valid CVV
      });
      // Check thai language loading properly
      test('TH - Invalid CVV length returns error', () {
        Translations.testLocale = const Locale('th');
        final result = ValidationUtils.validateCVV(
            value: '12', context: mockBuildContext); // Too short
        expect(result, 'รหัส CVV ต้องมี 3 หรือ 4 หลัก');
      });
      // Check japanese language loading properly
      test('JA - Invalid CVV length returns error', () {
        Translations.testLocale = const Locale('ja');
        final result = ValidationUtils.validateCVV(
            value: '12', context: mockBuildContext); // Too short
        expect(result, 'CVVは3桁または4桁の数字です');
      });
    });
    group('ValidationUtils - Phone Number', () {
      test('Phone number is required', () {
        Translations.testLocale = const Locale('en');
        final result = ValidationUtils.validatePhoneNumber(
            phoneNumber: null, context: mockBuildContext);
        expect(result, 'Phone number is invalid');
      });

      test('Empty phone number returns error', () {
        final result = ValidationUtils.validatePhoneNumber(
            phoneNumber: '', context: mockBuildContext);
        expect(result, 'Phone number is invalid');
      });

      test('Phone number with non-digit characters returns error', () {
        final result = ValidationUtils.validatePhoneNumber(
            phoneNumber: '081-234-5678',
            context: mockBuildContext); // Invalid format
        expect(result, 'Phone number is invalid');
      });

      test('Phone number with letters returns error', () {
        final result = ValidationUtils.validatePhoneNumber(
            phoneNumber: '081abc5678',
            context: mockBuildContext); // Invalid characters
        expect(result, 'Phone number is invalid');
      });

      test('Valid phone number with + passes', () {
        final result = ValidationUtils.validatePhoneNumber(
            phoneNumber: '+15551234567', context: mockBuildContext);
        expect(result, null);
      });

      test('Valid phone number without + passes', () {
        final result = ValidationUtils.validatePhoneNumber(
            phoneNumber: '0812345678', context: mockBuildContext);
        expect(result, null);
      });
    });
  });
}
