import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/pages/paymentMethods/credit_card_page.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';

/// The [InstallmentsController] manages the state and logic for
/// creating a mobile banking source from Omise API.
class InstallmentsController extends ValueNotifier<InstallmentsPageState> {
  /// Instance of [OmiseApiService] used to interact with the omise dart package.
  final OmiseApiService omiseApiService;

  /// Constructor for initializing [InstallmentsController].
  /// Takes in a required [omiseApiService].
  InstallmentsController({
    required this.omiseApiService,
  }) : super(InstallmentsPageState(sourceLoadingStatus: Status.idle));

  final Map<PaymentMethodName, double> minimumInstallmentAmountPerType = {
    PaymentMethodName.installmentBay: 50000,
    PaymentMethodName.installmentWlbBay: 50000,
    PaymentMethodName.installmentFirstChoice: 30000,
    PaymentMethodName.installmentWlbFirstChoice: 30000,
    PaymentMethodName.installmentBbl: 50000,
    PaymentMethodName.installmentWlbBbl: 50000,
    PaymentMethodName.installmentMbb: 8333,
    PaymentMethodName.installmentKtc: 30000,
    PaymentMethodName.installmentWlbKtc: 30000,
    PaymentMethodName.installmentKbank: 30000,
    PaymentMethodName.installmentWlbKbank: 30000,
    PaymentMethodName.installmentScb: 50000,
    PaymentMethodName.installmentWlbScb: 50000,
    PaymentMethodName.installmentTtb: 50000,
    PaymentMethodName.installmentWlbTtb: 50000,
    PaymentMethodName.installmentUob: 50000,
    PaymentMethodName.installmentWlbUob: 50000,
  };

  final Map<PaymentMethodName, double> interestRatePerType = {
    PaymentMethodName.installmentBay: 0.0074,
    PaymentMethodName.installmentWlbBay: 0.0074,
    PaymentMethodName.installmentFirstChoice: 0.0116,
    PaymentMethodName.installmentWlbFirstChoice: 0.0116,
    PaymentMethodName.installmentBbl: 0.0074,
    PaymentMethodName.installmentWlbBbl: 0.0074,
    PaymentMethodName.installmentMbb: 0.0,
    PaymentMethodName.installmentKtc: 0.0074,
    PaymentMethodName.installmentWlbKtc: 0.0074,
    PaymentMethodName.installmentKbank: 0.0065,
    PaymentMethodName.installmentWlbKbank: 0.0065,
    PaymentMethodName.installmentScb: 0.0074,
    PaymentMethodName.installmentWlbScb: 0.0074,
    PaymentMethodName.installmentTtb: 0.008,
    PaymentMethodName.installmentWlbTtb: 0.008,
    PaymentMethodName.installmentUob: 0.0064,
    PaymentMethodName.installmentWlbUob: 0.0064,
  };

  void setSourceCreationParams({
    required int amount,
    required Currency currency,
    required PaymentMethodName paymentMethod,
    required Capability capability,
    required List<int> terms,
  }) {
    // filter the terms based on the final calculated amount
    final minimumAmount = minimumInstallmentAmountPerType[paymentMethod];

    final zeroInterestInstallments = capability.zeroInterestInstallments;
    terms.removeWhere((term) {
      var interestAmount = 0.0;
      if (!zeroInterestInstallments) {
        final rate = interestRatePerType[paymentMethod] ?? 0;
        interestAmount = amount * rate;
      }
      final installmentAmountPerMonth = (amount + interestAmount) / term;
      final isTermValid =
          minimumAmount == null || installmentAmountPerMonth >= minimumAmount;
      return !isTermValid;
    });
    _setValue(value.copyWith(
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
        capability: capability,
        terms: terms));
  }

  /// Creates a source based on the collected data from the user.
  Future<void> processInstallment(int term, BuildContext context) async {
    try {
      // if wlb installment then open the credit card page
      if (value.paymentMethod?.value.contains('_wlb_') == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CreditCardPage(
                    omiseApiService: omiseApiService,
                    capability: value.capability!,
                    amount: value.amount,
                    currency: value.currency,
                    paymentMethod: value.paymentMethod,
                    locale: value.locale,
                    term: term,
                  )),
        );
        return;
      }
      // Set the status to loading while creating the token
      _setValue(value.copyWith(sourceLoadingStatus: Status.loading));

      // Create the source using Omise API
      final source = await omiseApiService.createSource(CreateSourceRequest(
          amount: value.amount!,
          currency: value.currency!,
          type: value.paymentMethod!,
          installmentTerm: term));

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
  void _setValue(InstallmentsPageState state) {
    value = state;
  }
}

/// State class that holds the values for [InstallmentsController].
class InstallmentsPageState {
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

  /// The selected installments method
  final PaymentMethodName? paymentMethod;

  /// The installment terms
  final List<int>? terms;

  /// The locale to open the credit card page
  final OmiseLocale? locale;

  /// The capability to pass to the credit card page
  final Capability? capability;

  /// Constructor for creating a [InstallmentsPageState].
  InstallmentsPageState({
    required this.sourceLoadingStatus,
    this.source,
    this.amount,
    this.currency,
    this.paymentMethod,
    this.terms,
    this.locale,
    this.capability,
    this.sourceErrorMessage,
  });

  /// Creates a copy of the current state while allowing overriding of
  /// specific fields. This is needed since in order to trigger a rebuild on the value notifier level, we need a new instance to be created for non primitive types.
  InstallmentsPageState copyWith({
    Source? source,
    Status? sourceLoadingStatus,
    int? amount,
    Currency? currency,
    PaymentMethodName? paymentMethod,
    List<int>? terms,
    OmiseLocale? locale,
    Capability? capability,
    String? sourceErrorMessage,
  }) {
    return InstallmentsPageState(
      source: source ?? this.source,
      sourceLoadingStatus: sourceLoadingStatus ?? this.sourceLoadingStatus,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      terms: terms ?? this.terms,
      locale: locale ?? this.locale,
      capability: capability ?? this.capability,
      sourceErrorMessage: sourceErrorMessage ?? this.sourceErrorMessage,
    );
  }
}
