import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart' as omise_dart;
import 'package:omise_flutter/omise_flutter.dart';
import 'package:omise_flutter/src/controllers/bank_selector_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/pages/paymentMethods/bank_selector_page.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import '../mocks.dart';

void main() {
  late MockOmiseApiService mockOmiseApiService;
  late MockBankSelectorController mockController;

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
    mockController = MockBankSelectorController();
  });

  setUpAll(() {
    registerFallbackValue(MockBuildContext());
    registerFallbackValue(MockCreateSourceRequest());
    registerFallbackValue(omise_dart.BankCode.affin);
    Translations.testLocale = const Locale('en');
  });

  final mockBanks = [
    omise_dart.Bank(
        name: "Affin", code: omise_dart.BankCode.affin, active: true),
    omise_dart.Bank(
        name: "Bank B", code: omise_dart.BankCode.affin, active: true),
  ];
  const amount = 1000;
  const currency = omise_dart.Currency.myr;
  const paymentMethod = omise_dart.PaymentMethodName.fpx;
  const testEmail = 'test@example.com';
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

  group("FpxBanksPage", () {
    testWidgets('displays list of FPX banks', (WidgetTester tester) async {
      when(() => mockController.value).thenReturn(FpxBankSelectorPageState(
        sourceLoadingStatus: Status.idle,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BankSelectorPage(
            omiseApiService: mockOmiseApiService,
            amount: 1000,
            currency: omise_dart.Currency.myr,
            banks: mockBanks,
            bankSelectorController: mockController,
            paymentMethod: paymentMethod,
          ),
        ),
      );

      expect(find.byType(ListTile), findsNWidgets(mockBanks.length));
      for (var bank in mockBanks) {
        expect(find.text(bank.name), findsOneWidget);
      }
    });

    testWidgets(
      'After source creation, the result is returned to the integrator when the bank is selected',
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
                        builder: (context) => BankSelectorPage(
                          omiseApiService: mockOmiseApiService,
                          amount: amount,
                          currency: currency,
                          banks: mockBanks,
                          email: testEmail,
                          paymentMethod: paymentMethod,
                        ),
                      ),
                    );
                    capturedResult =
                        result; // Capture the result from Navigator.pop
                  },
                  child: const Text('Open Fpx Banks Page'),
                );
              },
            ),
          ),
        );

        // Simulate opening the fpx banks page
        await tester.tap(find.text('Open Fpx Banks Page'));
        await tester.pumpAndSettle(); // Wait for the credit card page to open

        final affinBank = find.widgetWithText(ListTile, 'Affin');
        expect(tester.widget<ListTile>(affinBank).enabled, isTrue);
        await tester.tap(affinBank);

        // Wait for the token creation process to complete and the page to pop
        await tester.pumpAndSettle();

        // Check if the result is captured correctly after the page is popped
        expect(capturedResult?.source?.id,
            equals(mockSource.id)); // Verify result from pop

        // Ensure the SelectMobileBankingPaymentMethodPage is no longer in the widget tree (i.e., the page was popped)
        expect(find.byType(BankSelectorPage), findsNothing);
      },
    );
  });
}
