import 'dart:async';
import 'dart:developer';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/foundation.dart'; // Import this for ValueNotifier
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_dart/src/exceptions/omise_api_exception.dart';
import 'package:omise_flutter/src/utils/validationUtils.dart';

class CreditCardPaymentMethodController
    extends ValueNotifier<CreditCardPaymentMethodState> {
  /// Instance of [OmiseApiService] used to interact with the omise dart package.
  final OmiseApiService omiseApiService;

  /// Constructor for initializing [CreditCardPaymentMethodController].
  /// Takes in a required [omiseApiService].
  CreditCardPaymentMethodController({required this.omiseApiService})
      : super(CreditCardPaymentMethodState(
            status: Status.idle,
            createTokenRequest: CreateTokenRequest(
                name: "",
                number: "",
                expirationMonth: "",
                expirationYear: "")));

  /// Loads the capabilities from Omise API to get the country.
  Future<void> loadCapabilities() async {
    try {
      // Set the status to loading while fetching capabilities
      _setValue(value.copyWith(status: Status.loading));

      // Fetch capabilities from Omise API
      final capabilities = await omiseApiService.getCapabilities();
      value.createTokenRequest.country = capabilities.country;
      _setValue(value.copyWith(
        capability: capabilities,
        status: Status.success,
      ));
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

  void updateState(CreditCardPaymentMethodState newState) {
    _setValue(newState);
  }

  void setExpiryDate(String expiryDate) {
    if (ValidationUtils.expiryDateRegEx.hasMatch(expiryDate)) {
      // Split the expiryDate into month and year
      final List<String> parts = expiryDate.split('/');
      final String expirationMonth = parts[0]; // MM
      final String expirationYear = parts[1]; // YY

      var newState = value.copyWith();
      newState.createTokenRequest.expirationMonth = expirationMonth;
      newState.createTokenRequest.expirationYear = expirationYear;

      _setValue(newState);
    }
  }

  /// Internal helper function to update the state of [ValueNotifier].
  void _setValue(CreditCardPaymentMethodState state) {
    value = state;
  }
}

/// State class that holds the values for [CreditCardPaymentMethodController].
/// Contains the current status, error messages, capabilities...
class CreditCardPaymentMethodState {
  /// The current status of the controller, such as idle, loading, success, or error.
  final Status status;

  /// Optional error message in case of failure.
  final String? errorMessage;

  /// The capability object fetched from the API, containing available payment methods.
  final Capability? capability;

  CreateTokenRequest createTokenRequest;

  var avsCountries = [
    CountryCode.fromCode("US")!,
    CountryCode.fromCode("CA"),
    CountryCode.fromCode("GB")!
  ];

  bool get shouldShowAddressFields =>
      avsCountries.contains(CountryCode.fromCode(createTokenRequest.country));

  /// Constructor for creating a [CreditCardPaymentMethodState].
  CreditCardPaymentMethodState({
    required this.status,
    this.errorMessage,
    this.capability,
    required this.createTokenRequest,
  });

  /// Creates a copy of the current state while allowing overriding of
  /// specific fields.
  CreditCardPaymentMethodState copyWith({
    Status? status,
    String? errorMessage,
    Capability? capability,
    CreateTokenRequest? createTokenRequest,
  }) {
    return CreditCardPaymentMethodState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        capability: capability ?? this.capability,
        createTokenRequest: createTokenRequest ?? this.createTokenRequest);
  }
}
