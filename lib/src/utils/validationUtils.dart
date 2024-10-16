import 'package:omise_flutter/src/enums/enums.dart';

class ValidationUtils {
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    } else if (value.length != 16) {
      return 'Card number must be 16 digits';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    } else if (value.length < 3) {
      return 'Name must be at least 3 characters';
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
        return 'Expiry date must be in MM/YY format';
      }
    }
    return null;
  }

  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    } else if (value.length != 3) {
      return 'CVV must be 3 digits';
    }
    return null;
  }

  static String? validateInput(ValidationType validationType, String? value) {
    switch (validationType) {
      case ValidationType.cardNumber:
        return validateCardNumber(value);
      case ValidationType.name:
        return validateName(value);
      case ValidationType.expiryDate:
        return validateExpiryDate(value);
      case ValidationType.cvv:
        return validateCVV(value);
      default:
        return null;
    }
  }
}
