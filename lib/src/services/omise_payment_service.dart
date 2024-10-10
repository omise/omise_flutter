import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/pages/select_payment_method_page.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';

/// [OmisePayment] is the main class that users should interact with
/// to utilize processing payments
/// using the Omise API. It initializes the necessary
/// services and provides a way to select payment methods.
class OmisePayment {
  /// Creates an instance of [OmisePayment].
  ///
  /// Requires a [publicKey] for authenticating requests to the Omise API.
  ///
  /// An optional [enableDebug] parameter can be set to enable debugging
  /// logs for API requests and responses.
  OmisePayment({
    required String publicKey,
    bool? enableDebug,
  }) {
    // Initialize the OmiseApiService with the provided public key
    // and debug settings.
    omiseApiService = OmiseApiService(
      publicKey: publicKey,
      enableDebug: enableDebug,
    );
  }

  /// The instance of [OmiseApiService] used for making API calls
  /// related to payments.
  late OmiseApiService omiseApiService;

  /// Creates and returns a [SelectPaymentMethodPage] widget.
  ///
  /// This method allows the user to select payment methods. It takes an optional
  /// [selectedPaymentMethods] parameter, which is a list of payment method names
  /// that the merchant wants to display.
  ///
  /// Returns a [Widget] that represents the payment method selection page.
  Widget selectPaymentMethod({
    List<PaymentMethodName>? selectedPaymentMethods,
  }) {
    return SelectPaymentMethodPage(
      omiseApiService: omiseApiService, // Pass the Omise API service
      selectedPaymentMethods:
          selectedPaymentMethods, // Pass any pre-selected methods
    );
  }
}
