import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/google_pay_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/google_pay_request.dart';
import '../mocks.dart';

void main() {
  late MockOmiseApiService mockOmiseApiService;
  late GooglePayController googlePayController;
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
    googlePayController = GooglePayController(
      omiseApiService: mockOmiseApiService,
      pkey: testPublicKey,
    );
  });

  group('GooglePayController', () {
    test('initial state should be idle', () {
      expect(googlePayController.value.tokenLoadingStatus, Status.idle);
    });

    test('setTokenCreationParams updates state correctly', () {
      googlePayController.setTokenCreationParams(
        googlePayMerchantId: 'merchant_123',
        requestBillingAddress: true,
        requestPhoneNumber: true,
        amount: 1000,
        currency: Currency.thb,
        itemDescription: 'Test Item',
      );

      expect(googlePayController.value.googlePayMerchantId, 'merchant_123');
      expect(googlePayController.value.requestBillingAddress, true);
      expect(googlePayController.value.requestPhoneNumber, true);
      expect(googlePayController.value.amount, 10);
      expect(googlePayController.value.currency, Currency.thb);
      expect(googlePayController.value.itemDescription, 'Test Item');
    });

    test('setGooglePayParameters sets request JSON correctly', () {
      googlePayController.setTokenCreationParams(
        googlePayMerchantId: 'merchant_123',
        requestBillingAddress: true,
        requestPhoneNumber: true,
        amount: 1000,
        currency: Currency.thb,
      );
      googlePayController
          .setGooglePayParameters(['VISA', 'MASTERCARD'], 'TEST');

      expect(googlePayController.value.googlePayRequest, isNotNull);
      final request = GooglePayRequest.fromJson(
          jsonDecode(googlePayController.value.googlePayRequest!));
      expect(request.provider, 'google_pay');
      expect(request.data.environment, 'TEST');
      expect(
          request
              .data.allowedPaymentMethods.first.parameters.allowedCardNetworks,
          ['VISA', 'MASTERCARD']);
    });

    test('createToken updates state to loading and calls Omise API', () async {
      when(() => mockOmiseApiService.createToken(any(),
          isTokenizationMethod: true)).thenAnswer((_) async => mockToken);
      googlePayController.setTokenCreationParams(
        googlePayMerchantId: 'merchant_123',
        requestBillingAddress: true,
        requestPhoneNumber: true,
        amount: 1000,
        currency: Currency.thb,
      );

      googlePayController.setGooglePayResult({
        "apiVersion": 2,
        "apiVersionMinor": 0,
        "paymentMethodData": {
          "description": "Test Card: Visa••••1111",
          "info": {
            "assuranceDetails": {
              "accountVerified": true,
              "cardHolderAuthenticated": false
            },
            "billingAddress": {
              "address1": "1600 Amphitheatre Parkway",
              "address2": "",
              "address3": "",
              "administrativeArea": "CA",
              "countryCode": "US",
              "locality": "Mountain View",
              "name": "Card Holder Name",
              "phoneNumber": "6505555555",
              "postalCode": "94043",
              "sortingCode": ""
            },
            "cardDetails": "1111",
            "cardNetwork": "VISA"
          },
          "tokenizationData": {"token": "{}", "type": "PAYMENT_GATEWAY"},
          "type": "CARD"
        }
      });

      expect(googlePayController.value.tokenLoadingStatus, Status.idle);
      await googlePayController.createToken();

      expect(googlePayController.value.token, equals(mockToken));
      expect(googlePayController.value.tokenLoadingStatus, Status.success);
    });

    test('createToken handles errors and updates state correctly', () async {
      when(() => mockOmiseApiService.createToken(any(),
          isTokenizationMethod: true)).thenThrow(Exception('API Error'));

      googlePayController.setGooglePayResult({
        'paymentMethodData': {
          'tokenizationData': {'token': 'test_token'}
        }
      });

      await googlePayController.createToken();
      expect(googlePayController.value.tokenLoadingStatus, Status.error);
      expect(
          googlePayController.value.tokenErrorMessage, 'Exception: API Error');
    });
  });
}
