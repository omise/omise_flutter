import 'package:flutter/material.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/translations/translations.dart';

class ValidationUtils {
  static String? validateCardNumber(
      {required BuildContext context, String? value, OmiseLocale? locale}) {
    if (value == null || value.isEmpty) {
      return Translations.get('cardNumberRequired', locale, context);
    }

    // Remove any spaces or dashes if present in the card number
    value = value.replaceAll(RegExp(r'\s+|-'), '');

    // Check if the string contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return Translations.get('invalidCardNumber', locale, context);
    }

    if (!_isValidLuhn(value)) {
      return Translations.get('invalidCardNumber', locale, context);
    }

    return null;
  }

  static bool _isValidLuhn(String cardNumber) {
    int sum = 0;
    bool alternate = false;

    // Loop through card number digits from right to left
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int n = int.parse(cardNumber[i]);

      if (alternate) {
        n *= 2;
        if (n > 9) {
          n -= 9;
        }
      }

      sum += n;
      alternate = !alternate;
    }

    // If the sum is divisible by 10, the card number is valid
    return (sum % 10 == 0);
  }

  static String? validateName(String? value,
      {required String fieldName,
      required BuildContext context,
      OmiseLocale? locale}) {
    final currentLocale = Translations.detectLocale(locale, context);
    if (value == null || value.trim().isEmpty) {
      return '$fieldName${currentLocale == OmiseLocale.en ? ' ' : ''}${Translations.get('isRequired', locale, context)}';
    }
    return null;
  }

  static final expiryDateRegEx = RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$');
  static String? validateExpiryDate(
      {required BuildContext context, OmiseLocale? locale, String? value}) {
    if (value == null || value.isEmpty) {
      return Translations.get('expiryDateRequired', locale, context);
    } else {
      // Expiry date validation logic (MM/YY format)
      if (!expiryDateRegEx.hasMatch(value)) {
        return Translations.get('expiryFormat', locale, context);
      }
    }
    return null;
  }

  static String? validateCVV(
      {required BuildContext context, OmiseLocale? locale, String? value}) {
    if (value == null || value.isEmpty) {
      return Translations.get('cvvRequired', locale, context);
    }

    // Check if the string contains only digits
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return Translations.get('onlyDigits', locale, context);
    }

    // Validate length (3 digits for most cards, 4 digits for AMEX)
    if (value.length != 3 && value.length != 4) {
      return Translations.get('cvvDigits', locale, context);
    }

    return null; // CVV is valid
  }

  static String? validatePhoneNumber(
      {required BuildContext context,
      OmiseLocale? locale,
      String? phoneNumber}) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return Translations.get('invalidPhoneNumber', locale, context);
    }

    // Allow numbers that:
    // - Start with `+`
    // - Contain only digits otherwise
    final RegExp phoneRegExp = RegExp(r'^\+?\d+$');

    if (!phoneRegExp.hasMatch(phoneNumber)) {
      return Translations.get('invalidPhoneNumber', locale, context);
    }

    return null; // Valid phone number
  }

  static String? validateEmail(
      {required BuildContext context, OmiseLocale? locale, String? email}) {
    if (email == null || email.isEmpty) {
      return 'Invalid email'; // There is no text actually displayed for the user when the email is invalid, the button is disabled so no need for translation.
    }

    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegExp.hasMatch(email)) {
      return 'Invalid email';
    }

    return null; // Valid email
  }

  static String? validateInput(
      {required ValidationType validationType,
      required BuildContext context,
      OmiseLocale? locale,
      String? value}) {
    switch (validationType) {
      case ValidationType.cardNumber:
        return validateCardNumber(
            value: value, context: context, locale: locale);
      case ValidationType.name:
      case ValidationType.address:
      case ValidationType.city:
      case ValidationType.state:
      case ValidationType.postalCode:
        return validateName(value,
            fieldName: Translations.get(
              validationType.name,
              locale,
              context,
            ),
            locale: locale,
            context: context);
      case ValidationType.expiryDate:
        return validateExpiryDate(
            value: value, locale: locale, context: context);
      case ValidationType.cvv:
        return validateCVV(value: value, locale: locale, context: context);
      case ValidationType.phoneNumber:
        return validatePhoneNumber(
            phoneNumber: value, locale: locale, context: context);
      case ValidationType.email:
        return validateEmail(email: value, locale: locale, context: context);
      case ValidationType.none:
        return null;
    }
  }
}
