import 'package:flutter/material.dart';
import 'package:omise_flutter/src/models/payment_method.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:omise_flutter/src/utils/payment_utils.dart';

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
Widget paymentMethodTile(
    {required PaymentMethodTileData paymentMethod,
    required BuildContext context,
    String? customTitle,
    OmiseLocale? locale}) {
  String? footer() {
    if (PaymentUtils.aliPayPartners.contains(paymentMethod.name)) {
      return Translations.get('aliPayPartnerFooter', locale, context);
    }
    if (PaymentUtils.grabPartners.contains(paymentMethod.name)) {
      return Translations.get('grabPayFooter', locale, context);
    }
    return null;
  }

  final footerText = footer();
  return ListTile(
    title: Text(customTitle ??
        paymentMethod.name.title(context: context, locale: locale)),
    subtitle: footerText != null ? Text(footerText) : null,
    leading: SizedBox(
      height: paymentMethod.leadingIconHeight,
      width: paymentMethod.leadingIconWidth,
      child: paymentMethod.leadingIcon,
    ),
    trailing: Icon(paymentMethod.trailingIcon),
    onTap: paymentMethod.onTap,
  );
}
