import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/fpx_bank_selector_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/omise_payment_result.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:omise_flutter/src/utils/message_display_utils.dart';
import 'package:omise_flutter/src/utils/package_info.dart';
import 'package:omise_flutter/src/utils/payment_utils.dart';

class FpxBanksPage extends StatefulWidget {
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

  /// Allow passing an instance of the controller to facilitate testing
  final FpxBankSelectorController? fpxBankSelectorController;
  const FpxBanksPage(
      {super.key,
      required this.fpxBanks,
      required this.omiseApiService,
      required this.amount,
      required this.currency,
      this.fpxBankSelectorController,
      this.locale,
      this.email});

  @override
  State<FpxBanksPage> createState() => _FpxBanksPageState();
}

class _FpxBanksPageState extends State<FpxBanksPage> {
  late final FpxBankSelectorController fpxBankSelectorController =
      widget.fpxBankSelectorController ??
          FpxBankSelectorController(
            omiseApiService: widget.omiseApiService,
          );
  @override
  void initState() {
    super.initState();
    fpxBankSelectorController.addListener(() {
      if (fpxBankSelectorController.value.sourceLoadingStatus == Status.error) {
        MessageDisplayUtils.showSnackBar(
            context, fpxBankSelectorController.value.sourceErrorMessage!);
      } else if (fpxBankSelectorController.value.sourceLoadingStatus ==
          Status.success) {
        while (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(OmisePaymentResult(
              source: fpxBankSelectorController.value.source));
        }
      }
    });
    fpxBankSelectorController.setSourceCreationParams(
        amount: widget.amount, currency: widget.currency, email: widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Translations.get('fpx', widget.locale, context)),
        ),
        body: ValueListenableBuilder(
            valueListenable: fpxBankSelectorController,
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
                                          PaymentUtils.getFpxBankImageName(
                                              fpxBank.code), // Icon for bank
                                          package: PackageInfo.packageName,
                                          alignment: Alignment.center,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                            PaymentUtils.getFpxBankImageName(
                                                FpxBankCode.unknown),
                                            package: PackageInfo.packageName,
                                            alignment: Alignment.center,
                                          ),
                                        ),
                                      ),
                                    ),
                          trailing: fpxBank.active
                              ? const Icon(Icons.arrow_forward_ios)
                              : null,
                          onTap: () {
                            fpxBankSelectorController
                                .createSource(fpxBank.code);
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
