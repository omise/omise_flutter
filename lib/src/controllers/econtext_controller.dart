import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';

/// The [EcontextController] manages the state and logic for
/// creating a mobile banking source from Omise API.
class EcontextController extends ValueNotifier<EcontextPageState> {
  /// Instance of [OmiseApiService] used to interact with the omise dart package.
  final OmiseApiService omiseApiService;

  /// Constructor for initializing [EcontextController].
  /// Takes in a required [omiseApiService].
  EcontextController({
    required this.omiseApiService,
  }) : super(EcontextPageState(
            sourceLoadingStatus: Status.idle, textFieldValidityStatuses: {}));

  void setSourceCreationParams({
    required int amount,
    required Currency currency,
  }) {
    _setValue(value.copyWith(
        createSourceRequest: CreateSourceRequest(
      amount: amount,
      currency: currency,
      type: PaymentMethodName.econtext,
    )));
  }

  /// Updates the state with a new [EcontextPageState].
  void updateState(EcontextPageState newState) {
    _setValue(newState);
  }

  /// Creates a source based on the collected data from the user.
  Future<void> createSource() async {
    try {
      // Set the status to loading while creating the token
      _setValue(value.copyWith(sourceLoadingStatus: Status.loading));

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
  void _setValue(EcontextPageState state) {
    value = state;
  }
}

/// State class that holds the values for [EcontextController].
class EcontextPageState {
  /// The source object received from the API after source creation.
  final Source? source;

  /// The current status of the source creation loading, such as idle, loading, success, or error.
  final Status sourceLoadingStatus;

  /// Optional error message in case capability failure.
  final String? sourceErrorMessage;

  /// The source request
  final CreateSourceRequest? createSourceRequest;

  /// Map to hold the validity status of text fields.
  final Map<String, bool> textFieldValidityStatuses;

  /// Constructor for creating a [EcontextPageState].
  EcontextPageState({
    required this.sourceLoadingStatus,
    required this.textFieldValidityStatuses,
    this.createSourceRequest,
    this.source,
    this.sourceErrorMessage,
  });

  /// Creates a copy of the current state while allowing overriding of
  /// specific fields. This is needed since in order to trigger a rebuild on the value notifier level, we need a new instance to be created for non primitive types.
  EcontextPageState copyWith({
    Source? source,
    Status? sourceLoadingStatus,
    int? amount,
    Currency? currency,
    String? sourceErrorMessage,
    bool? shippingSameAsBilling,
    CreateSourceRequest? createSourceRequest,
    Map<String, bool>? textFieldValidityStatuses,
  }) {
    return EcontextPageState(
        source: source ?? this.source,
        sourceLoadingStatus: sourceLoadingStatus ?? this.sourceLoadingStatus,
        sourceErrorMessage: sourceErrorMessage ?? this.sourceErrorMessage,
        createSourceRequest: createSourceRequest ?? this.createSourceRequest,
        textFieldValidityStatuses:
            textFieldValidityStatuses ?? this.textFieldValidityStatuses);
  }
}
