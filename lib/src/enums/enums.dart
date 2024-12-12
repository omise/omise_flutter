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

enum CustomPaymentMethod {
  mobileBanking("mobile_banking"),
  unknown("unknown");

  final String value;

  // Constructor for the enum
  const CustomPaymentMethod(this.value);
}

extension CustomPaymentMethodNameTitleExtension on CustomPaymentMethod {
  String get title {
    switch (this) {
      case CustomPaymentMethod.mobileBanking:
        return 'Mobile Banking';
      default:
        return 'Unsupported Payment Method';
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
  String get title {
    switch (this) {
      case PaymentMethodName.card:
        return 'Credit/Debit Card';
      case PaymentMethodName.promptpay:
        return 'PromptPay';
      case PaymentMethodName.mobileBankingBay:
        return "Krungsri (KMA)";
      case PaymentMethodName.mobileBankingBbl:
        return "Bangkok Bank";
      case PaymentMethodName.mobileBankingKbank:
        return "KBank (K PLUS)";
      case PaymentMethodName.mobileBankingKtb:
        return "Krungthai NEXT";
      case PaymentMethodName.mobileBankingOcbc:
        return "OCBC Digital";
      case PaymentMethodName.mobileBankingScb:
        return "SCB (SCB Easy)";
      default:
        return 'Unsupported Payment Method';
    }
  }
}
