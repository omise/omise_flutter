import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';

/// The [AtomeController] manages the state and logic for
/// creating a mobile banking source from Omise API.
class AtomeController extends ValueNotifier<AtomePageState> {
  /// Instance of [OmiseApiService] used to interact with the omise dart package.
  final OmiseApiService omiseApiService;

  /// Constructor for initializing [AtomeController].
  /// Takes in a required [omiseApiService].
  AtomeController({
    required this.omiseApiService,
  }) : super(AtomePageState(
            sourceLoadingStatus: Status.idle,
            shippingSameAsBilling: true,
            textFieldValidityStatuses: {}));

  void setSourceCreationParams({
    required int amount,
    required Currency currency,
    required List<Item> items,
  }) {
    _setValue(value.copyWith(
        createSourceRequest: CreateSourceRequest(
            amount: amount,
            currency: currency,
            type: PaymentMethodName.atome,
            shipping: ShippingAddress(),
            billing: BillingAddress(),
            items: items)));
  }

  void setShippingSameAsBilling(bool? sameAsShipping) {
    final currentMap = value.textFieldValidityStatuses;
    if (sameAsShipping == false) {
      // remove any keys that were used to validate billing

      currentMap.removeWhere((key, value) {
        return key.toLowerCase().contains('billing');
      });
    }
    _setValue(value.copyWith(
        shippingSameAsBilling: sameAsShipping,
        textFieldValidityStatuses: currentMap));
  }

  /// Updates the state with a new [CreditCardPaymentMethodState].
  void updateState(AtomePageState newState) {
    _setValue(newState);
  }

  /// Creates a source based on the collected data from the user.
  Future<void> createSource() async {
    try {
      // Set the status to loading while creating the token
      _setValue(value.copyWith(sourceLoadingStatus: Status.loading));

      // Create the source using Omise API
      if (value.shippingSameAsBilling) {
        final createSourceRequest = value.createSourceRequest;
        // set the billing same as shipping
        createSourceRequest!.billing =
            BillingAddress.fromJson(createSourceRequest.shipping!.toJson());
        _setValue(value.copyWith(createSourceRequest: createSourceRequest));
      }
      final source =
          await omiseApiService.createSource(value.createSourceRequest!);

      _setValue(value.copyWith(
        source: source,
        sourceLoadingStatus: Status.success,
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
          sourceLoadingStatus: Status.error, sourceErrorMessage: error));
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
  void _setValue(AtomePageState state) {
    value = state;
  }
}

/// State class that holds the values for [AtomeController].
class AtomePageState {
  /// The source object received from the API after source creation.
  final Source? source;

  /// The current status of the source creation loading, such as idle, loading, success, or error.
  final Status sourceLoadingStatus;

  /// Optional error message in case capability failure.
  final String? sourceErrorMessage;

  /// The source request
  final CreateSourceRequest? createSourceRequest;

  final bool shippingSameAsBilling;

  /// Map to hold the validity status of text fields.
  final Map<String, bool> textFieldValidityStatuses;

  /// Constructor for creating a [AtomePageState].
  AtomePageState({
    required this.sourceLoadingStatus,
    required this.shippingSameAsBilling,
    required this.textFieldValidityStatuses,
    this.createSourceRequest,
    this.source,
    this.sourceErrorMessage,
  });

  /// Creates a copy of the current state while allowing overriding of
  /// specific fields. This is needed since in order to trigger a rebuild on the value notifier level, we need a new instance to be created for non primitive types.
  AtomePageState copyWith({
    Source? source,
    Status? sourceLoadingStatus,
    int? amount,
    Currency? currency,
    String? sourceErrorMessage,
    bool? shippingSameAsBilling,
    CreateSourceRequest? createSourceRequest,
    Map<String, bool>? textFieldValidityStatuses,
  }) {
    return AtomePageState(
        source: source ?? this.source,
        sourceLoadingStatus: sourceLoadingStatus ?? this.sourceLoadingStatus,
        sourceErrorMessage: sourceErrorMessage ?? this.sourceErrorMessage,
        shippingSameAsBilling:
            shippingSameAsBilling ?? this.shippingSameAsBilling,
        createSourceRequest: createSourceRequest ?? this.createSourceRequest,
        textFieldValidityStatuses:
            textFieldValidityStatuses ?? this.textFieldValidityStatuses);
  }
}
