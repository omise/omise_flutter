import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart' as omise_dart;
import 'package:omise_flutter/src/controllers/installments_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/omise_payment_result.dart';
import 'package:omise_flutter/src/pages/paymentMethods/credit_card_page.dart';
import 'package:omise_flutter/src/pages/paymentMethods/installments/terms_page.dart';
import 'package:omise_flutter/src/translations/translations.dart';

import '../mocks.dart';

void main() {
  late MockOmiseApiService mockOmiseApiService;
  late InstallmentsController mockController;
  final MockBuildContext mockBuildContext = MockBuildContext();

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
    mockController = MockInstallmentsController();
  });

  setUpAll(() {
    registerFallbackValue(MockBuildContext());
    registerFallbackValue(MockCreateSourceRequest());
    Translations.testLocale = const Locale('en');
  });

  tearDownAll(() {
    Translations.testLocale = null;
  });

  const amount = 1000000;
  const currency = omise_dart.Currency.thb;
  const paymentMethod = omise_dart.PaymentMethodName.installmentScb;
  const paymentMethodWlb = omise_dart.PaymentMethodName.installmentWlbScb;
  final terms = [3, 6, 9];

  final mockCapability = MockCapability();
  final mockSource = omise_dart.Source(
    object: 'source',
    id: 'src_123',
    amount: amount,
    currency: currency,
    type: paymentMethod,
    livemode: false,
    chargeStatus: omise_dart.ChargeStatus.unknown,
    flow: 'redirect',
    createdAt: DateTime.now(),
  );

  group("TermsPage", () {
    testWidgets('displays list of installment terms',
        (WidgetTester tester) async {
      when(() => mockController.value).thenReturn(InstallmentsPageState(
        sourceLoadingStatus: Status.idle,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: TermsPage(
            terms: terms,
            omiseApiService: mockOmiseApiService,
            amount: amount,
            currency: currency,
            installmentPaymentMethod: paymentMethod,
            capability: mockCapability,
            installmentsPaymentMethodSelectorController: mockController,
          ),
        ),
      );

      expect(find.byType(ListTile), findsNWidgets(terms.length));
      for (var term in terms) {
        expect(find.text('$term months'), findsOneWidget);
      }
    });

    testWidgets(
      'After source creation, the result is returned to the integrator when an installment term is selected',
      (WidgetTester tester) async {
        OmisePaymentResult? capturedResult;

        when(() => mockOmiseApiService.createSource(any()))
            .thenAnswer((_) async => mockSource);
        when(() => mockCapability.zeroInterestInstallments).thenReturn(false);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TermsPage(
                          terms: terms,
                          omiseApiService: mockOmiseApiService,
                          amount: amount,
                          currency: currency,
                          installmentPaymentMethod: paymentMethod,
                          capability: mockCapability,
                        ),
                      ),
                    );
                    capturedResult = result;
                  },
                  child: const Text('Open Terms Page'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open Terms Page'));
        await tester.pumpAndSettle();

        final installmentOption = find.text('3 months');
        await tester.tap(installmentOption);
        await tester.pumpAndSettle();

        expect(capturedResult?.source?.id, equals(mockSource.id));
        expect(find.byType(TermsPage), findsNothing);
      },
    );
  });
  testWidgets(
    'When payment method is wlb, the credit card page opens',
    (WidgetTester tester) async {
      when(() => mockController.value).thenReturn(InstallmentsPageState(
        sourceLoadingStatus: Status.idle,
      ));
      when(() => mockCapability.zeroInterestInstallments).thenReturn(false);
      await tester.pumpWidget(
        MaterialApp(
          home: TermsPage(
            terms: terms,
            omiseApiService: mockOmiseApiService,
            amount: amount,
            currency: currency,
            installmentPaymentMethod: paymentMethodWlb,
            capability: mockCapability,
            installmentsPaymentMethodSelectorController:
                InstallmentsController(omiseApiService: mockOmiseApiService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final installmentsTile = find.widgetWithText(
        ListTile,
        '3 months',
      );
      expect(installmentsTile, findsOneWidget);
      await tester.tap(installmentsTile);
      await tester.pumpAndSettle();

      // Verify that the credit card page has opened
      expect(find.byType(CreditCardPage), findsOneWidget);
    },
  );
}
