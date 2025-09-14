import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_flutter/src/controllers/installments_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_dart/omise_dart.dart';

import '../mocks.dart';

void main() {
  late InstallmentsController controller;
  late MockOmiseApiService mockOmiseApiService;
  late MockCapability mockCapability;
  final MockBuildContext mockBuildContext = MockBuildContext();
  const amount = 1000000;
  const currency = Currency.thb;
  const paymentMethod = PaymentMethodName.installmentScb;
  final terms = [3, 6, 9];

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
    mockCapability = MockCapability();
  });

  setUpAll(() {
    registerFallbackValue(MockCreateSourceRequest());
  });

  final mockSource = Source(
    object: 'source',
    id: 'src_123',
    amount: amount,
    currency: currency,
    type: paymentMethod,
    livemode: false,
    chargeStatus: ChargeStatus.unknown,
    flow: 'redirect',
    createdAt: DateTime.now(),
  );
  final cardHolderData = [CardHolderData.email, CardHolderData.phoneNumber];

  group('InstallmentsController', () {
    test('setSourceCreationParams updates state correctly', () {
      controller = InstallmentsController(
        omiseApiService: mockOmiseApiService,
      );
      when(() => mockCapability.zeroInterestInstallments).thenReturn(false);
      controller.setSourceCreationParams(
          amount: amount,
          currency: currency,
          paymentMethod: paymentMethod,
          capability: mockCapability,
          terms: terms,
          cardHolderData: [CardHolderData.email, CardHolderData.phoneNumber]);

      expect(controller.value.amount, amount);
      expect(controller.value.currency, currency);
      expect(controller.value.paymentMethod, paymentMethod);
      expect(controller.value.capability, mockCapability);
      expect(controller.value.terms, isNotEmpty);
    });

    test('processInstallment - success', () async {
      controller = InstallmentsController(
        omiseApiService: mockOmiseApiService,
      );
      when(() => mockOmiseApiService.createSource(any()))
          .thenAnswer((_) async => mockSource);
      when(() => mockCapability.zeroInterestInstallments).thenReturn(false);
      controller.setSourceCreationParams(
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
        capability: mockCapability,
        terms: terms,
        cardHolderData: cardHolderData,
      );

      var changes = <InstallmentsPageState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      await controller.processInstallment(
          term: terms.first, context: mockBuildContext);

      expect(changes.length, 2);
      expect(changes[0].sourceLoadingStatus, Status.loading);
      expect(changes[1].sourceLoadingStatus, Status.success);
      expect(changes[1].source, mockSource);
    });

    test('processInstallment - failure', () async {
      when(() => mockOmiseApiService.createSource(any()))
          .thenThrow(OmiseApiException(message: "API Error"));
      when(() => mockCapability.zeroInterestInstallments).thenReturn(false);

      controller = InstallmentsController(
        omiseApiService: mockOmiseApiService,
      );

      controller.setSourceCreationParams(
          amount: amount,
          currency: currency,
          paymentMethod: paymentMethod,
          capability: mockCapability,
          terms: terms,
          cardHolderData: cardHolderData);

      var changes = <InstallmentsPageState>[];
      controller.addListener(() {
        changes.add(controller.value);
      });

      await controller.processInstallment(
          term: terms.first, context: mockBuildContext);

      expect(changes.length, 2);
      expect(changes[0].sourceLoadingStatus, Status.loading);
      expect(changes[1].sourceLoadingStatus, Status.error);
      expect(changes[1].sourceErrorMessage, "API Error");
    });
  });
}
