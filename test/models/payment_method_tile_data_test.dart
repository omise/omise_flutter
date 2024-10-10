import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/models/payment_method.dart';

void main() {
  group('PaymentMethodTileData', () {
    test('should initialize with correct values', () {
      // Create a test image and icon
      final testImage = Image.asset('assets/test.png');
      const testIcon = Icons.check;
      const paymentMethodName = PaymentMethodName.card;

      void testCallback() {}

      // Create an instance of PaymentMethodTileData
      final paymentMethodTileData = PaymentMethodTileData(
        name: paymentMethodName, // Example payment method
        leadingIcon: testImage,
        trailingIcon: testIcon,
        onTap: testCallback,
      );

      // Verify that the fields are correctly initialized
      expect(paymentMethodTileData.name, paymentMethodName);
      expect(paymentMethodTileData.leadingIcon, testImage);
      expect(paymentMethodTileData.trailingIcon, testIcon);
    });

    test('should trigger the onTap callback when called', () {
      // Create a test callback function
      bool callbackTriggered = false;
      void mockCallback() {
        callbackTriggered = true;
      }

      // Create an instance of PaymentMethodTileData with the mock callback
      final paymentMethodTileData = PaymentMethodTileData(
        name: PaymentMethodName.promptpay, // Another example payment method
        leadingIcon: Image.asset('assets/test.png'),
        trailingIcon: Icons.arrow_forward,
        onTap: mockCallback,
      );

      // Initially, the callback should not be triggered
      expect(callbackTriggered, isFalse);

      // Trigger the callback and verify that it works
      paymentMethodTileData.onTap();
      expect(callbackTriggered, isTrue);
    });
  });
}
