import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_flutter/src/controllers/econtext_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_dart/omise_dart.dart';

import '../mocks.dart';

class MockOmiseApiService extends Mock implements OmiseApiService {}

void main() {
  late EcontextController controller;
  late MockOmiseApiService mockOmiseApiService;

  setUpAll(() {
    registerFallbackValue(MockCreateSourceRequest());
  });
  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
    controller = EcontextController(omiseApiService: mockOmiseApiService);
  });
  const amount = 1000;
  const currency = Currency.thb;
  final mockSource = Source(
    object: 'source',
    id: 'src_123',
    amount: amount,
    currency: currency,
    type: PaymentMethodName.atome,
    livemode: false,
    chargeStatus: ChargeStatus.unknown,
    flow: 'redirect',
    createdAt: DateTime.now(),
  );

  test('Initial state should be idle', () {
    expect(controller.value.sourceLoadingStatus, Status.idle);
    expect(controller.value.textFieldValidityStatuses, isEmpty);
  });

  test('setSourceCreationParams should update source creation request', () {
    controller.setSourceCreationParams(
      amount: amount,
      currency: Currency.thb,
    );

    expect(controller.value.createSourceRequest, isNotNull);
    expect(controller.value.createSourceRequest!.amount, amount);
    expect(controller.value.createSourceRequest!.currency, currency);
  });

  test('setTextFieldValidityStatuses updates the validation state', () {
    controller.setTextFieldValidityStatuses("email", true);
    expect(controller.value.textFieldValidityStatuses["email"], true);

    controller.setTextFieldValidityStatuses("email", false);
    expect(controller.value.textFieldValidityStatuses["email"], false);
  });

  test('createSource updates state to loading, then success', () async {
    when(() => mockOmiseApiService.createSource(any()))
        .thenAnswer((_) async => mockSource);

    controller.setSourceCreationParams(
      amount: 1000,
      currency: Currency.thb,
    );

    final future = controller.createSource();

    expect(controller.value.sourceLoadingStatus, Status.loading);

    await future;

    expect(controller.value.sourceLoadingStatus, Status.success);
    expect(controller.value.source, mockSource);
  });

  test('createSource handles API errors and sets error state', () async {
    when(() => mockOmiseApiService.createSource(any()))
        .thenThrow(OmiseApiException(message: "API Error"));

    controller.setSourceCreationParams(
      amount: amount,
      currency: currency,
    );

    await controller.createSource();

    expect(controller.value.sourceLoadingStatus, Status.error);
    expect(controller.value.sourceErrorMessage, "API Error");
  });
}
