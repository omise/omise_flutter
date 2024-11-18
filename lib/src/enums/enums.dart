import 'package:omise_dart/omise_dart.dart';

enum Status { idle, loading, success, error }

enum ValidationType {
  cardNumber("Card Number"),
  name("Name"),
  expiryDate("Expiry Date"),
  cvv("CVV"),
  address("Address"),
  city("City"),
  state("State"),
  postalCode("Postal Code");

  // Field to hold the display name
  final String displayName;

  // Constructor for the enum
  const ValidationType(this.displayName);
}

extension PaymentMethodNameTitleExtension on PaymentMethodName {
  String get title {
    switch (this) {
      case PaymentMethodName.card:
        return 'Credit/Debit Card';
      case PaymentMethodName.promptpay:
        return 'PromptPay';
      default:
        return 'Unsupported Payment Method';
    }
  }
}
