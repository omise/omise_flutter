import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:omise_flutter/src/utils/card_number_formatter.dart';

void main() {
  group('CardNumberFormatter', () {
    final formatter = CardNumberFormatter();

    TextEditingValue format(String text) {
      return formatter.formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length)),
      );
    }

    test('formats a standard 16 digit card as 4-4-4-4', () {
      final val = format('4242424242424242');
      expect(val.text, '4242 4242 4242 4242');
    });

    test('strips non-numeric characters before formatting', () {
      final val = format('abc4242xyz4242_4242-4242&');
      expect(val.text, '4242 4242 4242 4242');
    });

    test('formats Amex differently (4-6-5)', () {
      // Amex starts with 34 or 37
      final val = format('341234567890123'); // 15 digits
      expect(val.text, '3412 345678 90123');
    });

    test('caps length properly based on brand limits', () {
      // Amex is 15 max
      final val = format('341234567890123999');
      // Should stop at 15 chars
      expect(val.text, '3412 345678 90123');
    });

    test('formats Diners Club as 4-6-4', () {
      // Diners starts with 30, 36
      final val = format('36123456789012'); // 14 digits
      expect(val.text, '3612 345678 9012');
    });

    test('caps standard generic / unknown card at 19 digits', () {
      final val = format('111122223333444455556666'); // More than 19
      expect(val.text, '1111 2222 3333 4444 555');
    });
  });
}
