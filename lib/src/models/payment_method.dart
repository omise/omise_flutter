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
}
