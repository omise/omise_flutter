import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart' as omiseDart;
import 'package:omise_flutter/src/controllers/credit_card_payment_method_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/pages/paymentMethods/credit_card_payment_method_page.dart';
import 'package:omise_flutter/src/widgets/rounded_text_feild.dart';

import '../mocks.dart';

void main() {
  late MockOmiseApiService mockOmiseApiService;
  late CreditCardPaymentMethodController mockController;

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
    mockController = MockCreditCardPaymentMethodController();
  });

  // Define mock objects required for CreditCardPaymentMethodState
  final mockCreateTokenRequest = omiseDart.CreateTokenRequest(
    number: '4242424242424242',
    expirationMonth: "12",
    expirationYear: "25",
    securityCode: '123',
    name: "name",
  );
  final mockToken = omiseDart.Token(
      livemode: true,
      chargeStatus: "status",
      createdAt: "createdAt",
      used: false,
      object: 'token',
      id: 'tokn_test_123',
      card: omiseDart.Card(
          object: "object",
          id: "id",
          livemode: true,
          deleted: false,
          brand: "brand",
          fingerprint: "fingerprint",
          lastDigits: "lastDigits",
          name: "name",
          expirationMonth: 09,
          expirationYear: 25,
          securityCodeCheck: true,
          createdAt: "createdAt"));
  final mockTextFieldValidityStatuses = {
    'cardNumber': true,
    'expiryDate': true,
    'cvv': true,
    'name': true,
  };

  group("description", () {
    testWidgets(
        'displays loading spinner when capabilityLoadingStatus is loading',
        (WidgetTester tester) async {
      when(() => mockController.value).thenReturn(CreditCardPaymentMethodState(
        capabilityLoadingStatus: Status.loading,
        tokenLoadingStatus: Status.idle,
        createTokenRequest: mockCreateTokenRequest,
        textFieldValidityStatuses: mockTextFieldValidityStatuses,
      ));

      when(() => mockController.loadCapabilities())
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: CreditCardPaymentMethodPage(
            omiseApiService: mockOmiseApiService,
            creditCardPaymentMethodController: mockController,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message when capabilityLoadingStatus is error',
        (WidgetTester tester) async {
      const errorMessage = 'Something went wrong!';
      when(() => mockController.value).thenReturn(CreditCardPaymentMethodState(
        capabilityLoadingStatus: Status.error,
        tokenLoadingStatus: Status.idle,
        capabilityErrorMessage: errorMessage,
        createTokenRequest: mockCreateTokenRequest,
        textFieldValidityStatuses: mockTextFieldValidityStatuses,
      ));

      when(() => mockController.loadCapabilities())
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: CreditCardPaymentMethodPage(
            omiseApiService: mockOmiseApiService,
            creditCardPaymentMethodController: mockController,
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('displays form when capabilityLoadingStatus is success',
        (WidgetTester tester) async {
      when(() => mockController.value).thenReturn(CreditCardPaymentMethodState(
        capabilityLoadingStatus: Status.success,
        tokenLoadingStatus: Status.idle,
        createTokenRequest: mockCreateTokenRequest,
        textFieldValidityStatuses: mockTextFieldValidityStatuses,
      ));

      when(() => mockController.loadCapabilities())
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: CreditCardPaymentMethodPage(
            omiseApiService: mockOmiseApiService,
            creditCardPaymentMethodController: mockController,
          ),
        ),
      );

      expect(find.byType(TextField),
          findsWidgets); // Ensures form fields are shown
    });
    testWidgets('Pay button is disabled when page is opened',
        (WidgetTester tester) async {
      final newTokenRequest = mockCreateTokenRequest;
      newTokenRequest.number = '';
      when(() => mockController.value).thenReturn(CreditCardPaymentMethodState(
        capabilityLoadingStatus: Status.success,
        tokenLoadingStatus: Status.idle,
        createTokenRequest: newTokenRequest,
        textFieldValidityStatuses: {
          'cardNumber': false, // invalid
          'expiryDate': true,
          'cvv': true,
          'name': true
        },
      ));

      when(() => mockController.loadCapabilities())
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: CreditCardPaymentMethodPage(
            omiseApiService: mockOmiseApiService,
            creditCardPaymentMethodController: mockController,
          ),
        ),
      );

      final payButton = find.byType(ElevatedButton);
      expect(payButton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(payButton).enabled,
          isFalse); // Button should be disabled
    });
    testWidgets('Pay button remains disabled with invalid input',
        (WidgetTester tester) async {
      final newTokenRequest = mockCreateTokenRequest;
      newTokenRequest.number = '4242';
      when(() => mockController.value).thenReturn(CreditCardPaymentMethodState(
        capabilityLoadingStatus: Status.success,
        tokenLoadingStatus: Status.idle,
        createTokenRequest: newTokenRequest,
        textFieldValidityStatuses: {
          'cardNumber': false, // invalid
          'expiryDate': true,
          'cvv': true,
          'name': true,
        },
      ));

      when(() => mockController.loadCapabilities())
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: CreditCardPaymentMethodPage(
            omiseApiService: mockOmiseApiService,
            creditCardPaymentMethodController: mockController,
          ),
        ),
      );

      final payButton = find.byType(ElevatedButton);
      expect(payButton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(payButton).enabled, isFalse);
    });
    testWidgets('Pay button is enabled with valid input',
        (WidgetTester tester) async {
      when(() => mockController.value).thenReturn(CreditCardPaymentMethodState(
        capabilityLoadingStatus: Status.success,
        tokenLoadingStatus: Status.idle,
        createTokenRequest: mockCreateTokenRequest,
        textFieldValidityStatuses: {
          'cardNumber': true,
          'expiryDate': true,
          'cvv': true,
          'name': true,
        },
      ));

      when(() => mockController.loadCapabilities())
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: CreditCardPaymentMethodPage(
            omiseApiService: mockOmiseApiService,
            creditCardPaymentMethodController: mockController,
          ),
        ),
      );

      final payButton = find.byType(ElevatedButton);
      expect(payButton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(payButton).enabled,
          isTrue); // Button should be enabled
    });
    testWidgets('Pay button click disables fields and button',
        (WidgetTester tester) async {
      when(() => mockController.value).thenReturn(CreditCardPaymentMethodState(
        capabilityLoadingStatus: Status.success,
        tokenLoadingStatus: Status.loading,
        createTokenRequest: mockCreateTokenRequest,
        textFieldValidityStatuses: {
          'cardNumber': true,
          'expiryDate': true,
          'cvv': true,
          'name': true,
        },
      ));

      when(() => mockController.loadCapabilities())
          .thenAnswer((_) async => Future.value());
      when(() => mockController.createToken())
          .thenAnswer((_) async => mockToken);

      await tester.pumpWidget(
        MaterialApp(
          home: CreditCardPaymentMethodPage(
            omiseApiService: mockOmiseApiService,
            creditCardPaymentMethodController: mockController,
          ),
        ),
      );

      final payButton = find.byType(ElevatedButton);
      await tester.tap(payButton); // Simulate button press
      await tester.pump(); // Rebuild UI after state change

      // Check if fields and button are disabled after click
      final disabledFields = find
          .byType(TextField)
          .evaluate()
          .every((element) => (element.widget as TextField).enabled == false);
      expect(disabledFields, isTrue);

      expect(tester.widget<ElevatedButton>(payButton).enabled,
          isFalse); // Button should be disabled
    });
    testWidgets('Fields and button are re-enabled after token request finishes',
        (WidgetTester tester) async {
      when(() => mockController.value).thenReturn(CreditCardPaymentMethodState(
        capabilityLoadingStatus: Status.success,
        tokenLoadingStatus: Status.idle, // Finished loading
        createTokenRequest: mockCreateTokenRequest,
        textFieldValidityStatuses: {
          'cardNumber': true,
          'expiryDate': true,
          'cvv': true,
          'name': true,
        },
      ));

      when(() => mockController.loadCapabilities())
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: CreditCardPaymentMethodPage(
            omiseApiService: mockOmiseApiService,
            creditCardPaymentMethodController: mockController,
          ),
        ),
      );

      await tester.pump(); // Rebuild UI after state change

      // Fields and button should be enabled again
      final enabledFields = find
          .byType(TextField)
          .evaluate()
          .every((element) => (element.widget as TextField).enabled == true);
      expect(enabledFields, isTrue);

      final payButton = find.byType(ElevatedButton);
      expect(tester.widget<ElevatedButton>(payButton).enabled,
          isTrue); // Button should be enabled again
    });
  });
  testWidgets('allows typing into the text fields',
      (WidgetTester tester) async {
    when(() => mockController.value).thenReturn(CreditCardPaymentMethodState(
      capabilityLoadingStatus: Status.success,
      tokenLoadingStatus: Status.idle,
      createTokenRequest: mockCreateTokenRequest,
      textFieldValidityStatuses: {
        'cardNumber': true,
        'expiryDate': true,
        'cvv': true,
        'name': true,
      },
    ));

    when(() => mockController.loadCapabilities())
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(
      MaterialApp(
        home: CreditCardPaymentMethodPage(
          omiseApiService: mockOmiseApiService,
          creditCardPaymentMethodController: mockController,
        ),
      ),
    );

    // Find the TextFields
    final cardNumberField = find.byKey(const Key('cardNumber'));
    final expiryDateField = find.byKey(const Key('expiryDate'));
    final cvvField = find.byKey(const Key('cvv'));
    final nameField = find.byKey(const Key('name'));

    // Type into the text fields
    await tester.enterText(cardNumberField, '4242424242424242');
    await tester.enterText(expiryDateField, '12/25');
    await tester.enterText(cvvField, '123');
    await tester.enterText(nameField, 'John Doe');

    // Rebuild the widget after the state has changed
    await tester.pump();

    // Check that the fields contain the entered text
    expect(find.text('4242424242424242'), findsOneWidget);
    expect(find.text('12/25'), findsOneWidget);
    expect(find.text('123'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
  });

  testWidgets('should show address fields when shouldShowAddressFields is true',
      (WidgetTester tester) async {
    mockCreateTokenRequest.country = 'CA';
    when(() => mockController.value).thenReturn(CreditCardPaymentMethodState(
      capabilityLoadingStatus: Status.success,
      tokenLoadingStatus: Status.idle,
      capability: omiseDart.Capability(
        object: 'capability',
        location: '/capability',
        banks: [omiseDart.Bank.scb, omiseDart.Bank.bbl],
        limits: omiseDart.Limits(
          chargeAmount: omiseDart.Amount(max: 100000, min: 100),
          transferAmount: omiseDart.Amount(max: 50000, min: 500),
          installmentAmount: omiseDart.InstallmentAmount(min: 1000),
        ),
        paymentMethods: [
          omiseDart.PaymentMethod(
            object: 'payment_method',
            name: omiseDart.PaymentMethodName.card,
            currencies: [omiseDart.Currency.thb],
            banks: [omiseDart.Bank.scb],
          ),
          omiseDart.PaymentMethod(
            object: 'payment_method',
            name: omiseDart.PaymentMethodName.promptpay,
            currencies: [omiseDart.Currency.thb],
            banks: [omiseDart.Bank.bbl],
          ),
        ],
        tokenizationMethods: [omiseDart.TokenizationMethod.applepay],
        zeroInterestInstallments: false,
        country: 'CA',
      ),
      createTokenRequest: mockCreateTokenRequest,
      textFieldValidityStatuses: {
        'cardNumber': true,
        'expiryDate': true,
        'cvv': true,
        'name': true,
      },
    ));

    when(() => mockController.loadCapabilities())
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(
      MaterialApp(
        home: CreditCardPaymentMethodPage(
          omiseApiService: mockOmiseApiService,
          creditCardPaymentMethodController: mockController,
        ),
      ),
    );

    // Act
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Card Number'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('City'), findsOneWidget);
    expect(find.text('State'), findsOneWidget);
    expect(find.text('Postal code'), findsOneWidget);
  });

  testWidgets('should type into address fields and update controller',
      (WidgetTester tester) async {
    mockCreateTokenRequest.country = 'CA';
    when(() => mockController.value).thenReturn(CreditCardPaymentMethodState(
      capabilityLoadingStatus: Status.success,
      tokenLoadingStatus: Status.idle,
      capability: omiseDart.Capability(
        object: 'capability',
        location: '/capability',
        banks: [omiseDart.Bank.scb, omiseDart.Bank.bbl],
        limits: omiseDart.Limits(
          chargeAmount: omiseDart.Amount(max: 100000, min: 100),
          transferAmount: omiseDart.Amount(max: 50000, min: 500),
          installmentAmount: omiseDart.InstallmentAmount(min: 1000),
        ),
        paymentMethods: [
          omiseDart.PaymentMethod(
            object: 'payment_method',
            name: omiseDart.PaymentMethodName.card,
            currencies: [omiseDart.Currency.thb],
            banks: [omiseDart.Bank.scb],
          ),
          omiseDart.PaymentMethod(
            object: 'payment_method',
            name: omiseDart.PaymentMethodName.promptpay,
            currencies: [omiseDart.Currency.thb],
            banks: [omiseDart.Bank.bbl],
          ),
        ],
        tokenizationMethods: [omiseDart.TokenizationMethod.applepay],
        zeroInterestInstallments: false,
        country: 'CA',
      ),
      createTokenRequest: mockCreateTokenRequest,
      textFieldValidityStatuses: {
        'cardNumber': true,
        'expiryDate': true,
        'cvv': true,
        'name': true,
      },
    ));

    when(() => mockController.loadCapabilities())
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(
      MaterialApp(
        home: CreditCardPaymentMethodPage(
          omiseApiService: mockOmiseApiService,
          creditCardPaymentMethodController: mockController,
        ),
      ),
    );

    // Act
    await tester.enterText(find.byType(RoundedTextField).at(4), '123 Main St');
    await tester.enterText(find.byType(RoundedTextField).at(5), 'Metropolis');
    await tester.enterText(find.byType(RoundedTextField).at(6), 'NY');
    await tester.enterText(find.byType(RoundedTextField).at(7), '54321');

    // Force a rebuild to process the changes
    await tester.pumpAndSettle();

    expect(mockController.value.createTokenRequest.street1, "123 Main St");
    expect(mockController.value.createTokenRequest.city, "Metropolis");
    expect(mockController.value.createTokenRequest.state, "NY");
    expect(mockController.value.createTokenRequest.postalCode, "54321");
  });
}
