import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/apple_pay_request.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/utils/payment_utils.dart';

/// The [ApplePayController] manages the state and logic for
/// creating a mobile banking source from Omise API.
class ApplePayController extends ValueNotifier<ApplePayPageState> {
  /// Instance of [OmiseApiService] used to interact with the omise dart package.
  final OmiseApiService omiseApiService;
  final String pkey;

  /// Constructor for initializing [ApplePayController].
  /// Takes in a required [omiseApiService].
  ApplePayController({
    required this.omiseApiService,
    required this.pkey,
  }) : super(ApplePayPageState(tokenLoadingStatus: Status.idle));

  void setTokenCreationParams({
    required String applePayMerchantId,
    List<String>? requiredShippingContactFields,
    List<String>? requiredBillingContactFields,
    required int amount,
    required Currency currency,
    required String country,
    String? itemDescription,
  }) {
    _setValue(value.copyWith(
      applePayMerchantId: applePayMerchantId,
      requiredBillingContactFields:
          requiredBillingContactFields ?? ["name", "phone", "postalAddress"],
      requiredShippingContactFields: requiredShippingContactFields ?? [],
      amount: PaymentUtils.parseAmount(amount, currency),
      currency: currency,
      country: country,
      itemDescription: itemDescription ?? '',
    ));
  }

  void setApplePayParameters(
    List<String>? cardBrands,
  ) {
    final applePayRequest = ApplePayRequest(
      provider: 'apple_pay',
      data: ApplePayData(
        supportedNetworks: cardBrands ??
            ["amex", "discover", "jcb", "masterCard", "visa", "chinaUnionPay"],
        merchantCapabilities: ["3DS", "debit", "credit"],
        currencyCode: value.currency!.value,
        merchantIdentifier: value.applePayMerchantId!,
        countryCode: value.country!,
        requiredShippingContactFields: value.requiredShippingContactFields!,
        requiredBillingContactFields: value.requiredBillingContactFields!,
      ),
    );
    _setValue(
        value.copyWith(applePayRequest: jsonEncode(applePayRequest.toJson())));
  }

  void setApplePayResult(Map<String, dynamic> applePayResult) {
    _setValue(value.copyWith(applePaymentResult: applePayResult));
  }

  /// Creates a token based on the collected data from the user.
  Future<void> createToken() async {
    try {
      // Set the status to loading while creating the token
      _setValue(value.copyWith(tokenLoadingStatus: Status.loading));
      final tokenRequest = CreateTokenRequest(
        method: TokenizationMethod.applepay,
        merchantId: value.applePayMerchantId!,
        data: value.applePaymentResult!['token']!,
      );
      final appleBillingInfo = value.applePaymentResult!['billingContact'];

      if (appleBillingInfo != null) {
        // any null value will be automatically removed when the request is sent
        if (appleBillingInfo['name']?['givenName']?.toString().isNotEmpty ==
            true) {
          tokenRequest.billingName =
              "${appleBillingInfo['name']['givenName']} ${appleBillingInfo['name']['familyName']}";
        }

        final postalAddress = appleBillingInfo['postalAddress'] ?? {};
        tokenRequest.billingCity = postalAddress['city'];
        tokenRequest.billingCountry = postalAddress['isoCountryCode'];
        tokenRequest.billingPostalCode = postalAddress['postalCode'];
        tokenRequest.billingState = postalAddress['state'];
        tokenRequest.billingStreet1 = postalAddress['street'];

        tokenRequest.billingPhoneNumber = appleBillingInfo['phoneNumber'];
        tokenRequest.brand =
            value.applePaymentResult!['paymentMethod']['network'];
      }
      // Create the token using Omise API
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
  void _setValue(ApplePayPageState state) {
    value = state;
  }
}

/// State class that holds the values for [ApplePayController].
class ApplePayPageState {
  /// The token object received from the API after token creation.
  final Token? token;

  /// The current status of the source creation loading, such as idle, loading, success, or error.
  final Status tokenLoadingStatus;

  /// Optional error message in case of token failure.
  final String? tokenErrorMessage;

  /// The apple pay merchant id
  final String? applePayMerchantId;

  final List<String>? requiredShippingContactFields;

  final List<String>? requiredBillingContactFields;

  /// The paymentResult from apple pay
  final Map<String, dynamic>? applePaymentResult;

  /// The amount used in source creation.
  final num? amount;

  /// The currency used in source creation.
  final Currency? currency;

  /// The country used in token creation, capability api is used to set it.
  final String? country;

  /// The request params sent to apple pay.
  final String? applePayRequest;

  /// The description of the item being purchased.
  final String? itemDescription;

  /// Constructor for creating a [ApplePayPageState].
  ApplePayPageState(
      {required this.tokenLoadingStatus,
      this.token,
      this.tokenErrorMessage,
      this.applePayMerchantId,
      this.requiredBillingContactFields,
      this.requiredShippingContactFields,
      this.applePaymentResult,
      this.amount,
      this.currency,
      this.country,
      this.applePayRequest,
      this.itemDescription});

  /// Creates a copy of the current state while allowing overriding of
  /// specific fields. This is needed since in order to trigger a rebuild on the value notifier level, we need a new instance to be created for non primitive types.
  ApplePayPageState copyWith({
    Token? token,
    Status? tokenLoadingStatus,
    String? tokenErrorMessage,
    String? applePayMerchantId,
    final List<String>? requiredShippingContactFields,
    final List<String>? requiredBillingContactFields,
    Map<String, dynamic>? applePaymentResult,
    num? amount,
    Currency? currency,
    String? country,
    String? applePayRequest,
    String? itemDescription,
  }) {
    return ApplePayPageState(
      token: token ?? this.token,
      tokenLoadingStatus: tokenLoadingStatus ?? this.tokenLoadingStatus,
      tokenErrorMessage: tokenErrorMessage ?? this.tokenErrorMessage,
      applePayMerchantId: applePayMerchantId ?? this.applePayMerchantId,
      requiredBillingContactFields:
          requiredBillingContactFields ?? this.requiredBillingContactFields,
      requiredShippingContactFields:
          requiredShippingContactFields ?? this.requiredShippingContactFields,
      applePaymentResult: applePaymentResult ?? this.applePaymentResult,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      country: country ?? this.country,
      applePayRequest: applePayRequest ?? this.applePayRequest,
      itemDescription: itemDescription ?? this.itemDescription,
    );
  }
}
