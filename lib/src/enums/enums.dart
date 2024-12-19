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
  postalCode;
}

enum CustomPaymentMethod {
  mobileBanking("mobile_banking"),
  unknown("unknown");

  final String value;

  // Constructor for the enum
  const CustomPaymentMethod(this.value);
}

extension CustomPaymentMethodNameTitleExtension on CustomPaymentMethod {
  String title({required BuildContext context, OmiseLocale? locale}) {
    switch (this) {
      case CustomPaymentMethod.mobileBanking:
        return Translations.get('mobileBanking', locale, context);
      default:
        return Translations.get('unsupportedPaymentMethod', locale, context);
    }
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
    switch (this) {
      case PaymentMethodName.card:
      case PaymentMethodName.promptpay:
      case PaymentMethodName.mobileBankingBay:
      case PaymentMethodName.mobileBankingBbl:
      case PaymentMethodName.mobileBankingKbank:
      case PaymentMethodName.mobileBankingKtb:
      case PaymentMethodName.mobileBankingOcbc:
      case PaymentMethodName.mobileBankingScb:
        return Translations.get(name, locale, context);
      default:
        return Translations.get('unsupportedPaymentMethod', locale, context);
    }
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
