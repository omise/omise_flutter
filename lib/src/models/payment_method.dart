import 'package:flutter/material.dart';

class PaymentMethod {
  final String name;
  final Image leadingIcon;
  final IconData trailingIcon;
  final VoidCallback onTap;

  PaymentMethod({
    required this.name,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.onTap,
  });
}
