import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';

/// The [MobileBankingController] manages the state and logic for
/// creating a mobile banking source from Omise API.
class MobileBankingController extends ValueNotifier<MobileBankingPageState> {
  /// Instance of [OmiseApiService] used to interact with the omise dart package.
  final OmiseApiService omiseApiService;

  /// Constructor for initializing [MobileBankingController].
  /// Takes in a required [omiseApiService].
  MobileBankingController({
    required this.omiseApiService,
  }) : super(MobileBankingPageState(sourceLoadingStatus: Status.idle));

  void setSourceCreationParams({
    required int amount,
    required Currency currency,
  }) {
    _setValue(value.copyWith(
      amount: amount,
      currency: currency,
    ));
  }

  /// Creates a source based on the collected data from the user.
  Future<void> createSource(PaymentMethodName paymentMethodName) async {
    try {
      // Set the status to loading while creating the token
      _setValue(value.copyWith(sourceLoadingStatus: Status.loading));

      // Create the token using Omise API
      final source = await omiseApiService.createSource(CreateSourceRequest(
          amount: value.amount!,
          currency: value.currency!,
          type: paymentMethodName));

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

  /// Internal helper function to update the state of [ValueNotifier].
  void _setValue(MobileBankingPageState state) {
    value = state;
  }
}

/// State class that holds the values for [MobileBankingController].
class MobileBankingPageState {
  /// The source object received from the API after source creation.
  final Source? source;

  /// The current status of the source creation loading, such as idle, loading, success, or error.
  final Status sourceLoadingStatus;

  /// Optional error message in case capability failure.
  final String? sourceErrorMessage;

  /// The amount used in source creation.
  final int? amount;

  /// The currency used in source creation.
  final Currency? currency;

  /// Constructor for creating a [MobileBankingPageState].
  MobileBankingPageState({
    required this.sourceLoadingStatus,
    this.source,
    this.amount,
    this.currency,
    this.sourceErrorMessage,
  });

  /// Creates a copy of the current state while allowing overriding of
  /// specific fields. This is needed since in order to trigger a rebuild on the value notifier level, we need a new instance to be created for non primitive types.
  MobileBankingPageState copyWith({
    Source? source,
    Status? sourceLoadingStatus,
    int? amount,
    Currency? currency,
    String? sourceErrorMessage,
  }) {
    return MobileBankingPageState(
      source: source ?? this.source,
      sourceLoadingStatus: sourceLoadingStatus ?? this.sourceLoadingStatus,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      sourceErrorMessage: sourceErrorMessage ?? this.sourceErrorMessage,
    );
  }
}
