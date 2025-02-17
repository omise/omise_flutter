import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart' as omise_dart;
import 'package:omise_flutter/omise_flutter.dart';
import 'package:omise_flutter/src/controllers/payment_methods_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/omise_payment_result.dart';
import 'package:omise_flutter/src/pages/paymentMethods/installments/installments_page.dart';
import 'package:omise_flutter/src/pages/paymentMethods/mobile_banking_page.dart';
import 'package:omise_flutter/src/pages/payment_methods_page.dart';
import 'package:omise_flutter/src/translations/translations.dart';

import '../mocks.dart';

void main() {
  late MockOmiseApiService mockOmiseApiService;
  late PaymentMethodsController mockController;
  final MockBuildContext mockBuildContext = MockBuildContext();

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
    mockController = MockPaymentMethodSelectorController();
  });

  setUpAll(() {
    registerFallbackValue(MockBuildContext());
    registerFallbackValue(MockCreateSourceRequest());
    registerFallbackValue(PaymentMethodName.card);
    Translations.testLocale = const Locale('en');
  });

  tearDownAll(() {
    Translations.testLocale = null;
  });

  // Define mock currency and bank objects as they are required in PaymentMethod
  final mockCurrencies = [omise_dart.Currency.thb];
  final mockBanks = [omise_dart.Bank.kbank];
  const amount = 1000000;
  const currency = omise_dart.Currency.thb;
  const paymentMethod = omise_dart.PaymentMethodName.promptpay;

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

  testWidgets('displays loading spinner when capability is loading',
      (WidgetTester tester) async {
    when(() => mockController.value).thenReturn(PaymentMethodsState(
        capabilityLoadingStatus: Status.loading,
        sourceLoadingStatus: Status.idle));

    when(() => mockController.loadCapabilities())
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(
      MaterialApp(
        home: PaymentMethodsPage(
          omiseApiService: mockOmiseApiService,
          paymentMethodSelectorController: mockController,
          amount: amount,
          currency: currency,
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays error message when capability status is error',
      (WidgetTester tester) async {
    const errorMessage = 'Something went wrong!';
    when(() => mockController.value).thenReturn(PaymentMethodsState(
        sourceLoadingStatus: Status.idle,
        capabilityLoadingStatus: Status.error,
        capabilityErrorMessage: errorMessage));

    when(() => mockController.loadCapabilities())
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(
      MaterialApp(
        home: PaymentMethodsPage(
          omiseApiService: mockOmiseApiService,
          paymentMethodSelectorController: mockController,
          amount: amount,
          currency: currency,
        ),
      ),
    );

    expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets(
      'displays list of payment methods when capability status is success',
      (WidgetTester tester) async {
    final paymentMethods = [
      omise_dart.PaymentMethod(
        object: 'payment_method',
        name: omise_dart.PaymentMethodName.card,
        currencies: mockCurrencies,
        banks: mockBanks,
        cardBrands: [
          omise_dart.CardBrand.visa,
          omise_dart.CardBrand.masterCard
        ],
      ),
      omise_dart.PaymentMethod(
        object: 'payment_method',
        name: omise_dart.PaymentMethodName.promptpay,
        currencies: mockCurrencies,
        banks: mockBanks,
        provider: 'provider_example',
      ),
      // This is how mobile banking is displayed as its a custom payment methods that sums all mobile banking payment methods together
      omise_dart.PaymentMethod(
        object: CustomPaymentMethod.mobileBanking.value,
        name: omise_dart.PaymentMethodName.unknown,
        currencies: mockCurrencies,
        banks: [],
        provider: 'provider_example',
      ),
    ];

    when(() => mockController.value).thenReturn(PaymentMethodsState(
        sourceLoadingStatus: Status.idle,
        capability: omise_dart.Capability(
          object: 'capability',
          location: '/capability',
          banks: [omise_dart.Bank.scb, omise_dart.Bank.bbl],
          limits: omise_dart.Limits(
            chargeAmount: omise_dart.Amount(max: 100000, min: 100),
            transferAmount: omise_dart.Amount(max: 50000, min: 500),
            installmentAmount: omise_dart.InstallmentAmount(min: 1000),
          ),
          paymentMethods: paymentMethods,
          tokenizationMethods: [omise_dart.TokenizationMethod.applepay],
          zeroInterestInstallments: false,
          country: 'TH',
        ),
        capabilityLoadingStatus: Status.success,
        viewablePaymentMethods: paymentMethods));
    when(() => mockController.getPaymentMethodParams(
            context: any(named: 'context'),
            locale: any(named: 'locale'),
            object: any(named: 'object'),
            paymentMethodName: any(named: 'paymentMethodName')))
        .thenReturn(PaymentMethodParams(isNextPage: false, function: () {}));

    when(() => mockController.loadCapabilities())
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(
      MaterialApp(
        home: PaymentMethodsPage(
          omiseApiService: mockOmiseApiService,
          paymentMethodSelectorController: mockController,
          amount: amount,
          currency: currency,
        ),
      ),
    );

    expect(find.byType(ListTile), findsNWidgets(paymentMethods.length));
    expect(
        find.text(
            omise_dart.PaymentMethodName.card.title(context: mockBuildContext)),
        findsOneWidget);
    expect(
        find.text(omise_dart.PaymentMethodName.promptpay
            .title(context: mockBuildContext)),
        findsOneWidget);
    expect(
        find.text(
            CustomPaymentMethod.mobileBanking.title(context: mockBuildContext)),
        findsOneWidget);
  });

  testWidgets('displays "No payment methods available" when the list is empty',
      (WidgetTester tester) async {
    when(() => mockController.value).thenReturn(PaymentMethodsState(
        capabilityLoadingStatus: Status.success,
        viewablePaymentMethods: [],
        sourceLoadingStatus: Status.idle));

    when(() => mockController.loadCapabilities())
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(
      MaterialApp(
        home: PaymentMethodsPage(
          omiseApiService: mockOmiseApiService,
          paymentMethodSelectorController: mockController,
          amount: amount,
          currency: currency,
        ),
      ),
    );

    expect(
        find.text('No payment methods available to display'), findsOneWidget);
  });

  testWidgets(
    'After prompt pay source creation, the result is returned to the integrator when the payment method is selected',
    (WidgetTester tester) async {
      OmisePaymentResult?
          capturedResult; // To capture the result from the navigator pop
      final controller = PaymentMethodsController(
        omiseApiService: mockOmiseApiService,
      );
      final mockCapability = omise_dart.Capability(
        object: 'capability',
        location: '/capability',
        banks: [omise_dart.Bank.scb, omise_dart.Bank.bbl],
        limits: omise_dart.Limits(
          chargeAmount: omise_dart.Amount(max: 100000, min: 100),
          transferAmount: omise_dart.Amount(max: 50000, min: 500),
          installmentAmount: omise_dart.InstallmentAmount(min: 1000),
        ),
        paymentMethods: [
          omise_dart.PaymentMethod(
            object: 'payment_method',
            name: omise_dart.PaymentMethodName.card,
            currencies: [omise_dart.Currency.thb],
            banks: [omise_dart.Bank.scb],
          ),
          omise_dart.PaymentMethod(
            object: 'payment_method',
            name: omise_dart.PaymentMethodName.promptpay,
            currencies: [omise_dart.Currency.thb],
            banks: [omise_dart.Bank.bbl],
          ),
          omise_dart.PaymentMethod(
            object: 'payment_method',
            name: omise_dart.PaymentMethodName.mobileBankingScb,
            currencies: [omise_dart.Currency.thb],
            banks: [],
          ),
        ],
        tokenizationMethods: [omise_dart.TokenizationMethod.applepay],
        zeroInterestInstallments: false,
        country: 'TH',
      );

      when(() => mockOmiseApiService.getCapabilities())
          .thenAnswer((_) async => mockCapability);

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
                      builder: (context) => PaymentMethodsPage(
                        omiseApiService: mockOmiseApiService,
                        paymentMethodSelectorController: controller,
                        amount: amount,
                        currency: currency,
                      ),
                    ),
                  );
                  capturedResult =
                      result; // Capture the result from Navigator.pop
                },
                child: const Text('Open Select Payment Method Page'),
              );
            },
          ),
        ),
      );

      // Simulate opening the credit card page
      await tester.tap(find.text('Open Select Payment Method Page'));
      await tester.pumpAndSettle(); // Wait for the credit card page to open

      final promptPayTile = find.widgetWithText(
          ListTile,
          omise_dart.PaymentMethodName.promptpay
              .title(context: mockBuildContext));
      expect(tester.widget<ListTile>(promptPayTile).enabled, isTrue);
      await tester.tap(promptPayTile);

      // Wait for the token creation process to complete and the page to pop
      await tester.pumpAndSettle();

      // Check if the result is captured correctly after the page is popped
      expect(capturedResult?.source?.id,
          equals(mockSource.id)); // Verify result from pop

      // Ensure the SelectPaymentMethodPage is no longer in the widget tree (i.e., the page was popped)
      expect(find.byType(PaymentMethodsPage), findsNothing);
    },
  );
  testWidgets(
    'When installments tile is clicked, the installments page opens',
    (WidgetTester tester) async {
      final controller = PaymentMethodsController(
        omiseApiService: mockOmiseApiService,
      );
      final mockCapability = omise_dart.Capability(
        object: 'capability',
        location: '/capability',
        banks: [omise_dart.Bank.scb, omise_dart.Bank.bbl],
        limits: omise_dart.Limits(
          chargeAmount: omise_dart.Amount(max: 100000, min: 100),
          transferAmount: omise_dart.Amount(max: 50000, min: 500),
          installmentAmount: omise_dart.InstallmentAmount(min: 1000),
        ),
        paymentMethods: [
          omise_dart.PaymentMethod(
            object: 'payment_method',
            name: omise_dart.PaymentMethodName.installmentScb,
            currencies: [omise_dart.Currency.thb],
            banks: [],
          ),
        ],
        tokenizationMethods: [omise_dart.TokenizationMethod.applepay],
        zeroInterestInstallments: false,
        country: 'TH',
      );

      when(() => mockOmiseApiService.getCapabilities())
          .thenAnswer((_) async => mockCapability);

      await tester.pumpWidget(
        MaterialApp(
          home: PaymentMethodsPage(
            omiseApiService: mockOmiseApiService,
            paymentMethodSelectorController: controller,
            amount: amount,
            currency: currency,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final installmentsTile = find.widgetWithText(
        ListTile,
        CustomPaymentMethod.installments.title(context: mockBuildContext),
      );
      expect(installmentsTile, findsOneWidget);
      await tester.tap(installmentsTile);
      await tester.pumpAndSettle();

      // Verify that the installments page has opened
      expect(find.byType(InstallmentsPage), findsOneWidget);
    },
  );
  testWidgets(
    'When mobile banking tile is clicked, the mobile banking page opens',
    (WidgetTester tester) async {
      final controller = PaymentMethodsController(
        omiseApiService: mockOmiseApiService,
      );
      final mockCapability = omise_dart.Capability(
        object: 'capability',
        location: '/capability',
        banks: [omise_dart.Bank.scb, omise_dart.Bank.bbl],
        limits: omise_dart.Limits(
          chargeAmount: omise_dart.Amount(max: 100000, min: 100),
          transferAmount: omise_dart.Amount(max: 50000, min: 500),
          installmentAmount: omise_dart.InstallmentAmount(min: 1000),
        ),
        paymentMethods: [
          omise_dart.PaymentMethod(
            object: 'payment_method',
            name: omise_dart.PaymentMethodName.mobileBankingScb,
            currencies: [omise_dart.Currency.thb],
            banks: [],
          ),
        ],
        tokenizationMethods: [omise_dart.TokenizationMethod.applepay],
        zeroInterestInstallments: false,
        country: 'TH',
      );

      when(() => mockOmiseApiService.getCapabilities())
          .thenAnswer((_) async => mockCapability);

      await tester.pumpWidget(
        MaterialApp(
          home: PaymentMethodsPage(
            omiseApiService: mockOmiseApiService,
            paymentMethodSelectorController: controller,
            amount: amount,
            currency: currency,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final installmentsTile = find.widgetWithText(
        ListTile,
        CustomPaymentMethod.mobileBanking.title(context: mockBuildContext),
      );
      expect(installmentsTile, findsOneWidget);
      await tester.tap(installmentsTile);
      await tester.pumpAndSettle();

      // Verify that the installments page has opened
      expect(find.byType(MobileBankingPage), findsOneWidget);
    },
  );
}
