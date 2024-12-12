import 'package:flutter/material.dart';
import 'package:omise_flutter/src/models/payment_method.dart';
import 'package:omise_flutter/src/enums/enums.dart';

/// A reusable function for displaying a payment method tile.
///
/// This widget provides a consistent UI representation for payment methods in
/// a list format. It can be used throughout the application wherever a payment
/// method needs to be displayed in a selectable format.
///
/// The tile consists of a leading icon, the name of the payment method as the
/// title, and an optional trailing icon. Tapping the tile can trigger an action
/// defined in the [onTap] callback.
///
/// Parameters:
///
/// - [paymentMethod]: An instance of [PaymentMethodTileData] that contains
///   the information required to display the tile, including:
///   - [name]: The name of the payment method.
///   - [leadingIcon]: The widget to display as the leading icon of the tile.
///   - [trailingIcon]: The icon to display on the right side of the tile.
///   - [onTap]: A callback function that is executed when the tile is tapped.
///
/// Returns:
/// A [ListTile] widget configured with the provided payment method data.
Widget paymentMethodTile({
  required PaymentMethodTileData paymentMethod,
  String? customTitle,
}) {
  return ListTile(
    title: Text(customTitle ?? paymentMethod.name.title),
    leading: SizedBox(
      height: paymentMethod.leadingIconHeight,
      width: paymentMethod.leadingIconWidth,
      child: paymentMethod.leadingIcon,
    ),
    trailing: Icon(paymentMethod.trailingIcon),
    onTap: paymentMethod.onTap,
  );
}
