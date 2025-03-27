import 'package:flutter/material.dart';
import 'package:omise_flutter/omise_flutter.dart';
import 'package:omise_flutter_module/enums.dart';

/// The [MethodChannelController] manages the state and logic for
/// creating a mobile banking source from Omise API.
class MethodChannelController extends ValueNotifier<MethodChannelState> {
  /// Constructor for initializing [MethodChannelController].
  MethodChannelController() : super(MethodChannelState());

  void setMethodChannelArguments({
    required MethodNames methodName,
    String? pkey,
    int? amount,
    Currency? currency,
    String? authUrl,
    List<String>? expectedReturnUrls,
    List<PaymentMethodName>? selectedPaymentMethods,
    List<TokenizationMethod>? selectedTokenizationMethods,
    String? googlePayMerchantId,
    bool? googlePayRequestBillingAddress,
    bool? googlePayRequestPhoneNumber,
    List<String>? googlePayCardBrands,
    String? googlePayEnvironment,
    String? googlePayItemDescription,
    String? applePayMerchantId,
    List<String>? applePayRequiredBillingContactFields,
    List<String>? applePayRequiredShippingContactFields,
    List<String>? applePayCardBrands,
    String? applePayItemDescription,
    List<Item>? atomeItems,
  }) {
    _setValue(value.copyWith(
      methodName: methodName,
      amount: amount,
      currency: currency,
      authUrl: authUrl,
      expectedReturnUrls: expectedReturnUrls,
      pkey: pkey,
      selectedPaymentMethods: selectedPaymentMethods,
      selectedTokenizationMethods: selectedTokenizationMethods,
      googlePayMerchantId: googlePayMerchantId,
      googlePayRequestBillingAddress: googlePayRequestBillingAddress,
      googlePayRequestPhoneNumber: googlePayRequestPhoneNumber,
      googlePayCardBrands: googlePayCardBrands,
      googlePayEnvironment: googlePayEnvironment,
      googlePayItemDescription: googlePayItemDescription,
      applePayMerchantId: applePayMerchantId,
      applePayRequiredBillingContactFields:
          applePayRequiredBillingContactFields,
      applePayRequiredShippingContactFields:
          applePayRequiredShippingContactFields,
      applePayCardBrands: applePayCardBrands,
      applePayItemDescription: applePayItemDescription,
      atomeItems: atomeItems,
    ));
  }

  /// Internal helper function to update the state of [ValueNotifier].
  void _setValue(MethodChannelState state) {
    value = state;
  }
}

/// State class that holds the values for [MethodChannelController].
class MethodChannelState {
  /// The method name passed from native to flutter
  final MethodNames? methodName;

  // The pkey passed from native to flutter
  final String? pkey;

  /// The amount used in source creation.
  final int? amount;

  /// The currency used in source creation.
  final Currency? currency;

  /// The url to authorize the charge
  final String? authUrl;

  /// A list of URLs that are expected as return URLs from the WebView.
  final List<String>? expectedReturnUrls;

  /// The list of payment methods specified by the user.
  final List<PaymentMethodName>? selectedPaymentMethods;

  /// List of selected payment methods specified by the user.
  /// If null, all supported tokenization methods will be shown.
  final List<TokenizationMethod>? selectedTokenizationMethods;

  /// The google play merchant id
  final String? googlePayMerchantId;

  /// The parameter to force request the billing address in google pay
  final bool? googlePayRequestBillingAddress;

  /// The parameter to force request the phone number in google pay
  final bool? googlePayRequestPhoneNumber;

  /// The list of card brands in google pay
  final List<String>? googlePayCardBrands;

  /// The environment for google pay
  final String? googlePayEnvironment;

  /// The google play description of the item being purchased.
  String? googlePayItemDescription;

  /// The apple play merchant id
  final String? applePayMerchantId;

  /// The list of fields to be requested in shipping address in apple pay.
  final List<String>? applePayRequiredShippingContactFields;

  /// The list of fields to be requested in billing address in apple pay.
  final List<String>? applePayRequiredBillingContactFields;

  /// The list of card brands in apple pay
  final List<String>? applePayCardBrands;

  /// The apple play description of the item being purchased.
  String? applePayItemDescription;

  /// The atome list of items.
  final List<Item>? atomeItems;

  /// Constructor for creating a [MethodChannelState].
  MethodChannelState({
    this.pkey,
    this.amount,
    this.currency,
    this.methodName,
    this.authUrl,
    this.expectedReturnUrls,
    this.selectedPaymentMethods,
    this.selectedTokenizationMethods,
    this.googlePayMerchantId,
    this.googlePayRequestBillingAddress,
    this.googlePayRequestPhoneNumber,
    this.googlePayCardBrands,
    this.googlePayEnvironment,
    this.googlePayItemDescription,
    this.applePayMerchantId,
    this.applePayRequiredShippingContactFields,
    this.applePayRequiredBillingContactFields,
    this.applePayCardBrands,
    this.applePayItemDescription,
    this.atomeItems,
  });

  /// Creates a copy of the current state while allowing overriding of
  /// specific fields. This is needed since in order to trigger a rebuild on the value notifier level, we need a new instance to be created for non primitive types.
  MethodChannelState copyWith({
    String? pkey,
    int? amount,
    Currency? currency,
    MethodNames? methodName,
    String? authUrl,
    List<String>? expectedReturnUrls,
    List<PaymentMethodName>? selectedPaymentMethods,
    List<TokenizationMethod>? selectedTokenizationMethods,
    String? googlePayMerchantId,
    bool? googlePayRequestBillingAddress,
    bool? googlePayRequestPhoneNumber,
    List<String>? googlePayCardBrands,
    String? googlePayEnvironment,
    String? googlePayItemDescription,
    String? applePayMerchantId,
    List<String>? applePayRequiredBillingContactFields,
    List<String>? applePayRequiredShippingContactFields,
    List<String>? applePayCardBrands,
    String? applePayItemDescription,
    List<Item>? atomeItems,
  }) {
    return MethodChannelState(
      pkey: pkey ?? this.pkey,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      methodName: methodName ?? this.methodName,
      authUrl: authUrl ?? this.authUrl,
      expectedReturnUrls: expectedReturnUrls ?? this.expectedReturnUrls,
      selectedPaymentMethods:
          selectedPaymentMethods ?? this.selectedPaymentMethods,
      selectedTokenizationMethods:
          selectedTokenizationMethods ?? this.selectedTokenizationMethods,
      googlePayMerchantId: googlePayMerchantId ?? this.googlePayMerchantId,
      googlePayRequestBillingAddress:
          googlePayRequestBillingAddress ?? this.googlePayRequestBillingAddress,
      googlePayRequestPhoneNumber:
          googlePayRequestPhoneNumber ?? this.googlePayRequestPhoneNumber,
      googlePayCardBrands: googlePayCardBrands ?? this.googlePayCardBrands,
      googlePayEnvironment: googlePayEnvironment ?? this.googlePayEnvironment,
      googlePayItemDescription:
          googlePayItemDescription ?? this.googlePayItemDescription,
      applePayMerchantId: applePayMerchantId ?? this.applePayMerchantId,
      applePayRequiredBillingContactFields:
          applePayRequiredBillingContactFields ??
              this.applePayRequiredBillingContactFields,
      applePayRequiredShippingContactFields:
          applePayRequiredShippingContactFields ??
              this.applePayRequiredShippingContactFields,
      applePayCardBrands: applePayCardBrands ?? this.applePayCardBrands,
      applePayItemDescription:
          applePayItemDescription ?? this.applePayItemDescription,
      atomeItems: atomeItems ?? this.atomeItems,
    );
  }
}
