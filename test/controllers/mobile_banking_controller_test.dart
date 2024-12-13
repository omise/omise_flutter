import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_flutter/src/controllers/mobile_banking_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_dart/omise_dart.dart';

import '../mocks.dart';

void main() {
  late MobileBankingController controller;
  late MockOmiseApiService mockOmiseApiService;

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
  });
  setUpAll(() {
    registerFallbackValue(MockCreateSourceRequest());
  });
  const amount = 1000;
  const currency = Currency.thb;
  const paymentMethod = PaymentMethodName.mobileBankingScb;
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

  group('MobileBankingPaymentMethodSelectorController', () {
    test('CreateSource - success with selected payment method', () async {
      // Stub the API service to return the mocked capability
      when(() => mockOmiseApiService.createSource(any()))
          .thenAnswer((_) async => mockSource);

      // Initialize the controller
      controller = MobileBankingController(
        omiseApiService: mockOmiseApiService,
      );
      // set the source params
      controller.setSourceCreationParams(
        amount: amount,
        currency: currency,
      );
      // Listen for value changes
      var changes = <MobileBankingPageState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      // Call the createSource method
      await controller.createSource(paymentMethod);

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

      // Initialize the controller
      controller = MobileBankingController(
        omiseApiService: mockOmiseApiService,
      );

      // Listen for value changes
      var changes = <MobileBankingPageState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      // Call the createSource method
      await controller.createSource(paymentMethod);

      // Assertions
      expect(changes.length, 2); // One for loading, one for error
      expect(changes[0].sourceLoadingStatus, Status.loading);
      expect(changes[0].source, null);
      expect(changes[1].sourceLoadingStatus, Status.error);
      expect(changes[1].source, null);
    });
  });
}
