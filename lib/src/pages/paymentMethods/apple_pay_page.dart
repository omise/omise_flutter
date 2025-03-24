import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:omise_flutter/omise_flutter.dart';
import 'package:omise_flutter/src/controllers/apple_pay_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:omise_flutter/src/utils/message_display_utils.dart';
import 'package:pay/pay.dart';

class ApplePayPage extends StatefulWidget {
  /// The custom list of card brands
  final List<String>? cardBrands;

  /// The google merchant id.
  final String applePayMerchantId;

  /// The list of fields to be requested in shipping address in apple pay.
  final List<String>? requiredShippingContactFields;

  /// The list of fields to be requested in billing address in apple pay.
  final List<String>? requiredBillingContactFields;

  /// An instance of [OmiseApiService] for interacting with the Omise API.
  final OmiseApiService omiseApiService;

  /// Allows passing an instance of the controller to facilitate testing.
  final ApplePayController? applePayController;

  /// The custom locale passed by the merchant.
  final OmiseLocale? locale;

  /// The currency if coming from wlb installments screen
  final Currency currency;

  /// The country used in token creation, capability api is used to set it.
  final String country;

  /// The amount if coming from wlb installments screen
  final int amount;

  /// The pkey of the merchant representing the merchant gateway id
  final String pkey;

  /// The description of the item being purchased.
  final String? itemDescription;

  const ApplePayPage({
    super.key,
    required this.applePayMerchantId,
    this.requiredBillingContactFields,
    this.requiredShippingContactFields,
    required this.omiseApiService,
    this.applePayController,
    required this.currency,
    required this.country,
    required this.amount,
    this.locale,
    this.cardBrands,
    required this.pkey,
    this.itemDescription,
  });

  @override
  State<ApplePayPage> createState() => _ApplePayPageState();
}

class _ApplePayPageState extends State<ApplePayPage> {
  /// The controller responsible for fetching and filtering payment methods.
  late final ApplePayController applePayController =
      widget.applePayController ??
          ApplePayController(
            omiseApiService: widget.omiseApiService,
            pkey: widget.pkey,
          );
  @override
  void initState() {
    super.initState();
    applePayController.addListener(() {
      if (applePayController.value.tokenLoadingStatus == Status.error) {
        MessageDisplayUtils.showSnackBar(
            context, applePayController.value.tokenErrorMessage!);
      } else if (applePayController.value.tokenLoadingStatus ==
          Status.success) {
        while (Navigator.of(context).canPop()) {
          Navigator.of(context)
              .pop(OmisePaymentResult(token: applePayController.value.token));
        }
      }
    });
    applePayController.setTokenCreationParams(
      applePayMerchantId: widget.applePayMerchantId,
      requiredBillingContactFields: widget.requiredBillingContactFields,
      requiredShippingContactFields: widget.requiredShippingContactFields,
      amount: widget.amount,
      currency: widget.currency,
      country: widget.country,
      itemDescription: widget.itemDescription,
    );
    applePayController.setApplePayParameters(widget.cardBrands);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.get('applePay', OmiseLocale.en, context),
        ),
      ),
      body: ValueListenableBuilder(
          valueListenable: applePayController,
          builder: (context, state, _) {
            return IgnorePointer(
              ignoring: state.tokenLoadingStatus == Status.loading,
              child: Opacity(
                opacity: state.tokenLoadingStatus == Status.loading ? 0.5 : 1,
                child: Center(
                  child: ApplePayButton(
                      type: ApplePayButtonType.buy,
                      buttonProvider: PayProvider.apple_pay,
                      onPaymentResult: (result) {
                        applePayController.setApplePayResult(result);
                        applePayController.createToken();
                      },
                      onError: (error) {
                        log("Apple pay error", error: error);
                      },
                      paymentConfiguration: PaymentConfiguration.fromJsonString(
                          state.applePayRequest!),
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
