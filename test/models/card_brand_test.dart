import 'package:flutter_test/flutter_test.dart';
import 'package:omise_flutter/src/models/card_brand.dart';

void main() {
  group('CardBrand enum tests', () {
    test('getActiveBrand recognizes valid brands correctly', () {
      // Amex
      expect(CardBrand.getActiveBrand('341234567890123'), CardBrand.amex);

      // Visa
      expect(CardBrand.getActiveBrand('4123456789012345'), CardBrand.visa);

      // Mastercard
      expect(
          CardBrand.getActiveBrand('5512345678901234'), CardBrand.mastercard);

      // Unknown
      expect(CardBrand.getActiveBrand('111111111'), isNull);
    });

    test('valid validates correctness and lengths', () {
      expect(CardBrand.visa.valid('4123456789012345'), isTrue);
      // Visa length must be exactly 16 based on our config
      expect(CardBrand.visa.valid('412345678901234'), isFalse);

      expect(CardBrand.amex.valid('341234567890123'), isTrue);
      expect(CardBrand.amex.valid('3412345678901234'), isFalse);
    });

    test('valid accepts formatted text with spaces', () {
      expect(CardBrand.visa.valid('4123 4567 8901 2345'), isTrue);
      expect(CardBrand.amex.valid('3412 345678 90123'), isTrue);
    });
  });
}
