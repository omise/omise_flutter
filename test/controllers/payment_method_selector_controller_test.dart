import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_flutter/src/controllers/payment_methods_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_dart/omise_dart.dart';

import '../mocks.dart';

void main() {
  late PaymentMethodsController controller;
  late MockOmiseApiService mockOmiseApiService;

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
  });
  setUpAll(() {
    registerFallbackValue(MockCreateSourceRequest());
  });
  const amount = 1000;
  const currency = Currency.thb;
  const paymentMethod = PaymentMethodName.card;
  final mockSource = Source(
      object: 'source',
      id: 'src_123',
      amount: amount,
      currency: currency,
      type: paymentMethod,
      livemode: false,
      chargeStatus: ChargeStatus.unknown,
      flow: 'flow',
      createdAt: DateTime.now());

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
      controller = PaymentMethodsController(
        omiseApiService: mockOmiseApiService,
        selectedPaymentMethods: [
          PaymentMethodName.card,
          PaymentMethodName.alipay
        ],
      );

      // Listen for value changes
      var changes = <PaymentMethodsState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      // Call the loadCapabilities method
      await controller.loadCapabilities();

      // Assertions
      expect(changes.length, 2); // One for loading, one for success
      expect(changes[0].capabilityLoadingStatus, Status.loading);
      expect(changes[1].capabilityLoadingStatus, Status.success);
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
      controller = PaymentMethodsController(
        omiseApiService: mockOmiseApiService,
      );

      // Listen for value changes
      var changes = <PaymentMethodsState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      // Call the loadCapabilities method
      await controller.loadCapabilities();

      // Assertions
      expect(changes.length, 2); // One for loading, one for error
      expect(changes[0].capabilityLoadingStatus, Status.loading);
      expect(changes[1].capabilityLoadingStatus, Status.error);
      expect(changes[1].capabilityErrorMessage, 'API Error');
    });
  });

  test('CreateSource - success with selected payment method', () async {
    // Stub the API service to return the mocked capability
    when(() => mockOmiseApiService.createSource(any()))
        .thenAnswer((_) async => mockSource);

    // Initialize the controller with selected payment methods
    controller = PaymentMethodsController(
      omiseApiService: mockOmiseApiService,
      selectedPaymentMethods: [
        PaymentMethodName.card,
        PaymentMethodName.promptpay
      ],
    );
    controller.setSourceCreationParams(
        amount: amount,
        currency: currency,
        selectedPaymentMethod: paymentMethod);
    // Listen for value changes
    var changes = <PaymentMethodsState>[];
    controller.addListener(() {
      changes.add(controller.value);
    });

    // Call the createSource method
    await controller.createSource();

    // Assertions
    expect(changes.length, 2); // One for loading, one for success
    expect(changes[0].sourceLoadingStatus, Status.loading);
    expect(changes[0].source, null);
    expect(changes[1].sourceLoadingStatus, Status.success);
    expect(changes[1].source, mockSource);
  });

  test('CreateSource - fails with no  params set for create source request',
      () async {
    // Mock data for source

    // Stub the API service to return the mocked capability
    when(() => mockOmiseApiService.createSource(any()))
        .thenAnswer((_) async => mockSource);

    // Initialize the controller with selected payment methods
    controller = PaymentMethodsController(
      omiseApiService: mockOmiseApiService,
      selectedPaymentMethods: [
        PaymentMethodName.card,
        PaymentMethodName.promptpay
      ],
    );

    // Listen for value changes
    var changes = <PaymentMethodsState>[];
    controller.addListener(() {
      changes.add(controller.value);
    });

    // Call the createSource method
    await controller.createSource();

    // Assertions
    expect(changes.length, 2); // One for loading, one for success
    expect(changes[0].sourceLoadingStatus, Status.loading);
    expect(changes[0].source, null);
    expect(changes[1].sourceLoadingStatus, Status.error);
    expect(changes[1].source, null);
  });
}
