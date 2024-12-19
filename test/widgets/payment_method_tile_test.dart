import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/payment_method.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:omise_flutter/src/widgets/payment_method_tile.dart';

import '../mocks.dart';

void main() {
  final MockBuildContext mockBuildContext = MockBuildContext();
  setUpAll(() {
    Translations.testLocale = const Locale('en');
  });
  tearDownAll(() {
    Translations.testLocale = null;
  });
  group('paymentMethodTile Widget Tests', () {
    testWidgets(
        'should display payment method name, leading icon, and trailing icon',
        (WidgetTester tester) async {
      // Arrange
      final testPaymentMethod = PaymentMethodTileData(
        name: PaymentMethodName.card,
        leadingIcon: const Icon(Icons.start),
        trailingIcon: Icons.arrow_forward,
        onTap: () {},
      );

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              paymentMethodTile(
                  paymentMethod: testPaymentMethod, context: mockBuildContext),
            ],
          ),
        ),
      ));

      // Assert
      expect(find.text(PaymentMethodName.card.title(context: mockBuildContext)),
          findsOneWidget); // Verify the name
      expect(
          find.byIcon(Icons.start), findsOneWidget); // Verify the leading icon
      expect(find.byIcon(Icons.arrow_forward),
          findsOneWidget); // Verify the trailing icon
    });

    testWidgets('should trigger onTap callback when tapped',
        (WidgetTester tester) async {
      // Arrange
      final mockCallback = MockCallback();

      final testPaymentMethod = PaymentMethodTileData(
        name: PaymentMethodName.card,
        leadingIcon: const Icon(Icons.start),
        trailingIcon: Icons.arrow_forward,
        onTap: () {
          mockCallback.call();
        },
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              paymentMethodTile(
                  paymentMethod: testPaymentMethod, context: mockBuildContext),
            ],
          ),
        ),
      ));

      // Act
      await tester.tap(find.byType(ListTile));

      // Assert
      verify(() => mockCallback.call()).called(1);
    });
  });
}
