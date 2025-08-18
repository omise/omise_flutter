import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart'
    as omise_dart; // avoid name conflict in this file
import 'package:omise_flutter/omise_flutter.dart';
import 'package:omise_flutter/src/controllers/credit_card_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/pages/paymentMethods/credit_card_page.dart';
import 'package:omise_flutter/src/widgets/rounded_text_field.dart';

import '../mocks.dart';

void main() {
  late MockOmiseApiService mockOmiseApiService;
  late CreditCardController mockController;

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
    mockController = MockCreditCardPaymentMethodController();
  });
  setUpAll(() {
    // The token request is accessed from the internal value of the controller making it hard to mock without mocking previously tested entities
    // so when the CreateTokenRequest type needs to be used it will be automatically replaced with this mock
    registerFallbackValue(MockCreateTokenRequest());
  });

  // Define mock objects required for CreditCardPaymentMethodState
  final mockCreateTokenRequest = omise_dart.CreateTokenRequest(
    number: '4242424242424242',
    expirationMonth: "12",
    expirationYear: "25",
    securityCode: '123',
    name: "name",
  );
  final mockToken = omise_dart.Token(
      livemode: true,
      chargeStatus: omise_dart.ChargeStatus.pending,
      createdAt: DateTime.now(),
      used: false,
      object: 'token',
      id: 'tokn_test_123',
      card: omise_dart.Card(
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

  group("Credit Card Page Tests", () {
    testWidgets(
        'displays loading spinner when capabilityLoadingStatus is loading',
        (WidgetTester tester) async {
      when(() => mockController.value).thenReturn(CreditCardPaymentMethodState(
        capabilityLoadingStatus: Status.loading,
        tokenAndSourceLoadingStatus: Status.idle,
        createTokenRequest: mockCreateTokenRequest,
        textFieldValidityStatuses: mockTextFieldValidityStatuses,
      ));

      when(() => mockController.loadCapabilities())
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: CreditCardPage(
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
        tokenAndSourceLoadingStatus: Status.idle,
        capabilityErrorMessage: errorMessage,
        createTokenRequest: mockCreateTokenRequest,
        textFieldValidityStatuses: mockTextFieldValidityStatuses,
      ));

      when(() => mockController.loadCapabilities())
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: CreditCardPage(
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
        tokenAndSourceLoadingStatus: Status.idle,
        createTokenRequest: mockCreateTokenRequest,
        textFieldValidityStatuses: mockTextFieldValidityStatuses,
      ));

      when(() => mockController.loadCapabilities())
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(
        MaterialApp(
          home: CreditCardPage(
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
        tokenAndSourceLoadingStatus: Status.idle,
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
          home: CreditCardPage(
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
        tokenAndSourceLoadingStatus: Status.idle,
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
          home: CreditCardPage(
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
        tokenAndSourceLoadingStatus: Status.idle,
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
          home: CreditCardPage(
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
        tokenAndSourceLoadingStatus: Status.loading,
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
      when(() => mockController.createSourceAndToken())
          .thenAnswer((_) async => mockToken);

      await tester.pumpWidget(
        MaterialApp(
          home: CreditCardPage(
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
        tokenAndSourceLoadingStatus: Status.idle, // Finished loading
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
          home: CreditCardPage(
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
      tokenAndSourceLoadingStatus: Status.idle,
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
        home: CreditCardPage(
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

  testWidgets('expiry and cvv disabled when loan card',
      (WidgetTester tester) async {
    final mockLoanCardCreateTokenRequest = omise_dart.CreateTokenRequest(
      number: '4784451119188786',
      expirationMonth: "12",
      expirationYear: "25",
      securityCode: '123',
      name: "name",
    );
    when(() => mockController.value).thenReturn(CreditCardPaymentMethodState(
      capabilityLoadingStatus: Status.success,
      tokenAndSourceLoadingStatus: Status.idle,
      createTokenRequest: mockLoanCardCreateTokenRequest,
      textFieldValidityStatuses: {
        'cardNumber': true,
      },
    ));

    when(() => mockController.loadCapabilities())
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(
      MaterialApp(
        home: CreditCardPage(
          omiseApiService: mockOmiseApiService,
          creditCardPaymentMethodController: mockController,
        ),
      ),
    );

    // Find the TextFields
    final cardNumberField = find.byKey(const Key('cardNumber'));
    final expiryDateField = find.byKey(const Key('expiryDate'));

    // Type into the text fields
    await tester.enterText(cardNumberField, '4784451119188786');

    // Rebuild the widget after the state has changed
    await tester.pump();

    // Check that the fields contain the entered text
    expect(find.text('4784451119188786'), findsOneWidget);

    expect(tester.widget<TextField>(expiryDateField).enabled,
        isFalse); // TextField should be disabled
  });

  testWidgets('should show address fields when shouldShowAddressFields is true',
      (WidgetTester tester) async {
    mockCreateTokenRequest.country = 'CA';
    when(() => mockController.value).thenReturn(CreditCardPaymentMethodState(
      capabilityLoadingStatus: Status.success,
      tokenAndSourceLoadingStatus: Status.idle,
      capability: omise_dart.Capability(
        object: 'capability',
        location: '/capability',
        banks: ['scb', 'bbl'],
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
            banks: [
              omise_dart.Bank(
                  code: omise_dart.BankCode.affin, name: "name", active: true)
            ],
          ),
          omise_dart.PaymentMethod(
            object: 'payment_method',
            name: omise_dart.PaymentMethodName.promptpay,
            currencies: [omise_dart.Currency.thb],
            banks: [
              omise_dart.Bank(
                  code: omise_dart.BankCode.affin, name: "name", active: true)
            ],
          ),
        ],
        tokenizationMethods: [omise_dart.TokenizationMethod.applepay],
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
        home: CreditCardPage(
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
      tokenAndSourceLoadingStatus: Status.idle,
      capability: omise_dart.Capability(
        object: 'capability',
        location: '/capability',
        banks: ['scb', 'bbl'],
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
            banks: [
              omise_dart.Bank(
                  code: omise_dart.BankCode.affin, name: "name", active: true)
            ],
          ),
          omise_dart.PaymentMethod(
            object: 'payment_method',
            name: omise_dart.PaymentMethodName.promptpay,
            currencies: [omise_dart.Currency.thb],
            banks: [
              omise_dart.Bank(
                  code: omise_dart.BankCode.affin, name: "name", active: true)
            ],
          ),
        ],
        tokenizationMethods: [omise_dart.TokenizationMethod.applepay],
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
        home: CreditCardPage(
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
  testWidgets(
    'After token creation, the result is returned to the integrator when the "Pay" button is clicked',
    (WidgetTester tester) async {
      OmisePaymentResult?
          capturedResult; // To capture the result from the navigator pop
      final controller = CreditCardController(
        omiseApiService: mockOmiseApiService,
      );
      final mockCapability = omise_dart.Capability(
        object: 'capability',
        location: '/capability',
        banks: ['scb', 'bbl'],
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
            banks: [
              omise_dart.Bank(
                  code: omise_dart.BankCode.affin, name: "name", active: true)
            ],
          ),
          omise_dart.PaymentMethod(
            object: 'payment_method',
            name: omise_dart.PaymentMethodName.promptpay,
            currencies: [omise_dart.Currency.thb],
            banks: [
              omise_dart.Bank(
                  code: omise_dart.BankCode.affin, name: "name", active: true)
            ],
          ),
        ],
        tokenizationMethods: [omise_dart.TokenizationMethod.applepay],
        zeroInterestInstallments: false,
        country: 'TH',
      );

      when(() => mockOmiseApiService.getCapabilities())
          .thenAnswer((_) async => mockCapability);
      final mockToken = omise_dart.Token(
        livemode: true,
        chargeStatus: omise_dart.ChargeStatus.pending,
        createdAt: DateTime.now(),
        used: false,
        object: 'token',
        id: 'tokn_test_123',
        card: omise_dart.Card(
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
            createdAt: "createdAt"),
      );

      when(() => mockOmiseApiService.createToken(any()))
          .thenAnswer((_) async => mockToken);

      // Wrap the test in a Navigator to capture the result from the pop
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CreditCardPage(
                        omiseApiService: mockOmiseApiService,
                        creditCardPaymentMethodController: controller,
                      ),
                    ),
                  );
                  capturedResult =
                      result; // Capture the result from Navigator.pop
                },
                child: const Text('Open Credit Card Page'),
              );
            },
          ),
        ),
      );

      // Simulate opening the credit card page
      await tester.tap(find.text('Open Credit Card Page'));
      await tester.pumpAndSettle(); // Wait for the credit card page to open
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
      // Simulate pressing the "Pay" button
      await tester.pumpAndSettle();
      final payButton = find.byType(ElevatedButton);
      expect(tester.widget<ElevatedButton>(payButton).enabled, isTrue);
      await tester.tap(payButton);

      // Wait for the token creation process to complete and the page to pop
      await tester.pumpAndSettle();

      // Check if the result is captured correctly after the page is popped
      expect(capturedResult?.token?.id,
          equals(mockToken.id)); // Verify result from pop

      // Ensure the CreditCardPaymentMethodPage is no longer in the widget tree (i.e., the page was popped)
      expect(find.byType(CreditCardPage), findsNothing);
    },
  );
  testWidgets('close icon is displayed when single page credit card is used',
      (WidgetTester tester) async {
    when(() => mockController.value).thenReturn(CreditCardPaymentMethodState(
      capabilityLoadingStatus: Status.success,
      tokenAndSourceLoadingStatus: Status.idle,
      createTokenRequest: mockCreateTokenRequest,
      textFieldValidityStatuses: mockTextFieldValidityStatuses,
    ));

    when(() => mockController.loadCapabilities())
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(
      MaterialApp(
        home: CreditCardPage(
          omiseApiService: mockOmiseApiService,
          creditCardPaymentMethodController: mockController,
          automaticallyImplyLeading: false,
        ),
      ),
    );

    // Find the IconButton that has an Icon with Icons.close
    final closeButton = find.widgetWithIcon(IconButton, Icons.close);

// Ensure the close button is displayed
    expect(closeButton, findsOneWidget);

// Perform a tap on the close button
    await tester.tap(closeButton);
    await tester.pumpAndSettle();
    // Ensure the CreditCardPage is no longer in the widget tree (i.e., the page was popped)
    expect(find.byType(CreditCardPage), findsNothing);
  });
  testWidgets(
      'close icon is displayed when single page credit card is used from native apps',
      (WidgetTester tester) async {
    when(() => mockController.value).thenReturn(CreditCardPaymentMethodState(
      capabilityLoadingStatus: Status.success,
      tokenAndSourceLoadingStatus: Status.idle,
      createTokenRequest: mockCreateTokenRequest,
      textFieldValidityStatuses: mockTextFieldValidityStatuses,
    ));

    when(() => mockController.loadCapabilities())
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(
      MaterialApp(
        home: CreditCardPage(
          omiseApiService: mockOmiseApiService,
          creditCardPaymentMethodController: mockController,
          automaticallyImplyLeading: false,
          nativeResultMethodName: 'openCardPageResult',
        ),
      ),
    );

    // Find the IconButton that has an Icon with Icons.close
    final closeButton = find.widgetWithIcon(IconButton, Icons.close);

// Ensure the close button is displayed
    expect(closeButton, findsOneWidget);

// Perform a tap on the close button
    await tester.tap(closeButton);
    await tester.pumpAndSettle();
    // checking if the page is closed is not possible since the page will not be closed form the flutter side but the native apps will
    // close the flutter integration once they receive the result from the channels.
  });
}
