import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/truemoney_wallet_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';

import '../mocks.dart';

void main() {
  late TrueMoneyWalletController controller;
  late MockOmiseApiService mockOmiseApiService;

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
  });

  setUpAll(() {
    registerFallbackValue(MockCreateSourceRequest());
  });

  const amount = 1000;
  const currency = Currency.thb;
  const phoneNumber = '0812345678';
  final mockSource = Source(
      object: 'source',
      id: 'src_123',
      amount: amount,
      currency: currency,
      type: PaymentMethodName.truemoney,
      livemode: false,
      chargeStatus: ChargeStatus.unknown,
      flow: 'flow',
      createdAt: DateTime.now());

  group('TrueMoneyWalletController Tests', () {
    test('setSourceCreationParams updates the state correctly', () {
      controller =
          TrueMoneyWalletController(omiseApiService: mockOmiseApiService);

      controller.setSourceCreationParams(amount: amount, currency: currency);

      expect(controller.value.amount, equals(amount));
      expect(controller.value.currency, equals(currency));
    });

    test('createSource succeeds when valid parameters are set', () async {
      when(() => mockOmiseApiService.createSource(any()))
          .thenAnswer((_) async => mockSource);

      controller =
          TrueMoneyWalletController(omiseApiService: mockOmiseApiService);
      controller.setSourceCreationParams(amount: amount, currency: currency);
      controller
          .updateState(controller.value.copyWith(phoneNumber: phoneNumber));

      var changes = <TrueMoneyWalletPageState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      await controller.createSource();

      expect(changes.length, 2);
      expect(changes[0].sourceLoadingStatus, Status.loading);
      expect(changes[1].sourceLoadingStatus, Status.success);
      expect(changes[1].source, mockSource);
    });

    test('createSource fails when required parameters are missing', () async {
      controller =
          TrueMoneyWalletController(omiseApiService: mockOmiseApiService);

      var changes = <TrueMoneyWalletPageState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      await controller.createSource();

      expect(changes.length, 2);
      expect(changes[0].sourceLoadingStatus, Status.loading);
      expect(changes[1].sourceLoadingStatus, Status.error);
      expect(changes[1].source, isNull);
    });

    test('createSource handles API exceptions properly', () async {
      when(() => mockOmiseApiService.createSource(any()))
          .thenThrow(OmiseApiException(message: 'API Error'));

      controller =
          TrueMoneyWalletController(omiseApiService: mockOmiseApiService);
      controller.setSourceCreationParams(amount: amount, currency: currency);
      controller
          .updateState(controller.value.copyWith(phoneNumber: phoneNumber));

      var changes = <TrueMoneyWalletPageState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      await controller.createSource();

      expect(changes.length, 2);
      expect(changes[0].sourceLoadingStatus, Status.loading);
      expect(changes[1].sourceLoadingStatus, Status.error);
      expect(changes[1].sourceErrorMessage, equals('API Error'));
    });
  });
}
