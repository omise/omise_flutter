import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omise_flutter/src/utils/expiry_date_formatter.dart'; // Adjust this import path as needed

void main() {
  group('ExpiryDateFormatter Tests', () {
    late ExpiryDateFormatter expiryDateFormatter;

    setUp(() {
      expiryDateFormatter = ExpiryDateFormatter();
    });

    test('Empty input remains unchanged', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '');

      final result = expiryDateFormatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '');
    });

    test('Valid input "1223" is formatted as "12/23"', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '1223');

      final result = expiryDateFormatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '12/23');
    });

    test('Input "123" is formatted as "12/3"', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '123');

      final result = expiryDateFormatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '12/3');
    });

    test('Excess input "122334" trims to "12/23"', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '122334');

      final result = expiryDateFormatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '12/23');
    });

    test('Deleting characters does not affect formatting', () {
      const oldValue = TextEditingValue(text: '12/23');
      const newValue = TextEditingValue(
        text: '12/2',
        selection: TextSelection.collapsed(offset: 4),
      );

      final result = expiryDateFormatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '12/2');
    });

    test('Partial input "1" remains as "1"', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '1');

      final result = expiryDateFormatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '1');
    });

    test('Partial input "12" is formatted as "12"', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '12');

      final result = expiryDateFormatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '12/');
    });

    test('Input with non-numeric characters is cleaned', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '12a23b');

      final result = expiryDateFormatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '12/23');
    });
  });
}
