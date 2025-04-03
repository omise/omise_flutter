import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/apple_pay_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/apple_pay_request.dart';
import '../mocks.dart';

void main() {
  late MockOmiseApiService mockOmiseApiService;
  late ApplePayController applePayController;
  const testPublicKey = 'test_pkey';
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

  setUpAll(() {
    registerFallbackValue(MockCreateTokenRequest());
  });
  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
    applePayController = ApplePayController(
      omiseApiService: mockOmiseApiService,
      pkey: testPublicKey,
    );
  });

  group('ApplePayController', () {
    test('initial state should be idle', () {
      expect(applePayController.value.tokenLoadingStatus, Status.idle);
    });

    test('setTokenCreationParams updates state correctly', () {
      applePayController.setTokenCreationParams(
        applePayMerchantId: 'merchant_123',
        amount: 1000,
        country: 'TH',
        currency: Currency.thb,
        itemDescription: 'Test Item',
      );

      expect(applePayController.value.applePayMerchantId, 'merchant_123');
      expect(applePayController.value.country, 'TH');
      expect(applePayController.value.amount, 10);
      expect(applePayController.value.currency, Currency.thb);
      expect(applePayController.value.itemDescription, 'Test Item');
    });

    test('setApplePayParameters sets request JSON correctly', () {
      applePayController.setTokenCreationParams(
        applePayMerchantId: 'merchant_123',
        amount: 1000,
        country: 'TH',
        currency: Currency.thb,
        itemDescription: 'Test Item',
      );
      applePayController.setApplePayParameters(
        ['VISA', 'MASTERCARD'],
      );

      expect(applePayController.value.applePayRequest, isNotNull);
      final request = ApplePayRequest.fromJson(
          jsonDecode(applePayController.value.applePayRequest!));
      expect(request.provider, 'apple_pay');
      expect(request.data.countryCode, 'TH');
      expect(request.data.supportedNetworks, ['VISA', 'MASTERCARD']);
    });

    test('createToken updates state to loading and calls Omise API', () async {
      when(() => mockOmiseApiService.createToken(any(),
          isTokenizationMethod: true)).thenAnswer((_) async => mockToken);
      applePayController.setTokenCreationParams(
        applePayMerchantId: 'merchant_123',
        amount: 1000,
        country: 'TH',
        currency: Currency.thb,
        itemDescription: 'Test Item',
      );

      applePayController.setApplePayResult({
        "token": 'encryptedToken',
        "billingContact": {
          "givenName": "John",
          "familyName": "Doe",
          "emailAddress": "john.doe@example.com",
          "phoneNumber": "+1 (555) 123-4567",
          "postalAddress": {
            "street": "123 Main St",
            "city": "San Francisco",
            "state": "CA",
            "postalCode": "94105",
            "country": "US",
            "countryCode": "US",
            "isoCountryCode": "USA",
          }
        },
        "shippingContact": {
          "givenName": "Jane",
          "familyName": "Doe",
          "emailAddress": "jane.doe@example.com",
          "phoneNumber": "+1 (555) 987-6543",
          "postalAddress": {
            "street": "456 Elm St",
            "city": "Los Angeles",
            "state": "CA",
            "postalCode": "90001",
            "country": "US",
            "countryCode": "US",
            "isoCountryCode": "USA",
          }
        },
        "shippingMethod": {
          "identifier": "express",
          "label": "Express Shipping",
          "detail": "Arrives in 2-3 days",
          "amount": "10.00"
        },
        "paymentMethod": {"network": "visa"}
      });

      expect(applePayController.value.tokenLoadingStatus, Status.idle);
      await applePayController.createToken();

      expect(applePayController.value.token, equals(mockToken));
      expect(applePayController.value.tokenLoadingStatus, Status.success);
    });

    test('createToken handles errors and updates state correctly', () async {
      when(() => mockOmiseApiService.createToken(any(),
          isTokenizationMethod: true)).thenThrow(Exception('API Error'));
      applePayController.setTokenCreationParams(
        applePayMerchantId: 'merchant_123',
        amount: 1000,
        country: 'TH',
        currency: Currency.thb,
        itemDescription: 'Test Item',
      );
      applePayController.setApplePayResult({
        "token": 'encryptedToken',
        "billingContact": {
          "givenName": "John",
          "familyName": "Doe",
          "emailAddress": "john.doe@example.com",
          "phoneNumber": "+1 (555) 123-4567",
          "postalAddress": {
            "street": "123 Main St",
            "city": "San Francisco",
            "state": "CA",
            "postalCode": "94105",
            "country": "US",
            "countryCode": "US",
            "isoCountryCode": "USA",
          }
        },
        "shippingContact": {
          "givenName": "Jane",
          "familyName": "Doe",
          "emailAddress": "jane.doe@example.com",
          "phoneNumber": "+1 (555) 987-6543",
          "postalAddress": {
            "street": "456 Elm St",
            "city": "Los Angeles",
            "state": "CA",
            "postalCode": "90001",
            "country": "US",
            "countryCode": "US",
            "isoCountryCode": "USA",
          }
        },
        "shippingMethod": {
          "identifier": "express",
          "label": "Express Shipping",
          "detail": "Arrives in 2-3 days",
          "amount": "10.00"
        },
        "paymentMethod": {"network": "visa"}
      });

      await applePayController.createToken();
      expect(applePayController.value.tokenLoadingStatus, Status.error);
      expect(
          applePayController.value.tokenErrorMessage, 'Exception: API Error');
    });
  });
}
