import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/translations/translations.dart';

enum Status { idle, loading, success, error }

enum ValidationType {
  cardNumber,
  name,
  expiryDate,
  cvv,
  address,
  city,
  state,
  postalCode,
  phoneNumber,
  email,
  countryCode,
  none;
}

enum CustomPaymentMethod {
  mobileBanking("mobile_banking"),
  installments("installment"),
  googlePay("googlepay"),
  unknown("unknown");

  final String value;

  // Constructor for the enum
  const CustomPaymentMethod(this.value);
}

extension CustomPaymentMethodNameTitleExtension on CustomPaymentMethod {
  String title({required BuildContext context, OmiseLocale? locale}) {
    final translation = Translations.get(name, locale, context);
    return translation == "N/A"
        ? Translations.get('unsupportedPaymentMethod', locale, context)
        : translation;
  }
}

extension CustomPaymentMethodNameExtension on CustomPaymentMethod {
  static CustomPaymentMethod fromString(String? methodName) {
    return CustomPaymentMethod.values.firstWhere(
      (method) => method.value.toLowerCase() == methodName?.toLowerCase(),
      orElse: () => CustomPaymentMethod.unknown,
    );
  }
}

extension PaymentMethodNameTitleExtension on PaymentMethodName {
  String title({required BuildContext context, OmiseLocale? locale}) {
    final translation = Translations.get(name, locale, context);
    return translation == "N/A"
        ? Translations.get('unsupportedPaymentMethod', locale, context)
        : translation;
  }
}

enum OmiseLocale { en, th, ja }

extension OmiseLocaleFromLocaleExtension on OmiseLocale {
  static OmiseLocale fromString(Locale locale) {
    final languageCode = locale.languageCode.toLowerCase();
    final mainCode = languageCode.contains(('_'))
        ? languageCode.split('_')[0]
        : languageCode;
    return OmiseLocale.values.firstWhere(
      (omiseLocale) => omiseLocale.name.toLowerCase() == mainCode.toLowerCase(),
      orElse: () => OmiseLocale.en,
    );
  }
}
