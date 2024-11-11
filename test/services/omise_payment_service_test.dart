import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omise_flutter/src/pages/select_payment_method_page.dart';
import 'package:omise_flutter/src/pages/payment_authorization_page.dart';
import 'package:omise_flutter/omise_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_android/webview_flutter_android.dart';

void main() {
  late OmisePayment omisePayment;
  const amount = 1000;
  const currency = Currency.thb;

  setUp(() {
    omisePayment = OmisePayment(
      publicKey: 'test_public_key',
      enableDebug: true,
    );
    WebViewPlatform.instance = AndroidWebViewPlatform();
  });

  test('OmisePayment instance is created successfully', () {
    // Verify that the OmisePayment instance is created
    expect(omisePayment, isNotNull);
    expect(omisePayment.omiseApiService, isNotNull);
  });

  testWidgets('selectPaymentMethod returns SelectPaymentMethodPage widget',
      (WidgetTester tester) async {
    // Create the widget returned by selectPaymentMethod
    final widget =
        omisePayment.selectPaymentMethod(amount: amount, currency: currency);

    // Pump the widget
    await tester.pumpWidget(MaterialApp(home: widget));

    // Verify that the correct widget type is displayed
    expect(find.byType(SelectPaymentMethodPage), findsOneWidget);
  });

  testWidgets(
      'selectPaymentMethod passes selectedPaymentMethods to SelectPaymentMethodPage',
      (WidgetTester tester) async {
    // Define a list of selected payment methods
    final selectedPaymentMethods = [
      PaymentMethodName.card,
      PaymentMethodName.promptpay
    ];

    // Create the widget returned by selectPaymentMethod with the selected methods
    final widget = omisePayment.selectPaymentMethod(
      selectedPaymentMethods: selectedPaymentMethods,
      amount: amount,
      currency: currency,
    );

    // Pump the widget
    await tester.pumpWidget(MaterialApp(home: widget));

    // Verify that the correct widget is displayed
    final selectPaymentMethodPageFinder = find.byType(SelectPaymentMethodPage);
    expect(selectPaymentMethodPageFinder, findsOneWidget);

    // Verify that the selectedPaymentMethods parameter was passed correctly
    final selectPaymentMethodPageWidget =
        tester.widget<SelectPaymentMethodPage>(selectPaymentMethodPageFinder);
    expect(selectPaymentMethodPageWidget.selectedPaymentMethods,
        selectedPaymentMethods);
  });

  testWidgets('authorizePayment returns PaymentAuthorizationPage widget',
      (WidgetTester tester) async {
    final authorizeUri = Uri.parse("https://example.com/auth");
    final expectedReturnUrls = ['https://example.com/success'];

    // Create the widget returned by authorizePayment
    final widget = omisePayment.authorizePayment(
      authorizeUri: authorizeUri,
      expectedReturnUrls: expectedReturnUrls,
    );

    // Pump the widget
    await tester.pumpWidget(MaterialApp(home: widget));

    // Verify that the correct widget type is displayed
    expect(find.byType(PaymentAuthorizationPage), findsOneWidget);

    // Verify that the authorizeUri and expectedReturnUrls parameters were passed correctly
    final paymentAuthorizationPageFinder =
        find.byType(PaymentAuthorizationPage);
    final paymentAuthorizationPageWidget =
        tester.widget<PaymentAuthorizationPage>(paymentAuthorizationPageFinder);

    expect(paymentAuthorizationPageWidget.authorizeUri, authorizeUri);
    expect(
        paymentAuthorizationPageWidget.expectedReturnUrls, expectedReturnUrls);
  });
}
