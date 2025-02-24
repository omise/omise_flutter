import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/truemoney_wallet_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/omise_payment_result.dart';
import 'package:omise_flutter/src/pages/paymentMethods/truemoney_wallet_page.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/widgets/rounded_text_field.dart';

import '../mocks.dart';

class MockOmiseApiService extends Mock implements OmiseApiService {}

class MockTrueMoneyWalletController extends Mock
    implements TrueMoneyWalletController {}

void main() {
  late MockOmiseApiService mockOmiseApiService;
  late MockTrueMoneyWalletController mockController;
  const testPhoneNumber = '0812345678';
  const testAmount = 1000;
  const testCurrency = Currency.thb;
  final mockSource = Source(
      object: 'source',
      id: 'src_123',
      amount: testAmount,
      currency: testCurrency,
      type: PaymentMethodName.truemoney,
      livemode: false,
      chargeStatus: ChargeStatus.unknown,
      flow: 'flow',
      createdAt: DateTime.now());

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
    mockController = MockTrueMoneyWalletController();
    when(() => mockController.value)
        .thenReturn(TrueMoneyWalletPageState(sourceLoadingStatus: Status.idle));
  });
  setUpAll(() {
    registerFallbackValue(MockCreateSourceRequest());
  });
  Widget createTestWidget() {
    return MaterialApp(
      home: TrueMoneyWalletPage(
        amount: testAmount,
        currency: Currency.thb,
        omiseApiService: mockOmiseApiService,
        trueMoneyWalletController: mockController,
      ),
    );
  }

  testWidgets('Renders UI correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TrueMoneyWalletPage(
        amount: testAmount,
        currency: Currency.thb,
        omiseApiService: mockOmiseApiService,
      ),
    ));

    expect(find.textContaining('TrueMoney'), findsWidgets);
    expect(find.byType(RoundedTextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Enables button when phone number is entered',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TrueMoneyWalletPage(
        amount: testAmount,
        currency: Currency.thb,
        omiseApiService: mockOmiseApiService,
      ),
    ));
    await tester.enterText(find.byType(RoundedTextField), testPhoneNumber);
    await tester.pump();

    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isTrue);
  });

  testWidgets('Calls createSource when button is tapped',
      (WidgetTester tester) async {
    when(() => mockController.createSource()).thenAnswer((_) async {});
    when(() => mockController.value).thenReturn(TrueMoneyWalletPageState(
      sourceLoadingStatus: Status.idle,
      phoneNumber: testPhoneNumber,
    ));

    await tester.pumpWidget(createTestWidget());
    await tester.enterText(find.byType(RoundedTextField), '0812345678');
    await tester.pump();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(() => mockController.createSource()).called(1);
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
                      builder: (context) => TrueMoneyWalletPage(
                        omiseApiService: mockOmiseApiService,
                        amount: testAmount,
                        currency: testCurrency,
                      ),
                    ),
                  );
                  capturedResult =
                      result; // Capture the result from Navigator.pop
                },
                child: const Text('Open Truemoney wallet Page'),
              );
            },
          ),
        ),
      );

      // Simulate opening the credit card page
      await tester.tap(find.text('Open Truemoney wallet Page'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(RoundedTextField), '0812345678');
      await tester.pump();
      final nextButton = find.widgetWithText(ElevatedButton, 'Next');
      expect(tester.widget<ElevatedButton>(nextButton).enabled, isTrue);
      await tester.tap(nextButton);

      // Wait for the token creation process to complete and the page to pop
      await tester.pumpAndSettle();

      // Check if the result is captured correctly after the page is popped
      expect(capturedResult?.source?.id,
          equals(mockSource.id)); // Verify result from pop

      // Ensure the TrueMoneyWalletPage is no longer in the widget tree (i.e., the page was popped)
      expect(find.byType(TrueMoneyWalletPage), findsNothing);
    },
  );
}
