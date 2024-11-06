import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart'; // Import this for ValueNotifier
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';

/// The [PaymentMethodSelectorController] manages the state and logic for
/// filtering and retrieving payment methods from Omise API.
class PaymentMethodSelectorController
    extends ValueNotifier<PaymentMethodSelectorState> {
  /// Instance of [OmiseApiService] used to interact with the omise dart package.
  final OmiseApiService omiseApiService;

  /// List of selected payment methods specified by the user.
  /// If null, all supported payment methods will be shown.
  final List<PaymentMethodName>? selectedPaymentMethods;

  /// Constructor for initializing [PaymentMethodSelectorController].
  /// Takes in a required [omiseApiService] and optional [selectedPaymentMethods].
  PaymentMethodSelectorController(
      {required this.omiseApiService, this.selectedPaymentMethods})
      : super(PaymentMethodSelectorState(status: Status.idle));

  /// List of supported payment methods. Add more methods here as needed.
  final supportedPaymentMethods = [
    PaymentMethodName.card,
  ];

  /// Loads the capabilities from Omise API and filters the payment methods
  /// based on the [selectedPaymentMethods] and [supportedPaymentMethods].
  Future<void> loadCapabilities() async {
    try {
      // Set the status to loading while fetching capabilities
      _setValue(value.copyWith(status: Status.loading));

      // Fetch capabilities from Omise API
      final capabilities = await omiseApiService.getCapabilities();
      List<PaymentMethod> filteredMethods = [];

      // Cross-filtering logic to filter available payment methods
      if (selectedPaymentMethods != null) {
        for (var method in capabilities.paymentMethods) {
          if (method.name != PaymentMethodName.unknown &&
              selectedPaymentMethods!.contains(method.name) &&
              supportedPaymentMethods.contains(method.name)) {
            filteredMethods.add(method);
          }
        }
      } else {
        // No user-specified selection, use all supported methods
        for (var method in capabilities.paymentMethods) {
          if (supportedPaymentMethods.contains(method.name)) {
            filteredMethods.add(method);
          }
        }
      }

      // Update the state with the filtered methods and success status
      _setValue(value.copyWith(
          capability: capabilities,
          status: Status.success,
          viewablePaymentMethods: filteredMethods));
    } catch (e) {
      // Handle errors and update the state with an error message
      var error = "";
      log(e.toString());
      if (e is OmiseApiException) {
        error = e.message;
      } else {
        error = e.toString();
      }
      _setValue(value.copyWith(status: Status.error, errorMessage: error));
    }
  }

  /// Internal helper function to update the state of [ValueNotifier].
  void _setValue(PaymentMethodSelectorState state) {
    value = state;
  }
}

/// State class that holds the values for [PaymentMethodSelectorController].
/// Contains the current status, error messages, capabilities, and filtered
/// payment methods that are viewable by the user.
class PaymentMethodSelectorState {
  /// The current status of the controller, such as idle, loading, success, or error.
  final Status status;

  /// Optional error message in case of failure.
  final String? errorMessage;

  /// The capability object fetched from the API, containing available payment methods.
  final Capability? capability;

  /// The list of payment methods filtered and viewable by the user.
  final List<PaymentMethod>? viewablePaymentMethods;

  /// Constructor for creating a [PaymentMethodSelectorState].
  PaymentMethodSelectorState(
      {required this.status,
      this.errorMessage,
      this.capability,
      this.viewablePaymentMethods});

  /// Creates a copy of the current state while allowing overriding of
  /// specific fields. This is needed since in order to trigger a rebuild on the value notifier level, we need a new instance to be created for non primitive types.
  PaymentMethodSelectorState copyWith({
    Status? status,
    String? errorMessage,
    Capability? capability,
    List<PaymentMethod>? viewablePaymentMethods,
  }) {
    return PaymentMethodSelectorState(
        status: status ?? this.status, // Use current value if null
        errorMessage:
            errorMessage ?? this.errorMessage, // Use current value if null
        capability: capability ?? this.capability, // Use current value if null
        viewablePaymentMethods:
            viewablePaymentMethods ?? this.viewablePaymentMethods);
  }
}
