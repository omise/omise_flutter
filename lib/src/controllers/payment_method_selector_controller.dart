import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/pages/paymentMethods/credit_card_payment_method_page.dart';
import 'package:omise_flutter/src/pages/paymentMethods/select_mobile_banking_payment_method_page.dart';
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
      : super(PaymentMethodSelectorState(
            capabilityLoadingStatus: Status.idle,
            sourceLoadingStatus: Status.idle));

  /// List of supported payment methods. Add more methods here as needed.
  final supportedPaymentMethods = [
    PaymentMethodName.card,
    PaymentMethodName.promptpay,
    PaymentMethodName.mobileBankingBay,
    PaymentMethodName.mobileBankingBbl,
    PaymentMethodName.mobileBankingKbank,
    PaymentMethodName.mobileBankingKtb,
    PaymentMethodName.mobileBankingOcbc,
    PaymentMethodName.mobileBankingScb,
  ];
  Map<PaymentMethodName, PaymentMethodParams> getPaymentMethodsMap(
      {required BuildContext context, String? object}) {
    return {
      PaymentMethodName.card: PaymentMethodParams(
          isNextPage: true,
          function: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreditCardPaymentMethodPage(
                        omiseApiService: omiseApiService,
                        capability: value.capability,
                      )),
            );
          }),
      PaymentMethodName.promptpay: PaymentMethodParams(
          isNextPage: false,
          function: () {
            _setValue(value.copyWith(
                selectedPaymentMethod: PaymentMethodName.promptpay));
            createSource();
          }),
      PaymentMethodName.unknown: PaymentMethodParams(
          isNextPage: true,
          function: () {
            if (object == CustomPaymentMethod.mobileBanking.value) {
              // open mobile banking screen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SelectMobileBankingPaymentMethodPage(
                          mobileBankingPaymentMethods: value
                              .capability!.paymentMethods
                              .where((method) => method.name.value.contains(
                                  CustomPaymentMethod.mobileBanking.value))
                              .toList(),
                          amount: value.amount!,
                          currency: value.currency!,
                          omiseApiService: omiseApiService,
                        )),
              );
            }
          })
    };
  }

  void setSourceCreationParams(
      {required int amount,
      required Currency currency,

      /// The selected payment method should only passed here for testing purposes
      PaymentMethodName? selectedPaymentMethod}) {
    _setValue(value.copyWith(
        amount: amount,
        currency: currency,
        selectedPaymentMethod: selectedPaymentMethod));
  }

  /// Loads the capabilities from Omise API and filters the payment methods
  /// based on the [selectedPaymentMethods] and [supportedPaymentMethods].
  Future<void> loadCapabilities() async {
    try {
      // Set the status to loading while fetching capabilities
      _setValue(value.copyWith(capabilityLoadingStatus: Status.loading));

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

// remove mobile banking methods and replace by a single mobile banking holding all methods
      if (filteredMethods.indexWhere(
            (method) => method.name.value
                .contains(CustomPaymentMethod.mobileBanking.value),
          ) !=
          -1) {
        filteredMethods.add(PaymentMethod(
            object: CustomPaymentMethod.mobileBanking.value,
            name: PaymentMethodName.unknown,
            currencies: [],
            banks: []));
      }

      filteredMethods.removeWhere((method) =>
          method.name.value.contains(CustomPaymentMethod.mobileBanking.value));
      // Update the state with the filtered methods and success status
      _setValue(value.copyWith(
          capability: capabilities,
          capabilityLoadingStatus: Status.success,
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
      _setValue(value.copyWith(
          capabilityLoadingStatus: Status.error,
          capabilityErrorMessage: error));
    }
  }

  /// Creates a source based on the collected data from the user.
  Future<void> createSource() async {
    try {
      // Set the status to loading while creating the token
      _setValue(value.copyWith(sourceLoadingStatus: Status.loading));

      // Create the token using Omise API
      final source = await omiseApiService.createSource(CreateSourceRequest(
          amount: value.amount!,
          currency: value.currency!,
          type: value.selectedPaymentMethod!));

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
  void _setValue(PaymentMethodSelectorState state) {
    value = state;
  }
}

/// State class that holds the values for [PaymentMethodSelectorController].
/// Contains the current status, error messages, capabilities, and filtered
/// payment methods that are viewable by the user.
class PaymentMethodSelectorState {
  /// The current status of the capability loading, such as idle, loading, success, or error.
  final Status capabilityLoadingStatus;

  /// Optional error message in case capability failure.
  final String? capabilityErrorMessage;

  /// The capability object fetched from the API, containing available payment methods.
  final Capability? capability;

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

  /// The payment method selected by the user.
  final PaymentMethodName? selectedPaymentMethod;

  /// The list of payment methods filtered and viewable by the user.
  final List<PaymentMethod>? viewablePaymentMethods;

  /// Constructor for creating a [PaymentMethodSelectorState].
  PaymentMethodSelectorState(
      {required this.capabilityLoadingStatus,
      required this.sourceLoadingStatus,
      this.capabilityErrorMessage,
      this.capability,
      this.source,
      this.amount,
      this.currency,
      this.sourceErrorMessage,
      this.selectedPaymentMethod,
      this.viewablePaymentMethods});

  /// Creates a copy of the current state while allowing overriding of
  /// specific fields. This is needed since in order to trigger a rebuild on the value notifier level, we need a new instance to be created for non primitive types.
  PaymentMethodSelectorState copyWith({
    Status? capabilityLoadingStatus,
    String? capabilityErrorMessage,
    Capability? capability,
    Source? source,
    Status? sourceLoadingStatus,
    int? amount,
    Currency? currency,
    String? sourceErrorMessage,
    PaymentMethodName? selectedPaymentMethod,
    List<PaymentMethod>? viewablePaymentMethods,
  }) {
    return PaymentMethodSelectorState(
      capabilityLoadingStatus: capabilityLoadingStatus ??
          this.capabilityLoadingStatus, // Use current value if null
      capabilityErrorMessage: capabilityErrorMessage ??
          this.capabilityErrorMessage, // Use current value if null
      capability: capability ?? this.capability, // Use current value if null
      source: source ?? this.source,
      sourceLoadingStatus: sourceLoadingStatus ?? this.sourceLoadingStatus,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      sourceErrorMessage: sourceErrorMessage ?? this.sourceErrorMessage,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      viewablePaymentMethods:
          viewablePaymentMethods ?? this.viewablePaymentMethods,
    );
  }
}

class PaymentMethodParams {
  final bool isNextPage;
  final VoidCallback function;

  PaymentMethodParams({
    required this.isNextPage,
    required this.function,
  });
}
