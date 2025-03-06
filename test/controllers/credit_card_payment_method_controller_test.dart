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

    test('isFormValid - returns correct validation', () {
      // Set multiple fields to valid
      controller.setTextFieldValidityStatuses('field1', true);
      controller.setTextFieldValidityStatuses('field2', true);
      controller.setTextFieldValidityStatuses('field3', true);
      controller.setTextFieldValidityStatuses('field4', true);

      expect(controller.value.isFormValid, true);
    });
  });
}
