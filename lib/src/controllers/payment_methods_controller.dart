import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/pages/paymentMethods/atome_page.dart';
import 'package:omise_flutter/src/pages/paymentMethods/bank_selector_page.dart';
import 'package:omise_flutter/src/pages/paymentMethods/credit_card_page.dart';
import 'package:omise_flutter/src/pages/paymentMethods/econtext_page.dart';
import 'package:omise_flutter/src/pages/paymentMethods/fpx_email_page.dart';
import 'package:omise_flutter/src/pages/paymentMethods/google_pay_page.dart';
import 'package:omise_flutter/src/pages/paymentMethods/installments/installments_page.dart';
import 'package:omise_flutter/src/pages/paymentMethods/mobile_banking_page.dart';
import 'package:omise_flutter/src/pages/paymentMethods/truemoney_wallet_page.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';

/// The [PaymentMethodsController] manages the state and logic for
/// filtering and retrieving payment methods from Omise API.
class PaymentMethodsController extends ValueNotifier<PaymentMethodsState> {
  /// Instance of [OmiseApiService] used to interact with the omise dart package.
  final OmiseApiService omiseApiService;

  /// List of selected payment methods specified by the user.
  /// If null, all supported payment methods will be shown.
  final List<PaymentMethodName>? selectedPaymentMethods;

  /// List of selected payment methods specified by the user.
  /// If null, all supported tokenization methods will be shown.
  final List<TokenizationMethod>? selectedTokenizationMethods;

  /// THe pkey required for google pay.
  final String pkey;

  /// Constructor for initializing [PaymentMethodsController].
  /// Takes in a required [omiseApiService] and optional [selectedPaymentMethods].
  PaymentMethodsController({
    required this.omiseApiService,
    required this.pkey,
    this.selectedPaymentMethods,
    this.selectedTokenizationMethods,
  }) : super(PaymentMethodsState(
            capabilityLoadingStatus: Status.idle,
            sourceLoadingStatus: Status.idle));

  /// List of supported payment methods. Add more methods here as needed.
  final supportedPaymentMethods = {
    PaymentMethodName.card,
    PaymentMethodName.promptpay,
    PaymentMethodName.mobileBankingBay,
    PaymentMethodName.mobileBankingBbl,
    PaymentMethodName.mobileBankingKbank,
    PaymentMethodName.mobileBankingKtb,
    PaymentMethodName.mobileBankingOcbc,
    PaymentMethodName.mobileBankingScb,
    PaymentMethodName.installmentBay,
    PaymentMethodName.installmentWlbBay,
    PaymentMethodName.installmentBbl,
    PaymentMethodName.installmentWlbBbl,
    PaymentMethodName.installmentFirstChoice,
    PaymentMethodName.installmentWlbFirstChoice,
    PaymentMethodName.installmentKbank,
    PaymentMethodName.installmentWlbKbank,
    PaymentMethodName.installmentKtc,
    PaymentMethodName.installmentWlbKtc,
    PaymentMethodName.installmentScb,
    PaymentMethodName.installmentWlbScb,
    PaymentMethodName.installmentTtb,
    PaymentMethodName.installmentWlbTtb,
    PaymentMethodName.installmentUob,
    PaymentMethodName.installmentWlbUob,
    PaymentMethodName.installmentMbb,
    PaymentMethodName.alipay,
    PaymentMethodName.alipayCn,
    PaymentMethodName.alipayHk,
    PaymentMethodName.paynow,
    PaymentMethodName.dana,
    PaymentMethodName.gcash,
    PaymentMethodName.kakaopay,
    PaymentMethodName.touchNGo,
    PaymentMethodName.rabbitLinepay,
    PaymentMethodName.boost,
    PaymentMethodName.shopeePay,
    PaymentMethodName.shopeePayJumpapp,
    PaymentMethodName.duitnowQr,
    PaymentMethodName.mayBankQr,
    PaymentMethodName.grabpay,
    PaymentMethodName.paypay,
    PaymentMethodName.wechatPay,
    PaymentMethodName.truemoney, // truemoney wallet
    PaymentMethodName.truemoneyJumpapp,
    PaymentMethodName.fpx,
    PaymentMethodName.duitnowObw,
    PaymentMethodName.atome,
    PaymentMethodName.econtext,
  };
  final supportedTokenizationMethods = {TokenizationMethod.googlepay};
  final alipayPartners = {PaymentMethodName.alipayCn};
  PaymentMethodParams getPaymentMethodParams(
      {required BuildContext context,
      String? object,
      OmiseLocale? locale,
      required PaymentMethodName paymentMethodName}) {
    switch (paymentMethodName) {
      case PaymentMethodName.card:
        return PaymentMethodParams(
            isNextPage: true,
            function: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreditCardPage(
                          omiseApiService: omiseApiService,
                          capability: value.capability,
                          locale: locale,
                        )),
              );
            });
      case PaymentMethodName.truemoney:
        return PaymentMethodParams(
            isNextPage: true,
            function: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TrueMoneyWalletPage(
                          omiseApiService: omiseApiService,
                          amount: value.amount!,
                          currency: value.currency!,
                          locale: locale,
                        )),
              );
            });
      case PaymentMethodName.fpx:
        return PaymentMethodParams(
            isNextPage: true,
            function: () {
              int index = value.capability!.paymentMethods
                  .indexWhere((element) => element.name == paymentMethodName);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FpxEmailPage(
                    omiseApiService: omiseApiService,
                    amount: value.amount!,
                    currency: value.currency!,
                    locale: locale,
                    fpxBanks: index != -1
                        ? value.capability!.paymentMethods[index].banks
                        : [],
                  ),
                ),
              );
            });
      case PaymentMethodName.duitnowObw:
        return PaymentMethodParams(
            isNextPage: true,
            function: () {
              int index = value.capability!.paymentMethods
                  .indexWhere((element) => element.name == paymentMethodName);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BankSelectorPage(
                    omiseApiService: omiseApiService,
                    amount: value.amount!,
                    currency: value.currency!,
                    locale: locale,
                    fpxBanks: index != -1
                        ? value.capability!.paymentMethods[index].banks
                        : [],
                    paymentMethod: paymentMethodName,
                  ),
                ),
              );
            });
      case PaymentMethodName.atome:
        return PaymentMethodParams(
            isNextPage: true,
            function: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AtomePage(
                    omiseApiService: omiseApiService,
                    amount: value.amount!,
                    currency: value.currency!,
                    locale: locale,
                    items: value.atomeItems ?? [],
                  ),
                ),
              );
            });
      case PaymentMethodName.unknown:
        return PaymentMethodParams(
            isNextPage: true,
            function: () {
              if (object == CustomPaymentMethod.mobileBanking.value) {
                // open mobile banking screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MobileBankingPage(
                            mobileBankingPaymentMethods: value
                                .capability!.paymentMethods
                                .where((method) => method.name.value.contains(
                                    CustomPaymentMethod.mobileBanking.value))
                                .toList(),
                            amount: value.amount!,
                            currency: value.currency!,
                            omiseApiService: omiseApiService,
                            locale: locale,
                          )),
                );
              }
              if (object == CustomPaymentMethod.installments.value) {
                // open installments screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InstallmentsPage(
                            installmentPaymentMethods:
                                value.installmentPaymentMethods!,
                            amount: value.amount!,
                            currency: value.currency!,
                            omiseApiService: omiseApiService,
                            locale: locale,
                            capability: value.capability!,
                          )),
                );
              }
              if (object == CustomPaymentMethod.googlePay.value) {
                // open google pay screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GooglePayPage(
                            pkey: pkey,
                            googlePayMerchantId: value.googlePayMerchantId!,
                            requestBillingAddress: value.requestBillingAddress!,
                            requestPhoneNumber: value.requestPhoneNumber!,
                            cardBrands: value.cardBrands,
                            amount: value.amount!,
                            currency: value.currency!,
                            omiseApiService: omiseApiService,
                            locale: locale,
                            environment: value.googlePayEnvironment,
                            itemDescription: value.googlePayItemDescription,
                          )),
                );
              }
              if ([
                CustomPaymentMethod.convenienceStore.value,
                CustomPaymentMethod.payeasy.value,
                CustomPaymentMethod.netBank.value
              ].contains(object)) {
                // open econtext page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EcontextPage(
                      amount: value.amount!,
                      currency: value.currency!,
                      omiseApiService: omiseApiService,
                      locale: locale,
                      econtextMethod:
                          CustomPaymentMethodNameExtension.fromString(object),
                    ),
                  ),
                );
              }
            });

      default:
        return PaymentMethodParams(
            isNextPage: false,
            function: () {
              _setValue(
                  value.copyWith(selectedPaymentMethod: paymentMethodName));
              createSource();
            });
    }
  }

  void setSourceCreationParams({
    required int amount,
    required Currency currency,

    /// The selected payment method should only passed here for testing purposes
    PaymentMethodName? selectedPaymentMethod,
    String? googlePayMerchantId,
    bool? requestBillingAddress,
    bool? requestPhoneNumber,
    List<String>? cardBrands,
    String? googlePayEnvironment,
    String? googlePayItemDescription,
    List<Item>? atomeItems,
  }) {
    _setValue(
      value.copyWith(
        amount: amount,
        currency: currency,
        selectedPaymentMethod: selectedPaymentMethod,
        googlePayMerchantId: googlePayMerchantId,
        requestBillingAddress: requestBillingAddress,
        requestPhoneNumber: requestPhoneNumber,
        cardBrands: cardBrands,
        googlePayEnvironment: googlePayEnvironment,
        googlePayItemDescription: googlePayItemDescription,
        atomeItems: atomeItems,
      ),
    );
  }

  /// Loads the capabilities from Omise API and filters the payment methods
  /// based on the [selectedPaymentMethods], [supportedPaymentMethods], [selectedTokenizationMethods] and [supportedTokenizationMethods].
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

// Check if either `mobileBanking` or `installment` is found and replace by a single method holding all methods
      bool mobileBanking = filteredMethods.any((method) =>
          method.name.value.contains(CustomPaymentMethod.mobileBanking.value));
      bool installment = filteredMethods.any((method) =>
          method.name.value.contains(CustomPaymentMethod.installments.value));
      if (mobileBanking) {
        filteredMethods.add(PaymentMethod(
          object: CustomPaymentMethod.mobileBanking.value,
          name: PaymentMethodName.unknown,
          currencies: [],
          banks: [],
        ));
      }
      if (installment) {
        filteredMethods.add(PaymentMethod(
          object: CustomPaymentMethod.installments.value,
          name: PaymentMethodName.unknown,
          currencies: [],
          banks: [],
        ));
      }
      final installmentsPaymentMethods = capabilities.paymentMethods
          .where((method) => method.name.value
              .contains(CustomPaymentMethod.installments.value))
          .toList();
      // if the both wlb and non wlb installment exist, remove non wlb
      installmentsPaymentMethods.removeWhere((method) => ((method.name.value
              .contains(CustomPaymentMethod.installments.value) &&
          !method.name.value.contains('_wlb_') &&
          installmentsPaymentMethods
              .map((element) => element.name)
              .toList()
              .contains(PaymentMethodNameExtension.fromString(
                  method.name.value.replaceFirst('_', '_wlb_'))))));
      filteredMethods.removeWhere((method) =>
          method.name.value.contains(CustomPaymentMethod.mobileBanking.value) ||
          method.name.value.contains(CustomPaymentMethod.installments.value));
      // if shopeePay and shopeePayJumpApp are both available, remove non jumpApp
      final methodNames = filteredMethods.map((method) => method.name).toList();
      final bothShopeePayMethodsExist =
          methodNames.contains(PaymentMethodName.shopeePay) &&
              methodNames.contains(PaymentMethodName.shopeePayJumpapp);
      if (bothShopeePayMethodsExist) {
        filteredMethods.removeWhere(
            (method) => method.name == PaymentMethodName.shopeePay);
      }
      // if truemoney and truemoneyJumpapp are both available, remove non jumpApp
      final bothTruemoneyMethodsExist =
          methodNames.contains(PaymentMethodName.truemoney) &&
              methodNames.contains(PaymentMethodName.truemoneyJumpapp);
      if (bothTruemoneyMethodsExist) {
        filteredMethods.removeWhere(
            (method) => method.name == PaymentMethodName.truemoney);
      }
      // check econtext and add the connected payment methods to the list of payment methods
      if (filteredMethods
          .any((element) => element.name == PaymentMethodName.econtext)) {
        filteredMethods.removeWhere((element) {
          // remove econtext
          return element.name == PaymentMethodName.econtext;
        });
        // Add three payment methods manually, Convenience store, pay easy and Net Bank
        filteredMethods.addAll([
          PaymentMethod(
            object: CustomPaymentMethod.convenienceStore.value,
            name: PaymentMethodName.unknown,
            currencies: [],
            banks: [],
          ),
          PaymentMethod(
            object: CustomPaymentMethod.payeasy.value,
            name: PaymentMethodName.unknown,
            currencies: [],
            banks: [],
          ),
          PaymentMethod(
            object: CustomPaymentMethod.netBank.value,
            name: PaymentMethodName.unknown,
            currencies: [],
            banks: [],
          )
        ]);
      }
      // filter tokenization methods
      final tokenizationMethods = capabilities.tokenizationMethods;
      for (int i = 0; i < tokenizationMethods.length; i++) {
        if (supportedTokenizationMethods.contains(tokenizationMethods[i])) {
          if (selectedTokenizationMethods != null &&
              selectedTokenizationMethods!.contains(tokenizationMethods[i])) {
            filteredMethods.add(PaymentMethod(
              object: CustomPaymentMethodNameExtension.fromString(
                      tokenizationMethods[i].value)
                  .value,
              name: PaymentMethodName.unknown,
              currencies: [],
              banks: [],
            ));
          } else {
            if (selectedTokenizationMethods != null) {
              continue;
            }
            // No user-specified selection, use all supported methods
            filteredMethods.add(PaymentMethod(
              object: CustomPaymentMethodNameExtension.fromString(
                      tokenizationMethods[i].value)
                  .value,
              name: PaymentMethodName.unknown,
              currencies: [],
              banks: [],
            ));
          }
        }
      }
      // Update the state with the filtered methods and success status
      _setValue(value.copyWith(
          capability: capabilities,
          capabilityLoadingStatus: Status.success,
          viewablePaymentMethods: filteredMethods,
          installmentPaymentMethods: installmentsPaymentMethods));
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

      // Create the source using Omise API
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
  void _setValue(PaymentMethodsState state) {
    value = state;
  }
}

/// State class that holds the values for [PaymentMethodsController].
/// Contains the current status, error messages, capabilities, and filtered
/// payment methods that are viewable by the user.
class PaymentMethodsState {
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

  final List<PaymentMethod>? installmentPaymentMethods;

  /// The google play merchant id
  final String? googlePayMerchantId;

  /// The parameter to force request the billing address in google pay
  final bool? requestBillingAddress;

  /// The parameter to force request the phone number in google pay
  final bool? requestPhoneNumber;

  /// The list of card brands in google pay
  final List<String>? cardBrands;

  /// The environment for google pay
  final String? googlePayEnvironment;

  /// The google play description of the item being purchased.
  String? googlePayItemDescription;

  /// The atome list of items.
  final List<Item>? atomeItems;

  /// Constructor for creating a [PaymentMethodsState].
  PaymentMethodsState({
    required this.capabilityLoadingStatus,
    required this.sourceLoadingStatus,
    this.capabilityErrorMessage,
    this.capability,
    this.source,
    this.amount,
    this.currency,
    this.sourceErrorMessage,
    this.selectedPaymentMethod,
    this.viewablePaymentMethods,
    this.installmentPaymentMethods,
    this.googlePayMerchantId,
    this.requestBillingAddress,
    this.requestPhoneNumber,
    this.cardBrands,
    this.googlePayEnvironment,
    this.googlePayItemDescription,
    this.atomeItems,
  });

  /// Creates a copy of the current state while allowing overriding of
  /// specific fields. This is needed since in order to trigger a rebuild on the value notifier level, we need a new instance to be created for non primitive types.
  PaymentMethodsState copyWith({
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
    List<PaymentMethod>? installmentPaymentMethods,
    String? googlePayMerchantId,
    bool? requestBillingAddress,
    bool? requestPhoneNumber,
    List<String>? cardBrands,
    String? googlePayEnvironment,
    String? googlePayItemDescription,
    List<Item>? atomeItems,
  }) {
    return PaymentMethodsState(
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
      installmentPaymentMethods:
          installmentPaymentMethods ?? this.installmentPaymentMethods,
      googlePayMerchantId: googlePayMerchantId ?? this.googlePayMerchantId,
      requestBillingAddress:
          requestBillingAddress ?? this.requestBillingAddress,
      requestPhoneNumber: requestPhoneNumber ?? this.requestPhoneNumber,
      cardBrands: cardBrands ?? this.cardBrands,
      googlePayEnvironment: googlePayEnvironment ?? this.googlePayEnvironment,
      googlePayItemDescription:
          googlePayItemDescription ?? this.googlePayItemDescription,
      atomeItems: atomeItems ?? this.atomeItems,
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
