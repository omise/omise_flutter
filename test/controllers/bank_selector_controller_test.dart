import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_flutter/src/controllers/bank_selector_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_dart/omise_dart.dart';

import '../mocks.dart';

void main() {
  late BankSelectorController controller;
  late MockOmiseApiService mockOmiseApiService;

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
  });

  setUpAll(() {
    registerFallbackValue(MockCreateSourceRequest());
  });

  const amount = 1000;
  const currency = Currency.myr;
  const email = "test@example.com";
  const fpxBankCode = BankCode.ambank;
  final mockSource = Source(
    object: 'source',
    id: 'src_123',
    amount: amount,
    currency: currency,
    type: PaymentMethodName.fpx,
    livemode: false,
    chargeStatus: ChargeStatus.unknown,
    flow: 'redirect',
    createdAt: DateTime.now(),
  );

  group('FpxBankSelectorController', () {
    test('CreateSource - success with valid params', () async {
      // Stub the API service
      when(() => mockOmiseApiService.createSource(any()))
          .thenAnswer((_) async => mockSource);

      // Initialize the controller
      controller = BankSelectorController(
        omiseApiService: mockOmiseApiService,
      );

      // Set the source params
      controller.setSourceCreationParams(
          amount: amount,
          currency: currency,
          email: email,
          paymentMethod: PaymentMethodName.fpx);

      // Track state changes
      var changes = <FpxBankSelectorPageState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      // Call createSource
      await controller.createSource(fpxBankCode);

      // Assertions
      expect(changes.length, 2); // One for loading, one for success
      expect(changes[0].sourceLoadingStatus, Status.loading);
      expect(changes[0].source, null);
      expect(changes[1].sourceLoadingStatus, Status.success);
      expect(changes[1].source, mockSource);
    });

    test('CreateSource - fails with missing params', () async {
      // Stub the API service
      when(() => mockOmiseApiService.createSource(any()))
          .thenAnswer((_) async => mockSource);

      // Initialize the controller
      controller = BankSelectorController(
        omiseApiService: mockOmiseApiService,
      );

      // Track state changes
      var changes = <FpxBankSelectorPageState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      // Call createSource without setting params
      await controller.createSource(fpxBankCode);

      // Assertions
      expect(changes.length, 2); // One for loading, one for error
      expect(changes[0].sourceLoadingStatus, Status.loading);
      expect(changes[1].sourceLoadingStatus, Status.error);
      expect(changes[1].source, null);
      expect(changes[1].sourceErrorMessage, isNotNull);
    });
  });
}
