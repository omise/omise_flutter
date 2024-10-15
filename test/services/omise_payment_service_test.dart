import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omise_flutter/src/pages/select_payment_method_page.dart';
import 'package:omise_flutter/omise_flutter.dart';

void main() {
  late OmisePayment omisePayment;

  setUp(() {
    omisePayment = OmisePayment(
      publicKey: 'test_public_key',
      enableDebug: true,
    );
  });

  test('OmisePayment instance is created successfully', () {
    // Verify that the OmisePayment instance is created
    expect(omisePayment, isNotNull);
    expect(omisePayment.omiseApiService, isNotNull);
  });

  testWidgets('selectPaymentMethod returns SelectPaymentMethodPage widget',
      (WidgetTester tester) async {
    // Create the widget returned by selectPaymentMethod
    final widget = omisePayment.selectPaymentMethod();

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
}
