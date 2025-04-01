import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/bank_selector_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/omise_payment_result.dart';
import 'package:omise_flutter/src/services/method_channel_service.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:omise_flutter/src/utils/message_display_utils.dart';
import 'package:omise_flutter/src/utils/package_info.dart';
import 'package:omise_flutter/src/utils/payment_utils.dart';

class BankSelectorPage extends StatefulWidget {
  final List<Bank> fpxBanks;

  /// An instance of [OmiseApiService] for interacting with the Omise API.
  final OmiseApiService omiseApiService;

  /// The amount that will be used to create a source.
  final int amount;

  /// The currency that will be used to create a source.
  final Currency currency;

  /// The custom locale passed by the merchant.
  final OmiseLocale? locale;

  /// The email of the user.
  final String? email;

  /// The payment method the is connected to the list of banks.
  final PaymentMethodName paymentMethod;

  /// The function name that is communicated through channels methods for native integrations.
  final String? nativeResultMethodName;

  /// Allow passing an instance of the controller to facilitate testing
  final BankSelectorController? fpxBankSelectorController;
  const BankSelectorPage({
    super.key,
    required this.fpxBanks,
    required this.omiseApiService,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.fpxBankSelectorController,
    this.locale,
    this.email,
    this.nativeResultMethodName,
  });

  @override
  State<BankSelectorPage> createState() => _BankSelectorPageState();
}

class _BankSelectorPageState extends State<BankSelectorPage> {
  late final BankSelectorController bankSelectorController =
      widget.fpxBankSelectorController ??
          BankSelectorController(
            omiseApiService: widget.omiseApiService,
          );
  @override
  void initState() {
    super.initState();
    bankSelectorController.addListener(() {
      if (bankSelectorController.value.sourceLoadingStatus == Status.error) {
        MessageDisplayUtils.showSnackBar(
            context, bankSelectorController.value.sourceErrorMessage!);
      } else if (bankSelectorController.value.sourceLoadingStatus ==
          Status.success) {
        final omisePaymentResult =
            OmisePaymentResult(source: bankSelectorController.value.source);
        if (widget.nativeResultMethodName != null) {
          MethodChannelService.sendResultToNative(
            widget.nativeResultMethodName!,
            omisePaymentResult.toJson(),
          );
        } else {
          while (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(omisePaymentResult);
          }
        }
      }
    });
    bankSelectorController.setSourceCreationParams(
        amount: widget.amount,
        currency: widget.currency,
        email: widget.email,
        paymentMethod: widget.paymentMethod);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Translations.get(
              widget.paymentMethod.name, widget.locale, context)),
        ),
        body: ValueListenableBuilder(
            valueListenable: bankSelectorController,
            builder: (context, state, _) {
              final isSourceLoading =
                  state.sourceLoadingStatus == Status.loading;
              return IgnorePointer(
                ignoring: isSourceLoading,
                child: Opacity(
                  opacity: isSourceLoading ? 0.5 : 1,
                  child: ListView.builder(
                    itemCount: widget.fpxBanks.length,
                    itemBuilder: (context, index) {
                      final fpxBank = widget.fpxBanks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          enabled: fpxBank.active,
                          title: Text(fpxBank.name), // Name of the bank
                          leading:
                              // condition for testing as the image will not load in test mode
                              widget.fpxBankSelectorController != null
                                  ? const SizedBox.shrink()
                                  : Opacity(
                                      opacity: fpxBank.active ? 1 : 0.5,
                                      child: SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: Image.asset(
                                          PaymentUtils.getBankImageName(
                                              fpxBank.code), // Icon for bank
                                          package: PackageInfo.packageName,
                                          alignment: Alignment.center,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                            PaymentUtils.getBankImageName(
                                                BankCode.unknown),
                                            package: PackageInfo.packageName,
                                            alignment: Alignment.center,
                                            // nested error builder because in unit tests images cannot be displayed
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const SizedBox.shrink(),
                                          ),
                                        ),
                                      ),
                                    ),
                          trailing: fpxBank.active
                              ? const Icon(Icons.arrow_forward_ios)
                              : null,
                          onTap: () {
                            bankSelectorController.createSource(fpxBank.code);
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            }));
  }
}
