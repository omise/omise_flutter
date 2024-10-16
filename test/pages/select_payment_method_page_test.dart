import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/payment_method_selector_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/pages/select_payment_method_page.dart';

import '../mocks.dart';

void main() {
  late MockOmiseApiService mockOmiseApiService;
  late PaymentMethodSelectorController mockController;

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
    mockController = MockPaymentMethodSelectorController();
  });

  // Define mock currency and bank objects as they are required in PaymentMethod
  final mockCurrencies = [Currency.thb];
  final mockBanks = [Bank.kbank];

  testWidgets('displays loading spinner when status is loading',
      (WidgetTester tester) async {
    when(() => mockController.value)
        .thenReturn(PaymentMethodSelectorState(status: Status.loading));

    when(() => mockController.loadCapabilities())
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(
      MaterialApp(
        home: SelectPaymentMethodPage(
          omiseApiService: mockOmiseApiService,
          paymentMethodSelectorController: mockController,
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays error message when status is error',
      (WidgetTester tester) async {
    const errorMessage = 'Something went wrong!';
    when(() => mockController.value).thenReturn(PaymentMethodSelectorState(
        status: Status.error, errorMessage: errorMessage));

    when(() => mockController.loadCapabilities())
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(
      MaterialApp(
        home: SelectPaymentMethodPage(
          omiseApiService: mockOmiseApiService,
          paymentMethodSelectorController: mockController,
        ),
      ),
    );

    expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets('displays list of payment methods when status is success',
      (WidgetTester tester) async {
    final paymentMethods = [
      PaymentMethod(
        object: 'payment_method',
        name: PaymentMethodName.card,
        currencies: mockCurrencies,
        banks: mockBanks,
        cardBrands: [CardBrand.visa, CardBrand.masterCard],
      ),
      PaymentMethod(
        object: 'payment_method',
        name: PaymentMethodName.promptpay,
        currencies: mockCurrencies,
        banks: mockBanks,
        provider: 'provider_example',
      ),
    ];

    when(() => mockController.value).thenReturn(PaymentMethodSelectorState(
        status: Status.success, viewablePaymentMethods: paymentMethods));

    when(() => mockController.loadCapabilities())
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(
      MaterialApp(
        home: SelectPaymentMethodPage(
          omiseApiService: mockOmiseApiService,
          paymentMethodSelectorController: mockController,
        ),
      ),
    );

    expect(find.byType(ListTile), findsNWidgets(paymentMethods.length));
    expect(find.text('card'), findsOneWidget);
    expect(find.text('promptpay'), findsOneWidget);
  });

  testWidgets('displays "No payment methods available" when the list is empty',
      (WidgetTester tester) async {
    when(() => mockController.value).thenReturn(PaymentMethodSelectorState(
        status: Status.success, viewablePaymentMethods: []));

    when(() => mockController.loadCapabilities())
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(
      MaterialApp(
        home: SelectPaymentMethodPage(
          omiseApiService: mockOmiseApiService,
          paymentMethodSelectorController: mockController,
        ),
      ),
    );

    expect(
        find.text('No payment methods available to display'), findsOneWidget);
  });
}
