import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/pages/paymentMethods/google_pay_page.dart';
import 'package:omise_flutter/src/pages/payment_authorization_page.dart';
import 'package:omise_flutter/src/pages/payment_methods_page.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';

/// [OmisePayment] is the main class that users should interact with
/// to utilize processing payments
/// using the Omise API. It initializes the necessary
/// services and provides a way to select payment methods.
class OmisePayment {
  final bool? enableDebug;
  final OmiseLocale? locale;
  final String publicKey;

  /// Creates an instance of [OmisePayment].
  ///
  /// Requires a [publicKey] for authenticating requests to the Omise API.
  ///
  /// An optional [enableDebug] parameter can be set to enable debugging
  /// logs for API requests and responses.
  /// An optional [locale] parameter that can be used to set the locale
  /// of the text. By default the SDK will use the `Localizations.localeOf(context)`.
  OmisePayment({
    required this.publicKey,
    this.enableDebug = false,
    this.locale,
  }) {
    // Initialize the OmiseApiService with the provided public key
    // and debug settings.
    omiseApiService = OmiseApiService(
      publicKey: publicKey,
      enableDebug: enableDebug,
    );
  }

  /// The instance of [OmiseApiService] used for making API calls
  /// related to payments.
  late OmiseApiService omiseApiService;

  /// Creates and returns a [PaymentMethodsPage] widget.
  ///
  /// This method allows the user to select payment methods. It takes an optional
  /// [selectedPaymentMethods] parameter, which is a list of payment method names
  /// that the merchant wants to display.
  ///
  /// [amount] Represents the amount that will be used in the source creation. Should follow the amount format supported by the omise API.
  ///
  /// [currency] Represents the currency that will be used in the source creation.
  /// [requestBillingAddress] - Determines if the billing address should be requested in google pay
  ///
  /// [requestPhoneNumber] - Determines if the phone number should be requested in google pay.
  ///
  /// [googleMerchantId] - The Google Merchant ID.
  ///
  /// [googlePayCardBrands] - Allowed card brands for Google Pay (e.g., ['VISA', 'MASTERCARD']).
  ///
  /// [googlePayEnvironment] - The environment for Google Pay ('TEST' or 'PRODUCTION'). If not provided the environment will determined based on the pkey of the merchant.
  ///
  /// [googlePayItemDescription] - The description of the item being purchased for Google Pay.
  ///
  /// Returns a [Widget] that represents the payment method selection page.
  Widget selectPaymentMethod(
      {List<PaymentMethodName>? selectedPaymentMethods,
      List<TokenizationMethod>? selectedTokenizationMethods,
      required int amount,
      required Currency currency,
      bool? requestBillingAddress = false,
      bool? requestPhoneNumber = false,
      String? googleMerchantId,
      List<String>? googlePayCardBrands,
      String? googlePayEnvironment,
      String? googlePayItemDescription}) {
    return PaymentMethodsPage(
      omiseApiService: omiseApiService, // Pass the Omise API service
      amount: amount,
      currency: currency,
      selectedPaymentMethods:
          selectedPaymentMethods, // Pass any pre-selected methods
      selectedTokenizationMethods: selectedTokenizationMethods,
      locale: locale, requestBillingAddress: requestBillingAddress!,
      requestPhoneNumber: requestPhoneNumber!,
      googlePlayMerchantId: googleMerchantId,
      cardBrands: googlePayCardBrands,
      googlePayEnvironment: googlePayEnvironment, pkey: publicKey,
      googlePayItemDescription: googlePayItemDescription,
    );
  }

  /// Builds and returns a [GooglePayPage] widget.
  ///
  /// This method directly presents the Google Pay payment page.
  ///
  /// [amount] - The transaction amount, following Omise API format.
  ///
  /// [currency] - The transaction currency.
  ///
  /// [googleMerchantId] - The Google Merchant ID.
  ///
  /// [requestBillingAddress] - Determines if billing address is requested in google pay
  ///
  /// [requestPhoneNumber] - Determines if phone number is requested in google pay
  ///
  /// [googlePayCardBrands] - Allowed card brands for Google Pay (e.g., ['VISA']).
  ///
  /// [googlePayEnvironment] - The environment for Google Pay ('TEST' or 'PRODUCTION'). If not provided the environment will determined based on the pkey of the merchant.
  ///
  /// [googlePayItemDescription] - The description of the item being purchased for Google Pay.
  ///
  /// Returns a [Widget] for the Google Pay payment page.
  Widget buildGooglePayPage(
      {required int amount,
      required Currency currency,
      required String googleMerchantId,
      bool? requestBillingAddress = false,
      bool? requestPhoneNumber = false,
      List<String>? googlePayCardBrands,
      String? googlePayEnvironment,
      String? googlePayItemDescription}) {
    return GooglePayPage(
      omiseApiService: omiseApiService, // Pass the Omise API service
      amount: amount,
      currency: currency,
      locale: locale, requestBillingAddress: requestBillingAddress!,
      requestPhoneNumber: requestPhoneNumber!,
      googlePlayMerchantId: googleMerchantId,
      cardBrands: googlePayCardBrands,
      environment: googlePayEnvironment,
      pkey: publicKey,
      itemDescription: googlePayItemDescription,
    );
  }

  /// Creates and returns a [PaymentAuthorizationPage] widget.
  ///
  /// This function is responsible for creating a payment authorization page
  /// that displays a WebView allowing the user to authorize a payment.
  ///
  /// - [authorizeUri] (required): The URL to be loaded in the WebView for
  ///   payment authorization.
  /// - [expectedReturnUrls] (optional): A list of return URLs to detect when the
  ///   payment authorization is complete and to close the WebView accordingly.
  ///
  /// Returns a [Widget] that represents the payment authorization page.
  Widget authorizePayment({
    required Uri authorizeUri,
    List<String>? expectedReturnUrls,
  }) {
    return PaymentAuthorizationPage(
      authorizeUri: authorizeUri,
      expectedReturnUrls: expectedReturnUrls,
      enableDebug: enableDebug,
      locale: locale,
    );
  }
}
