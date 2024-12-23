import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart' as omise_dart;
import 'package:omise_flutter/src/controllers/mobile_banking_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/omise_payment_result.dart';
import 'package:omise_flutter/src/pages/paymentMethods/mobile_banking_page.dart';
import 'package:omise_flutter/src/translations/translations.dart';

import '../mocks.dart';

void main() {
  late MockOmiseApiService mockOmiseApiService;
  late MobileBankingController mockController;
  final MockBuildContext mockBuildContext = MockBuildContext();

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
    mockController = MockMobileBankingPaymentMethodSelectorController();
  });

  setUpAll(() {
    registerFallbackValue(MockBuildContext());
    registerFallbackValue(MockCreateSourceRequest());
    Translations.testLocale = const Locale('en');
  });
  tearDownAll(() {
    Translations.testLocale = null;
  });

  // Define mock currency and bank objects as they are required in PaymentMethod
  final mockCurrencies = [omise_dart.Currency.thb];
  const amount = 1000;
  const currency = omise_dart.Currency.thb;
  const paymentMethod = omise_dart.PaymentMethodName.mobileBankingScb;

  final mockSource = omise_dart.Source(
      object: 'source',
      id: 'src_123',
      amount: amount,
      currency: currency,
      type: paymentMethod,
      livemode: false,
      chargeStatus: omise_dart.ChargeStatus.unknown,
      flow: 'flow',
      createdAt: DateTime.now());
  final mobileBankingPaymentMethods = [
    omise_dart.PaymentMethod(
      object: 'payment_method',
      name: omise_dart.PaymentMethodName.mobileBankingBay,
      currencies: mockCurrencies,
      banks: [],
    ),
    omise_dart.PaymentMethod(
      object: 'payment_method',
      name: omise_dart.PaymentMethodName.mobileBankingBbl,
      currencies: mockCurrencies,
      banks: [],
    ),
    omise_dart.PaymentMethod(
      object: 'payment_method',
      name: omise_dart.PaymentMethodName.mobileBankingKbank,
      currencies: mockCurrencies,
      banks: [],
    ),
    omise_dart.PaymentMethod(
      object: 'payment_method',
      name: omise_dart.PaymentMethodName.mobileBankingKtb,
      currencies: mockCurrencies,
      banks: [],
    ),
    omise_dart.PaymentMethod(
      object: 'payment_method',
      name: omise_dart.PaymentMethodName.mobileBankingScb,
      currencies: mockCurrencies,
      banks: [],
    ),
  ];

  group("SelectMobileBankingPaymentMethodPage", () {
    testWidgets('displays list of mobile banking payment methods',
        (WidgetTester tester) async {
      when(() => mockController.value).thenReturn(MobileBankingPageState(
        sourceLoadingStatus: Status.idle,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: MobileBankingPage(
            omiseApiService: mockOmiseApiService,
            amount: amount,
            currency: currency,
            mobileBankingPaymentMethods: mobileBankingPaymentMethods,
            mobileBankingPaymentMethodSelectorController: mockController,
          ),
        ),
      );

      expect(find.byType(ListTile),
          findsNWidgets(mobileBankingPaymentMethods.length));
      for (var method in mobileBankingPaymentMethods) {
        expect(find.text(method.name.title(context: mockBuildContext)),
            findsOneWidget);
      }
    });

    testWidgets(
      'After source creation, the result is returned to the integrator when the payment method is selected',
      (WidgetTester tester) async {
        OmisePaymentResult?
            capturedResult; // To capture the result from the navigator pop

        when(() => mockOmiseApiService.createSource(any()))
            .thenAnswer((_) async => mockSource);

        // Wrap the test in a Navigator to capture the result from the pop
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MobileBankingPage(
                          omiseApiService: mockOmiseApiService,
                          amount: amount,
                          currency: currency,
                          mobileBankingPaymentMethods:
                              mobileBankingPaymentMethods,
                        ),
                      ),
                    );
                    capturedResult =
                        result; // Capture the result from Navigator.pop
                  },
                  child: const Text('Open Mobile Banking Page'),
                );
              },
            ),
          ),
        );

        // Simulate opening the credit card page
        await tester.tap(find.text('Open Mobile Banking Page'));
        await tester.pumpAndSettle(); // Wait for the credit card page to open

        final mobileBankingScbTitle = find.widgetWithText(
            ListTile,
            omise_dart.PaymentMethodName.mobileBankingScb
                .title(context: mockBuildContext));
        expect(tester.widget<ListTile>(mobileBankingScbTitle).enabled, isTrue);
        await tester.tap(mobileBankingScbTitle);

        // Wait for the token creation process to complete and the page to pop
        await tester.pumpAndSettle();

        // Check if the result is captured correctly after the page is popped
        expect(capturedResult?.source?.id,
            equals(mockSource.id)); // Verify result from pop

        // Ensure the SelectMobileBankingPaymentMethodPage is no longer in the widget tree (i.e., the page was popped)
        expect(find.byType(MobileBankingPage), findsNothing);
      },
    );
  });
}
