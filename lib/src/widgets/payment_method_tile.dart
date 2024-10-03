import 'package:flutter/material.dart';
import 'package:omise_flutter/src/models/payment_method.dart';

/// A reusable function for displaying a payment method tile
Widget paymentMethodTile({
  required PaymentMethod paymentMethod,
}) {
  return ListTile(
    title: Text(paymentMethod.name),
    leading: paymentMethod.leadingIcon,
    trailing: Icon(paymentMethod.trailingIcon),
    onTap: paymentMethod.onTap,
  );
}
