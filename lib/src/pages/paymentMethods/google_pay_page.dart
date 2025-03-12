import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:omise_flutter/omise_flutter.dart';
import 'package:omise_flutter/src/controllers/google_pay_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:omise_flutter/src/utils/message_display_utils.dart';
import 'package:pay/pay.dart';

class GooglePayPage extends StatefulWidget {
  /// The environment used in the google pay payment
  final String? environment;

  /// The custom list of card brands
  final List<String>? cardBrands;

  /// The google merchant id.
  final String googlePayMerchantId;

  /// If the billing address should be requested.
  final bool requestBillingAddress;

  /// If the phone number should be requested.
  final bool requestPhoneNumber;

  /// An instance of [OmiseApiService] for interacting with the Omise API.
  final OmiseApiService omiseApiService;

  /// Allows passing an instance of the controller to facilitate testing.
  final GooglePayController? googlePayController;

  /// The custom locale passed by the merchant.
  final OmiseLocale? locale;

  /// The currency if coming from wlb installments screen
  final Currency currency;

  /// The amount if coming from wlb installments screen
  final int amount;

  /// The pkey of the merchant representing the merchant gateway id
  final String pkey;

  /// The description of the item being purchased.
  final String? itemDescription;

  const GooglePayPage({
    super.key,
    required this.googlePayMerchantId,
    required this.requestBillingAddress,
    required this.requestPhoneNumber,
    required this.omiseApiService,
    this.googlePayController,
    required this.currency,
    required this.amount,
    this.locale,
    this.cardBrands,
    this.environment,
    required this.pkey,
    this.itemDescription,
  });

  @override
  State<GooglePayPage> createState() => _GooglePayPageState();
}

class _GooglePayPageState extends State<GooglePayPage> {
  /// The controller responsible for fetching and filtering payment methods.
  late final GooglePayController googlePayController =
      widget.googlePayController ??
          GooglePayController(
            omiseApiService: widget.omiseApiService,
            pkey: widget.pkey,
          );
  @override
  void initState() {
    super.initState();
    googlePayController.addListener(() {
      if (googlePayController.value.tokenLoadingStatus == Status.error) {
        MessageDisplayUtils.showSnackBar(
            context, googlePayController.value.tokenErrorMessage!);
      } else if (googlePayController.value.tokenLoadingStatus ==
          Status.success) {
        while (Navigator.of(context).canPop()) {
          Navigator.of(context)
              .pop(OmisePaymentResult(token: googlePayController.value.token));
        }
      }
    });
    googlePayController.setTokenCreationParams(
        googlePayMerchantId: widget.googlePayMerchantId,
        requestBillingAddress: widget.requestBillingAddress,
        requestPhoneNumber: widget.requestPhoneNumber,
        amount: widget.amount,
        currency: widget.currency,
        itemDescription: widget.itemDescription);
    googlePayController.setGooglePayParameters(
        widget.cardBrands, widget.environment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.get('googlePay', OmiseLocale.en, context),
        ),
      ),
      body: ValueListenableBuilder(
          valueListenable: googlePayController,
          builder: (context, state, _) {
            return IgnorePointer(
              ignoring: state.tokenLoadingStatus == Status.loading,
              child: Opacity(
                opacity: state.tokenLoadingStatus == Status.loading ? 0.5 : 1,
                child: Center(
                  child: GooglePayButton(
                      type: GooglePayButtonType.pay,
                      buttonProvider: PayProvider.google_pay,
                      onPaymentResult: (result) {
                        googlePayController.setGooglePayResult(result);
                        googlePayController.createToken();
                      },
                      onError: (error) {
                        log("Google pay error", error: error);
                      },
                      paymentConfiguration: PaymentConfiguration.fromJsonString(
                          state.googlePayRequest!),
                      paymentItems: [
                        PaymentItem(
                          label: state.itemDescription!,
                          amount: state.amount!.toString(),
                          status: PaymentItemStatus.final_price,
                        )
                      ]),
                ),
              ),
            );
          }),
    );
  }
}
