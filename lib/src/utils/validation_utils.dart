import 'package:omise_flutter/src/enums/enums.dart';

class ValidationUtils {
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }

    // Remove any spaces or dashes if present in the card number
    value = value.replaceAll(RegExp(r'\s+|-'), '');

    // Check if the string contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Invalid card number';
    }

    if (!_isValidLuhn(value)) {
      return 'Invalid card number';
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

  static String? validateName(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? "Name"} is required';
    }
    return null;
  }

  static final expiryDateRegEx = RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$');
  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    } else {
      // Expiry date validation logic (MM/YY format)
      if (!expiryDateRegEx.hasMatch(value)) {
        return 'MM/YY format';
      }
    }
    return null;
  }

  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }

    // Check if the string contains only digits
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Only digits are allowed';
    }

    // Validate length (3 digits for most cards, 4 digits for AMEX)
    if (value.length != 3 && value.length != 4) {
      return 'CVV must be 3 or 4 digits';
    }

    return null; // CVV is valid
  }

  static String? validateInput(ValidationType validationType, String? value) {
    switch (validationType) {
      case ValidationType.cardNumber:
        return validateCardNumber(value);
      case ValidationType.name:
      case ValidationType.address:
      case ValidationType.city:
      case ValidationType.state:
      case ValidationType.postalCode:
        return validateName(value, fieldName: validationType.displayName);
      case ValidationType.expiryDate:
        return validateExpiryDate(value);
      case ValidationType.cvv:
        return validateCVV(value);
      default:
        return null;
    }
  }
}
