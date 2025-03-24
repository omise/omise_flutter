import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_flutter/omise_flutter.dart';
import 'package:omise_flutter/src/controllers/apple_pay_controller.dart';
import 'package:omise_flutter/src/pages/paymentMethods/apple_pay_page.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:pay/pay.dart';

import '../mocks.dart';

void main() {
  late MockOmiseApiService mockOmiseApiService;

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
  });

  setUpAll(() {
    registerFallbackValue(MockBuildContext());
    registerFallbackValue(MockCreateTokenRequest());
    Translations.testLocale = const Locale('en');
  });

  tearDownAll(() {
    Translations.testLocale = null;
  });

  const amount = 1000;
  const currency = Currency.thb;
  const applePayMerchantId = "merchant_123";
  const pkey = "pkey_test";

  group("ApplePayPage Tests", () {
    testWidgets('Displays Apple Pay button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ApplePayPage(
            country: 'TH',
            applePayMerchantId: applePayMerchantId,
            omiseApiService: mockOmiseApiService,
            applePayController: ApplePayController(
                omiseApiService: mockOmiseApiService, pkey: pkey),
            currency: currency,
            amount: amount,
            pkey: pkey,
            itemDescription: "Test Item",
          ),
        ),
      );

      expect(find.byType(ApplePayButton), findsOneWidget);
    });
  });
}
