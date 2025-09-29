import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/credit_card_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';

import '../mocks.dart';

void main() {
  late CreditCardController controller;
  late MockOmiseApiService mockOmiseApiService;

  setUpAll(() {
    // The token request is accessed from the internal value of the controller making it hard to mock without mocking previously tested entities
    // so when the CreateTokenRequest type needs to be used it will be automatically replaced with this mock
    registerFallbackValue(MockCreateTokenRequest());
  });

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
    controller = CreditCardController(
      omiseApiService: mockOmiseApiService,
    );
  });

  group('CreditCardPaymentMethodController', () {
    test('loadCapabilities - success', () async {
      final mockCapability = Capability(
        object: 'capability',
        location: '/capability',
        banks: ['scb', 'bbl'],
        limits: Limits(
          chargeAmount: Amount(max: 100000, min: 100),
          transferAmount: Amount(max: 50000, min: 500),
          installmentAmount: InstallmentAmount(min: 1000),
        ),
        paymentMethods: [
          PaymentMethod(
            object: 'payment_method',
            name: PaymentMethodName.card,
            currencies: [Currency.thb],
            banks: [Bank(code: BankCode.affin, name: "name", active: true)],
          ),
          PaymentMethod(
            object: 'payment_method',
            name: PaymentMethodName.promptpay,
            currencies: [Currency.thb],
            banks: [Bank(code: BankCode.affin, name: "name", active: true)],
          ),
        ],
        tokenizationMethods: [TokenizationMethod.applepay],
        zeroInterestInstallments: false,
        country: 'TH',
      );

      when(() => mockOmiseApiService.getCapabilities())
          .thenAnswer((_) async => mockCapability);

      var changes = <CreditCardPaymentMethodState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      await controller.loadCapabilities();

      expect(changes.length, 2); // One for loading, one for success
      expect(changes[0].capabilityLoadingStatus, Status.loading);
      expect(changes[1].capabilityLoadingStatus, Status.success);
      expect(changes[1].capability!.country, 'TH');
    });

    test('loadCapabilities - error handling', () async {
      when(() => mockOmiseApiService.getCapabilities())
          .thenThrow(OmiseApiException(message: 'API Error'));

      var changes = <CreditCardPaymentMethodState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      await controller.loadCapabilities();

      expect(changes.length, 2); // One for loading, one for error
      expect(changes[0].capabilityLoadingStatus, Status.loading);
      expect(changes[1].capabilityLoadingStatus, Status.error);
      expect(changes[1].capabilityErrorMessage, 'API Error');
    });

    test('createToken - success', () async {
      final mockToken = Token(
          livemode: true,
          chargeStatus: ChargeStatus.pending,
          createdAt: DateTime.now(),
          used: false,
          object: 'token',
          id: 'tokn_test_123',
          card: Card(
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

      when(() => mockOmiseApiService.createToken(any()))
          .thenAnswer((_) async => mockToken);

      var changes = <CreditCardPaymentMethodState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      await controller.createSourceAndToken();

      expect(changes.length, 2); // One for loading, one for success
      expect(changes[0].tokenAndSourceLoadingStatus, Status.loading);
      expect(changes[1].tokenAndSourceLoadingStatus, Status.success);
      expect(changes[1].token!.id, 'tokn_test_123');
    });

    test('createToken - error handling', () async {
      when(() => mockOmiseApiService.createToken(any()))
          .thenThrow(OmiseApiException(message: 'Token Error'));

      // Listen for value changes
      var changes = <CreditCardPaymentMethodState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      // Call the createToken method
      await controller.createSourceAndToken();

      // Assertions
      expect(changes.length, 2); // One for loading, one for error
      expect(changes[0].tokenAndSourceLoadingStatus, Status.loading);
      expect(changes[1].tokenAndSourceLoadingStatus, Status.error);
      expect(changes[1].tokenAndSourceErrorMessage, 'Token Error');
    });

    test('setExpiryDate - valid expiry date', () {
      // Set a valid expiry date
      controller.setExpiryDate('12/25');

      expect(controller.value.createTokenRequest.expirationMonth, '12');
      expect(controller.value.createTokenRequest.expirationYear, '25');
    });

    test('setTextFieldValidityStatuses - updates validity status', () {
      // Set validity statuses
      controller.setTextFieldValidityStatuses('cardNumber', true);

      expect(controller.value.textFieldValidityStatuses['cardNumber'], true);
    });

    test('setCardHolderData - updates cardholder data', () {
      final mockCardHolderData = [
        CardHolderData.email,
        CardHolderData.phoneNumber,
      ];

      // Set cardholder data
      controller.setCardHolderData(cardHolderData: mockCardHolderData);

      expect(controller.value.cardHolderData, mockCardHolderData);
      expect(controller.value.cardHolderData!.length, 2);
    });

    test('numberOfFields - calculates correctly with email and phone', () {
      // Test with no email or phone (base case)
      expect(controller.value.numberOfFields, 4); // nonAvsFields for TH country

      // Test with email added
      controller.value =
          controller.value.copyWith(cardHolderData: [CardHolderData.email]);
      expect(controller.value.numberOfFields, 5); // base + 1 for email

      // Test with phone and email added
      controller.value = controller.value.copyWith(
          cardHolderData: [CardHolderData.email, CardHolderData.phoneNumber]);
      expect(controller.value.numberOfFields,
          6); // base + 1 for email + 1 for phone

      // Test with AVS country (US)
      controller.value.createTokenRequest.country = 'US';
      expect(controller.value.numberOfFields,
          10); // avsFields (8) + email (1) + phone (1)
    });

    test('numberOfFields - calculates correctly with loan card', () {
      // Set loan card number
      controller.value.createTokenRequest.number = '4784451119188786';
      controller.value = controller.value.copyWith(
          cardHolderData: [CardHolderData.email, CardHolderData.phoneNumber]);

      expect(controller.value.isLoanCard, true);
      expect(controller.value.numberOfFields,
          4); // nonAvsFields (4) - 2 (loan card) + 1 (email) + 1 (phone) = 4
    });

    test('isFormValid - returns correct validation with email and phone fields',
        () {
      // Set email and phone in token request to include them in field count
      controller.value = controller.value.copyWith(
          cardHolderData: [CardHolderData.email, CardHolderData.phoneNumber]);

      // Set all required fields (4 base + 1 email + 1 phone = 6 fields)
      controller.setTextFieldValidityStatuses('cardNumber', true);
      controller.setTextFieldValidityStatuses('expiryDate', true);
      controller.setTextFieldValidityStatuses('cvv', true);
      controller.setTextFieldValidityStatuses('name', true);
      controller.setTextFieldValidityStatuses(
        'email',
        true,
      );
      controller.setTextFieldValidityStatuses(
        'phoneNumber',
        true,
      );

      expect(controller.value.isFormValid, true);
    });

    test('isFormValid - returns false when email/phone fields are missing', () {
      // Set email and phone in token request to include them in field count
      controller.value = controller.value.copyWith(
          cardHolderData: [CardHolderData.email, CardHolderData.phoneNumber]);

      // Set only base fields (missing email and phone validation)
      controller.setTextFieldValidityStatuses('cardNumber', true);
      controller.setTextFieldValidityStatuses('expiryDate', true);
      controller.setTextFieldValidityStatuses('cvv', true);
      controller.setTextFieldValidityStatuses('name', true);

      expect(controller.value.isFormValid,
          false); // Should be false as email/phone validations missing
    });
  });
}
