import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart' as omise_dart;
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/pages/paymentMethods/installments/installments_page.dart';
import 'package:omise_flutter/src/pages/paymentMethods/installments/terms_page.dart';
import 'package:omise_flutter/src/translations/translations.dart';

import '../mocks.dart';

void main() {
  late MockOmiseApiService mockOmiseApiService;
  final MockBuildContext mockBuildContext = MockBuildContext();

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
  });

  setUpAll(() {
    Translations.testLocale = const Locale('en');
  });

  tearDownAll(() {
    Translations.testLocale = null;
  });

  final mockCurrencies = [omise_dart.Currency.thb];
  const amount = 5000;
  const currency = omise_dart.Currency.thb;
  final mockCapability = MockCapability();

  final installmentPaymentMethods = [
    omise_dart.PaymentMethod(
      object: 'payment_method',
      name: omise_dart.PaymentMethodName.installmentBbl,
      currencies: mockCurrencies,
      banks: [],
      installmentTerms: [3, 6, 9],
    ),
    omise_dart.PaymentMethod(
      object: 'payment_method',
      name: omise_dart.PaymentMethodName.installmentKbank,
      currencies: mockCurrencies,
      banks: [],
      installmentTerms: [3, 6, 10],
    ),
  ];

  group("InstallmentsPage", () {
    testWidgets('displays list of installment payment methods',
        (WidgetTester tester) async {
      when(() => mockCapability.limits).thenReturn(omise_dart.Limits(
          chargeAmount: omise_dart.Amount(max: 0, min: 0),
          transferAmount: omise_dart.Amount(max: 0, min: 0),
          installmentAmount: omise_dart.InstallmentAmount(min: amount + 100)));
      await tester.pumpWidget(
        MaterialApp(
          home: InstallmentsPage(
            omiseApiService: mockOmiseApiService,
            amount: amount,
            currency: currency,
            capability: mockCapability,
            installmentPaymentMethods: installmentPaymentMethods,
          ),
        ),
      );
      expect(find.byType(ListTile),
          findsNWidgets(installmentPaymentMethods.length));
      for (var method in installmentPaymentMethods) {
        expect(find.text(method.name.title(context: mockBuildContext)),
            findsOneWidget);
      }
    });

    testWidgets('navigates to TermsPage on installment method selection',
        (WidgetTester tester) async {
      when(() => mockCapability.limits).thenReturn(omise_dart.Limits(
          chargeAmount: omise_dart.Amount(max: 0, min: 0),
          transferAmount: omise_dart.Amount(max: 0, min: 0),
          installmentAmount: omise_dart.InstallmentAmount(min: amount - 100)));
      await tester.pumpWidget(
        MaterialApp(
          home: InstallmentsPage(
            omiseApiService: mockOmiseApiService,
            amount: amount,
            currency: currency,
            capability: mockCapability,
            installmentPaymentMethods: installmentPaymentMethods,
          ),
        ),
      );

      final installmentBblTile = find.widgetWithText(
          ListTile,
          omise_dart.PaymentMethodName.installmentBbl
              .title(context: mockBuildContext));

      expect(tester.widget<ListTile>(installmentBblTile).enabled, isTrue);

      when(() => mockCapability.zeroInterestInstallments).thenReturn(false);
      await tester.tap(installmentBblTile);
      await tester.pumpAndSettle();

      expect(find.byType(TermsPage), findsOneWidget);
    });
    testWidgets('displays error when amount is below minInstallmentAmount',
        (WidgetTester tester) async {
      when(() => mockCapability.limits).thenReturn(omise_dart.Limits(
          chargeAmount: omise_dart.Amount(max: 0, min: 0),
          transferAmount: omise_dart.Amount(max: 0, min: 0),
          installmentAmount: omise_dart.InstallmentAmount(min: amount + 100)));
      await tester.pumpWidget(MaterialApp(
        home: InstallmentsPage(
          installmentPaymentMethods: installmentPaymentMethods,
          omiseApiService: mockOmiseApiService,
          amount: amount,
          currency: currency,
          capability: mockCapability,
        ),
      ));

      await tester.pump();

      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(
          find.textContaining(Translations.get(
              'installmentsAmountLowerThanMonthlyLimit',
              null,
              mockBuildContext)),
          findsOneWidget);
    });
  });
}
