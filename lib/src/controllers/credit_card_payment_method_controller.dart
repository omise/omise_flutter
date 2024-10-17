import 'dart:async';
import 'dart:developer';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/foundation.dart'; // Import this for ValueNotifier
import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/utils/validation_utils.dart';

class CreditCardPaymentMethodController
    extends ValueNotifier<CreditCardPaymentMethodState> {
  /// Instance of [OmiseApiService] used to interact with the omise dart package.
  final OmiseApiService omiseApiService;

  /// Constructor for initializing [CreditCardPaymentMethodController].
  /// Takes in a required [omiseApiService].
  CreditCardPaymentMethodController({required this.omiseApiService})
      : super(CreditCardPaymentMethodState(
            capabilityLoadingStatus: Status.idle,
            tokenLoadingStatus: Status.idle,
            textFieldValidityStatuses: {},
            createTokenRequest: CreateTokenRequest(
                name: "",
                number: "",
                expirationMonth: "",
                expirationYear: "")));

  /// Loads the capabilities from Omise API to get the country.
  Future<void> loadCapabilities({Capability? capability}) async {
    try {
      // Set the status to loading while fetching capabilities
      _setValue(value.copyWith(capabilityLoadingStatus: Status.loading));

      // Fetch capabilities from Omise API
      final capabilities =
          capability ?? await omiseApiService.getCapabilities();
      value.createTokenRequest.country = capabilities.country;
      _setValue(value.copyWith(
        capability: capabilities,
        capabilityLoadingStatus: Status.success,
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
      _setValue(value.copyWith(
          capabilityLoadingStatus: Status.error,
          capabilityErrorMessage: error));
    }
  }

  /// Creates a token based on the collected data from the user.
  Future<void> createToken() async {
    try {
      // Set the status to loading while fetching capabilities
      _setValue(value.copyWith(tokenLoadingStatus: Status.loading));
      // Create the token using Omise API
      final token = await omiseApiService.createToken(value.createTokenRequest);
      _setValue(value.copyWith(
        token: token,
        tokenLoadingStatus: Status.success,
      ));
    } catch (e) {
      // Handle errors and update the state with an error message
      var error = "";
      log(e.toString());
      if (e is OmiseApiException) {
        error = e.response?.message ?? e.message;
      } else {
        error = e.toString();
      }
      _setValue(value.copyWith(
          tokenLoadingStatus: Status.error, tokenErrorMessage: error));
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

  void setTextFieldValidityStatuses(String key, bool validField) {
    var newMap = value.textFieldValidityStatuses;
    newMap[key] = validField;
    var newState = value.copyWith(textFieldValidityStatuses: newMap);
    _setValue(newState);
  }

  /// Internal helper function to update the state of [ValueNotifier].
  void _setValue(CreditCardPaymentMethodState state) {
    value = state;
  }
}

/// State class that holds the values for [CreditCardPaymentMethodController].
/// Contains the current status, error messages, capabilities...
class CreditCardPaymentMethodState {
  /// The current status of the capability api  call, such as idle, loading, success, or error.
  final Status capabilityLoadingStatus;

  /// Optional error message in case of failure.
  final String? capabilityErrorMessage;

  /// The current status of the token api call, such as idle, loading, success, or error.
  final Status tokenLoadingStatus;

  /// Optional error message in case of failure.
  final String? tokenErrorMessage;

  /// The capability object fetched from the API, containing available payment methods.
  final Capability? capability;
  final Map<String, bool> textFieldValidityStatuses;

  /// The token object fetched from the API.
  final Token? token;

  CreateTokenRequest createTokenRequest;

  final avsCountries = [
    CountryCode.fromCode("US")!,
    CountryCode.fromCode("CA"),
    CountryCode.fromCode("GB")!
  ];

  final int avsFields = 8;
  final int nonAvsFields = 4;
  int get numberOfFields =>
      avsCountries.contains(CountryCode.fromCode(createTokenRequest.country))
          ? avsFields
          : nonAvsFields;
  bool get shouldShowAddressFields =>
      avsCountries.contains(CountryCode.fromCode(createTokenRequest.country));
  bool get isFormValid =>
      textFieldValidityStatuses.values.length == numberOfFields &&
      textFieldValidityStatuses.values.isNotEmpty &&
      !textFieldValidityStatuses.values.contains(false);

  /// Constructor for creating a [CreditCardPaymentMethodState].
  CreditCardPaymentMethodState({
    required this.capabilityLoadingStatus,
    required this.tokenLoadingStatus,
    required this.createTokenRequest,
    required this.textFieldValidityStatuses,
    this.capabilityErrorMessage,
    this.tokenErrorMessage,
    this.capability,
    this.token,
  });

  /// Creates a copy of the current state while allowing overriding of
  /// specific fields.
  CreditCardPaymentMethodState copyWith({
    Status? capabilityLoadingStatus,
    String? capabilityErrorMessage,
    Status? tokenLoadingStatus,
    String? tokenErrorMessage,
    Capability? capability,
    CreateTokenRequest? createTokenRequest,
    Token? token,
    Map<String, bool>? textFieldValidityStatuses,
  }) {
    return CreditCardPaymentMethodState(
      capabilityLoadingStatus:
          capabilityLoadingStatus ?? this.capabilityLoadingStatus,
      tokenLoadingStatus: tokenLoadingStatus ?? this.tokenLoadingStatus,
      tokenErrorMessage: tokenErrorMessage ?? this.tokenErrorMessage,
      capabilityErrorMessage:
          capabilityErrorMessage ?? this.capabilityErrorMessage,
      capability: capability ?? this.capability,
      createTokenRequest: createTokenRequest ?? this.createTokenRequest,
      token: token ?? this.token,
      textFieldValidityStatuses:
          textFieldValidityStatuses ?? this.textFieldValidityStatuses,
    );
  }
}
