import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_flutter/src/controllers/atome_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_dart/omise_dart.dart';

import '../mocks.dart';

class MockOmiseApiService extends Mock implements OmiseApiService {}

void main() {
  late AtomeController controller;
  late MockOmiseApiService mockOmiseApiService;

  setUpAll(() {
    registerFallbackValue(MockCreateSourceRequest());
  });
  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
    controller = AtomeController(omiseApiService: mockOmiseApiService);
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
  final mockItem =
      Item(name: "Test Item", quantity: 1, amount: amount, sku: 'sku');

  test('Initial state should be idle with shipping same as billing', () {
    expect(controller.value.sourceLoadingStatus, Status.idle);
    expect(controller.value.shippingSameAsBilling, true);
    expect(controller.value.textFieldValidityStatuses, isEmpty);
  });

  test('setSourceCreationParams should update source creation request', () {
    final mockItems = [mockItem];
    controller.setSourceCreationParams(
      amount: amount,
      currency: Currency.thb,
      items: mockItems,
    );

    expect(controller.value.createSourceRequest, isNotNull);
    expect(controller.value.createSourceRequest!.amount, amount);
    expect(controller.value.createSourceRequest!.currency, currency);
    expect(controller.value.createSourceRequest!.items, mockItems);
  });

  test('setShippingSameAsBilling should update state', () {
    controller.setShippingSameAsBilling(false);
    expect(controller.value.shippingSameAsBilling, false);
  });

  test('setTextFieldValidityStatuses updates the validation state', () {
    controller.setTextFieldValidityStatuses("email", true);
    expect(controller.value.textFieldValidityStatuses["email"], true);

    controller.setTextFieldValidityStatuses("email", false);
    expect(controller.value.textFieldValidityStatuses["email"], false);
  });
  test('setShippingSameAsBilling removes billing field validations when false',
      () {
    controller.setTextFieldValidityStatuses("billing_name", true);
    controller.setShippingSameAsBilling(false);

    expect(
        controller.value.textFieldValidityStatuses.containsKey("billing_name"),
        false);
  });

  test('createSource updates state to loading, then success', () async {
    when(() => mockOmiseApiService.createSource(any()))
        .thenAnswer((_) async => mockSource);

    controller.setSourceCreationParams(
      amount: 1000,
      currency: Currency.thb,
      items: [mockItem],
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
      items: [mockItem],
    );

    await controller.createSource();

    expect(controller.value.sourceLoadingStatus, Status.error);
    expect(controller.value.sourceErrorMessage, "API Error");
  });
}
