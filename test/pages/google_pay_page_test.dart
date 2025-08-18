import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_flutter/omise_flutter.dart';
import 'package:omise_flutter/src/controllers/google_pay_controller.dart';
import 'package:omise_flutter/src/pages/paymentMethods/google_pay_page.dart';
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
  const googlePayMerchantId = "merchant_123";
  const pkey = "pkey_test";

  group("GooglePayPage Tests", () {
    testWidgets('Displays Google Pay button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooglePayPage(
            googlePayMerchantId: googlePayMerchantId,
            requestBillingAddress: true,
            requestPhoneNumber: false,
            omiseApiService: mockOmiseApiService,
            googlePayController: GooglePayController(
                omiseApiService: mockOmiseApiService, pkey: pkey),
            currency: currency,
            amount: amount,
            pkey: pkey,
            itemDescription: "Test Item",
          ),
        ),
      );

      expect(find.byType(GooglePayButton), findsOneWidget);
    });
    testWidgets('close icon is displayed when single page google pay is used',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooglePayPage(
            googlePayMerchantId: googlePayMerchantId,
            requestBillingAddress: true,
            requestPhoneNumber: false,
            omiseApiService: mockOmiseApiService,
            googlePayController: GooglePayController(
                omiseApiService: mockOmiseApiService, pkey: pkey),
            currency: currency,
            amount: amount,
            pkey: pkey,
            itemDescription: "Test Item",
            automaticallyImplyLeading: false,
          ),
        ),
      );

      // Find the IconButton that has an Icon with Icons.close
      final closeButton = find.widgetWithIcon(IconButton, Icons.close);

// Ensure the close button is displayed
      expect(closeButton, findsOneWidget);

// Perform a tap on the close button
      await tester.tap(closeButton);
      await tester.pumpAndSettle();
      // Ensure the CreditCardPage is no longer in the widget tree (i.e., the page was popped)
      expect(find.byType(GooglePayPage), findsNothing);
    });
    testWidgets(
        'close icon is displayed when single page google pay is used from native apps',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooglePayPage(
            googlePayMerchantId: googlePayMerchantId,
            requestBillingAddress: true,
            requestPhoneNumber: false,
            omiseApiService: mockOmiseApiService,
            googlePayController: GooglePayController(
                omiseApiService: mockOmiseApiService, pkey: pkey),
            currency: currency,
            amount: amount,
            pkey: pkey,
            itemDescription: "Test Item",
            automaticallyImplyLeading: false,
            nativeResultMethodName: 'openGooglePayResult',
          ),
        ),
      );

      // Find the IconButton that has an Icon with Icons.close
      final closeButton = find.widgetWithIcon(IconButton, Icons.close);

// Ensure the close button is displayed
      expect(closeButton, findsOneWidget);

// Perform a tap on the close button
      await tester.tap(closeButton);
      await tester.pumpAndSettle();
      // checking if the page is closed is not possible since the page will not be closed form the flutter side but the native apps will
      // close the flutter integration once they receive the result from the channels.
    });
  });
}
