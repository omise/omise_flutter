import 'dart:async';
import 'dart:developer';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/foundation.dart'; // Import this for ValueNotifier
import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/utils/validation_utils.dart';

/// Controller for managing credit card payment method.
///
/// This class is responsible for handling the state and interactions
/// related to credit card payments, including loading capabilities,
/// creating tokens, and validating input fields. It extends
/// [ValueNotifier] to allow for state management and UI updates.
class CreditCardController extends ValueNotifier<CreditCardPaymentMethodState> {
  /// Instance of [OmiseApiService] used to interact with the Omise Dart package.
  final OmiseApiService omiseApiService;

  /// Constructor for initializing [CreditCardController].
  ///
  /// Takes in a required [omiseApiService] to facilitate API interactions.
  CreditCardController({required this.omiseApiService})
      : super(CreditCardPaymentMethodState(
            capabilityLoadingStatus: Status.idle,
            tokenAndSourceLoadingStatus: Status.idle,
            textFieldValidityStatuses: {},
            createTokenRequest: CreateTokenRequest(
                name: "",
                number: "",
                expirationMonth: "",
                expirationYear: "")));

  /// Loads the capabilities from the Omise API to get the country.
  ///
  /// Optionally accepts a [Capability] parameter to use predefined capabilities.
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

  void setInstallmentsSourceParameters({
    PaymentMethodName? paymentMethod,
    Currency? currency,
    int? amount,
    int? term,
  }) {
    _setValue(value.copyWith(
        paymentMethod: paymentMethod,
        amount: amount,
        currency: currency,
        term: term));
  }

  /// Creates a token and a source based on the collected data from the user.
  Future<void> createSourceAndToken() async {
    try {
      // Set the status to loading while creating the token
      _setValue(value.copyWith(tokenAndSourceLoadingStatus: Status.loading));
      // Create the token using Omise API
      final token = await omiseApiService.createToken(value.createTokenRequest);
      if (value.paymentMethod != null) {
        final source = await omiseApiService.createSource(CreateSourceRequest(
            amount: value.amount!,
            currency: value.currency!,
            type: value.paymentMethod!,
            installmentTerm: value.term));
        _setValue(value.copyWith(source: source));
      }
      _setValue(value.copyWith(
        token: token,
        tokenAndSourceLoadingStatus: Status.success,
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
          tokenAndSourceLoadingStatus: Status.error,
          tokenAndSourceErrorMessage: error));
    }
  }

  /// Updates the state with a new [CreditCardPaymentMethodState].
  void updateState(CreditCardPaymentMethodState newState) {
    _setValue(newState);
  }

  /// Sets the expiration date for the credit card.
  ///
  /// Parses the given [expiryDate] in the format MM/YY and updates
  /// the corresponding fields in the create token request.
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

  /// Updates the validity status of a text field.
  ///
  /// Accepts a [key] representing the text field and a [validField]
  /// indicating whether the field is valid or not.
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

/// State class that holds the values for [CreditCardController].
///
/// Contains the current loading status, error messages, capabilities,
/// and the create token request data.
class CreditCardPaymentMethodState {
  /// The current status of the capability API call, such as idle, loading, success, or error.
  final Status capabilityLoadingStatus;

  /// Optional error message in case of failure.
  final String? capabilityErrorMessage;

  /// The current status of the token API call, such as idle, loading, success, or error.
  final Status tokenAndSourceLoadingStatus;

  /// Optional error message in case of failure.
  final String? tokenAndSourceErrorMessage;

  /// The capability object fetched from the API, containing available payment methods.
  final Capability? capability;

  /// Map to hold the validity status of text fields.
  final Map<String, bool> textFieldValidityStatuses;

  /// The token object fetched from the API.
  final Token? token;

  /// The payment method selected if coming from wlb installments screen
  final PaymentMethodName? paymentMethod;

  /// The currency if coming from wlb installments screen
  final Currency? currency;

  /// The amount if coming from wlb installments screen
  final int? amount;

  /// The term if coming from wlb installments screen
  final int? term;

  final Source? source;

  /// Request object to create a token.
  CreateTokenRequest createTokenRequest;

  /// List of countries that support AVS (Address Verification Service).
  final avsCountries = [
    CountryCode.fromCode("US")!,
    CountryCode.fromCode("CA"),
    CountryCode.fromCode("GB")!
  ];

  /// Number of fields required for AVS and non-AVS countries.
  final int avsFields = 8;
  final int nonAvsFields = 4;

  /// Gets the number of fields required based on the country.
  int get numberOfFields {
    final baseFields =
        avsCountries.contains(CountryCode.fromCode(createTokenRequest.country))
            ? avsFields
            : nonAvsFields;

    return isLoanCard ? baseFields - 2 : baseFields;
  }

  /// Determines whether to show address fields based on the country.
  bool get shouldShowAddressFields =>
      avsCountries.contains(CountryCode.fromCode(createTokenRequest.country));

  bool get isLoanCard {
    // The bins cannot be put into env as flutter packages are published as source code and not compiled
    // so the merchant will have to configure the load card on runtime if not embedded as plain text.
    final bins = ["478445", "478449"];
    return bins
        .any((bin) => createTokenRequest.number?.startsWith(bin) ?? false);
  }

  /// Checks if the form is valid based on text field validity statuses.
  bool get isFormValid =>
      textFieldValidityStatuses.values.length == numberOfFields &&
      textFieldValidityStatuses.values.isNotEmpty &&
      !textFieldValidityStatuses.values.contains(false);

  /// Constructor for creating a [CreditCardPaymentMethodState].
  CreditCardPaymentMethodState({
    required this.capabilityLoadingStatus,
    required this.tokenAndSourceLoadingStatus,
    required this.createTokenRequest,
    required this.textFieldValidityStatuses,
    this.capabilityErrorMessage,
    this.tokenAndSourceErrorMessage,
    this.capability,
    this.token,
    this.paymentMethod,
    this.currency,
    this.amount,
    this.term,
    this.source,
  });

  /// Creates a copy of the current state while allowing overriding of specific fields.
  CreditCardPaymentMethodState copyWith({
    Status? capabilityLoadingStatus,
    String? capabilityErrorMessage,
    Status? tokenAndSourceLoadingStatus,
    String? tokenAndSourceErrorMessage,
    Capability? capability,
    CreateTokenRequest? createTokenRequest,
    Token? token,
    Map<String, bool>? textFieldValidityStatuses,
    PaymentMethodName? paymentMethod,
    Currency? currency,
    int? amount,
    int? term,
    Source? source,
  }) {
    return CreditCardPaymentMethodState(
      capabilityLoadingStatus:
          capabilityLoadingStatus ?? this.capabilityLoadingStatus,
      tokenAndSourceLoadingStatus:
          tokenAndSourceLoadingStatus ?? this.tokenAndSourceLoadingStatus,
      tokenAndSourceErrorMessage:
          tokenAndSourceErrorMessage ?? this.tokenAndSourceErrorMessage,
      capabilityErrorMessage:
          capabilityErrorMessage ?? this.capabilityErrorMessage,
      capability: capability ?? this.capability,
      createTokenRequest: createTokenRequest ?? this.createTokenRequest,
      token: token ?? this.token,
      textFieldValidityStatuses:
          textFieldValidityStatuses ?? this.textFieldValidityStatuses,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      term: term ?? this.term,
      source: source ?? this.source,
    );
  }
}
