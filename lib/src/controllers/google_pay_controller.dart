import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/google_pay_request.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';

/// The [GooglePayController] manages the state and logic for
/// creating a mobile banking source from Omise API.
class GooglePayController extends ValueNotifier<GooglePayPageState> {
  /// Instance of [OmiseApiService] used to interact with the omise dart package.
  final OmiseApiService omiseApiService;
  final String pkey;

  /// Constructor for initializing [GooglePayController].
  /// Takes in a required [omiseApiService].
  GooglePayController({
    required this.omiseApiService,
    required this.pkey,
  }) : super(GooglePayPageState(tokenLoadingStatus: Status.idle));

  void setTokenCreationParams({
    required String googlePayMerchantId,
    required bool requestBillingAddress,
    required bool requestPhoneNumber,
    required int amount,
    required Currency currency,
    String? itemDescription,
  }) {
    _setValue(value.copyWith(
      googlePayMerchantId: googlePayMerchantId,
      requestBillingAddress: requestBillingAddress,
      requestPhoneNumber: requestPhoneNumber,
      amount: amount,
      currency: currency,
      itemDescription: itemDescription ?? '',
    ));
  }

  void setGooglePayParameters(List<String>? cardBrands, String? environment) {
    final googlePayRequest = GooglePayRequest(
      provider: 'google_pay',
      data: GooglePayData(
        environment: environment ??
            (pkey.contains('pkey_test_') ? 'TEST' : 'PRODUCTION'),
        apiVersion: 2,
        apiVersionMinor: 0,
        merchantInfo: MerchantInfo(merchantId: value.googlePayMerchantId!),
        allowedPaymentMethods: [
          AllowedPaymentMethod(
              type: "CARD",
              parameters: PaymentParameters(
                  allowedAuthMethods: ["PAN_ONLY", "CRYPTOGRAM_3DS"],
                  allowedCardNetworks:
                      cardBrands?.map((e) => e.toUpperCase()).toList() ??
                          ["AMEX", "DISCOVER", "JCB", "MASTERCARD", "VISA"],
                  billingAddressRequired: value.requestBillingAddress!,
                  billingAddressParameters: BillingAddressParameters(
                      format: "FULL",
                      phoneNumberRequired: value.requestPhoneNumber!)),
              tokenizationSpecification: TokenizationSpecification(
                  type: "PAYMENT_GATEWAY",
                  parameters: {
                    "gateway": "omise",
                    "gatewayMerchantId": pkey,
                  }))
        ],
        transactionInfo: TransactionInfo(
            totalPriceStatus: "FINAL", currencyCode: value.currency!.value),
      ),
    );
    _setValue(value.copyWith(
        googlePayRequest: jsonEncode(googlePayRequest.toJson())));
  }

  void setGooglePayResult(Map<String, dynamic> googlePayResult) {
    _setValue(value.copyWith(googlePaymentResult: googlePayResult));
  }

  /// Creates a source based on the collected data from the user.
  Future<void> createToken() async {
    try {
      // Set the status to loading while creating the token
      _setValue(value.copyWith(tokenLoadingStatus: Status.loading));
      final tokenRequest = CreateTokenRequest(
        method: TokenizationMethod.googlepay,
        data: value.googlePaymentResult!['paymentMethodData']
            ['tokenizationData']['token'],
      );
      if (value.requestBillingAddress == true) {
        final googleBillingInfo =
            value.googlePaymentResult!['paymentMethodData']['info']
                ['billingAddress'];
        // any null value will be automatically removed when the request is sent
        tokenRequest.billingName = googleBillingInfo['name'];
        tokenRequest.billingCity = googleBillingInfo['locality'];
        tokenRequest.billingCountry = googleBillingInfo['countryCode'];
        tokenRequest.billingPostalCode = googleBillingInfo['postalCode'];
        tokenRequest.billingState = googleBillingInfo['administrativeArea'];
        tokenRequest.billingStreet1 = googleBillingInfo['address1'];
        if (googleBillingInfo['address2'] != null &&
            googleBillingInfo['address2'].toString().isNotEmpty) {
          tokenRequest.billingStreet2 = googleBillingInfo['address2'];
        }
        if (value.requestPhoneNumber == true) {
          tokenRequest.billingPhoneNumber = googleBillingInfo['phoneNumber'];
        }
      }

      // Create the source using Omise API
      final token = await omiseApiService.createToken(tokenRequest,
          isTokenizationMethod: true);

      _setValue(value.copyWith(
        token: token,
        tokenLoadingStatus: Status.success,
      ));
    } catch (e) {
      // Handle errors and update the state with an error message
      var error = "";
      log(e.toString());
      if (e is OmiseApiException) {
        error = e.response?.message ?? e.message;
      } else {
        error = e.toString();
      }
      _setValue(value.copyWith(
          tokenLoadingStatus: Status.error, tokenErrorMessage: error));
    }
  }

  /// Internal helper function to update the state of [ValueNotifier].
  void _setValue(GooglePayPageState state) {
    value = state;
  }
}

/// State class that holds the values for [GooglePayController].
class GooglePayPageState {
  /// The token object received from the API after token creation.
  final Token? token;

  /// The current status of the source creation loading, such as idle, loading, success, or error.
  final Status tokenLoadingStatus;

  /// Optional error message in case of token failure.
  final String? tokenErrorMessage;

  /// The google play merchant id
  final String? googlePayMerchantId;

  /// The parameter to force request the billing address
  final bool? requestBillingAddress;

  /// The parameter to force request the phone number
  final bool? requestPhoneNumber;

  /// The paymentResult from google pay
  final Map<String, dynamic>? googlePaymentResult;

  /// The amount used in source creation.
  final int? amount;

  /// The currency used in source creation.
  final Currency? currency;

  /// The request params sent to google pay.
  final String? googlePayRequest;

  /// The description of the item being purchased.
  final String? itemDescription;

  /// Constructor for creating a [GooglePayPageState].
  GooglePayPageState(
      {required this.tokenLoadingStatus,
      this.token,
      this.tokenErrorMessage,
      this.googlePayMerchantId,
      this.requestBillingAddress,
      this.requestPhoneNumber,
      this.googlePaymentResult,
      this.amount,
      this.currency,
      this.googlePayRequest,
      this.itemDescription});

  /// Creates a copy of the current state while allowing overriding of
  /// specific fields. This is needed since in order to trigger a rebuild on the value notifier level, we need a new instance to be created for non primitive types.
  GooglePayPageState copyWith({
    Token? token,
    Status? tokenLoadingStatus,
    String? tokenErrorMessage,
    String? googlePayMerchantId,
    bool? requestBillingAddress,
    bool? requestPhoneNumber,
    Map<String, dynamic>? googlePaymentResult,
    int? amount,
    Currency? currency,
    String? googlePayRequest,
    String? itemDescription,
  }) {
    return GooglePayPageState(
      token: token ?? this.token,
      tokenLoadingStatus: tokenLoadingStatus ?? this.tokenLoadingStatus,
      tokenErrorMessage: tokenErrorMessage ?? this.tokenErrorMessage,
      googlePayMerchantId: googlePayMerchantId ?? this.googlePayMerchantId,
      requestBillingAddress:
          requestBillingAddress ?? this.requestBillingAddress,
      requestPhoneNumber: requestPhoneNumber ?? this.requestPhoneNumber,
      googlePaymentResult: googlePaymentResult ?? this.googlePaymentResult,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      googlePayRequest: googlePayRequest ?? this.googlePayRequest,
      itemDescription: itemDescription ?? this.itemDescription,
    );
  }
}
