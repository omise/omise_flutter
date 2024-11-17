import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';

class PaymentMethodTileData {
  final PaymentMethodName name;
  final Widget leadingIcon;
  final IconData trailingIcon;
  final VoidCallback onTap;

  PaymentMethodTileData({
    required this.name,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.onTap,
  });
  double get leadingIconHeight {
    switch (name) {
      case PaymentMethodName.card:
        return 30;
      case PaymentMethodName.promptpay:
        return 50;
      default:
        return 50;
    }
  }

  double get leadingIconWidth {
    switch (name) {
      case PaymentMethodName.card:
        return 60;
      case PaymentMethodName.promptpay:
        return 60;
      default:
        return 60;
    }
  }
}
