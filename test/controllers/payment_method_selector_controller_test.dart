import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_flutter/src/controllers/payment_method_selector_controller.dart';
import 'package:omise_flutter/src/enums/status.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_dart/src/exceptions/omise_api_exception.dart';

import '../mocks.dart';

void main() {
  late PaymentMethodSelectorController controller;
  late MockOmiseApiService mockOmiseApiService;

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
  });

  group('PaymentMethodSelectorController', () {
    test('loadCapabilities - success with selected payment methods', () async {
      // Mock data for Capability, Limits, and PaymentMethod
      final mockCapability = Capability(
        object: 'capability',
        location: '/capability',
        banks: [Bank.scb, Bank.bbl],
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
            banks: [Bank.scb],
          ),
          PaymentMethod(
            object: 'payment_method',
            name: PaymentMethodName.promptpay,
            currencies: [Currency.thb],
            banks: [Bank.bbl],
          ),
        ],
        tokenizationMethods: [TokenizationMethod.applepay],
        zeroInterestInstallments: false,
        country: 'TH',
      );

      // Stub the API service to return the mocked capability
      when(() => mockOmiseApiService.getCapabilities())
          .thenAnswer((_) async => mockCapability);

      // Initialize the controller with selected payment methods
      controller = PaymentMethodSelectorController(
        omiseApiService: mockOmiseApiService,
        selectedPaymentMethods: [
          PaymentMethodName.card,
          PaymentMethodName.alipay
        ],
      );

      // Listen for value changes
      var changes = <PaymentMethodSelectorState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      // Call the loadCapabilities method
      await controller.loadCapabilities();

      // Assertions
      expect(changes.length, 2); // One for loading, one for success
      expect(changes[0].status, Status.loading);
      expect(changes[1].status, Status.success);
      expect(changes[1].viewablePaymentMethods!.length,
          1); // Only 'card' method should be available
      expect(
          changes[1].viewablePaymentMethods![0].name, PaymentMethodName.card);
    });

    test('loadCapabilities - error handling', () async {
      // Stub the API service to throw an exception
      when(() => mockOmiseApiService.getCapabilities())
          .thenThrow(OmiseApiException(message: 'API Error'));

      // Initialize the controller
      controller = PaymentMethodSelectorController(
        omiseApiService: mockOmiseApiService,
      );

      // Listen for value changes
      var changes = <PaymentMethodSelectorState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      // Call the loadCapabilities method
      await controller.loadCapabilities();

      // Assertions
      expect(changes.length, 2); // One for loading, one for error
      expect(changes[0].status, Status.loading);
      expect(changes[1].status, Status.error);
      expect(changes[1].errorMessage, 'API Error');
    });
  });
}
