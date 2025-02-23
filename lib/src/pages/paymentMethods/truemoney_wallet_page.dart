import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/truemoney_wallet_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/omise_payment_result.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:omise_flutter/src/utils/message_display_utils.dart';
import 'package:omise_flutter/src/utils/package_info.dart';
import 'package:omise_flutter/src/utils/validation_utils.dart';
import 'package:omise_flutter/src/widgets/rounded_text_field.dart';

class TrueMoneyWalletPage extends StatefulWidget {
  /// The amount that will be used to create a source.
  final int amount;

  /// The currency that will be used to create a source.
  final Currency currency;

  /// The custom locale passed by the merchant.
  final OmiseLocale? locale;

  /// An instance of [OmiseApiService] for interacting with the Omise API.
  final OmiseApiService omiseApiService;

  /// Allow passing an instance of the controller to facilitate testing
  final TrueMoneyWalletController? trueMoneyWalletController;
  const TrueMoneyWalletPage(
      {super.key,
      this.locale,
      required this.omiseApiService,
      this.trueMoneyWalletController,
      required this.amount,
      required this.currency});

  @override
  State<TrueMoneyWalletPage> createState() => _TrueMoneyWalletPageState();
}

class _TrueMoneyWalletPageState extends State<TrueMoneyWalletPage> {
  late final TrueMoneyWalletController trueMoneyWalletController =
      widget.trueMoneyWalletController ??
          TrueMoneyWalletController(
            omiseApiService: widget.omiseApiService,
          );
  @override
  void initState() {
    super.initState();
    trueMoneyWalletController.addListener(() {
      if (trueMoneyWalletController.value.sourceLoadingStatus == Status.error) {
        MessageDisplayUtils.showSnackBar(
            context, trueMoneyWalletController.value.sourceErrorMessage!);
      } else if (trueMoneyWalletController.value.sourceLoadingStatus ==
          Status.success) {
        while (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(OmisePaymentResult(
              source: trueMoneyWalletController.value.source));
        }
      }
    });
    trueMoneyWalletController.setSourceCreationParams(
        amount: widget.amount, currency: widget.currency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.get('truemoney', widget.locale, context),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.only(
            left: 20.0,
            right: 20,
            top: MediaQuery.of(context).size.width * 0.2),
        child: Column(
          children: [
            Image.asset(
              'assets/truemoney_wallet.png',
              width: MediaQuery.of(context).size.width * 0.65,
              height: MediaQuery.of(context).size.height * 0.12,
              package: PackageInfo.packageName,
              alignment: Alignment.center,
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.04,
                  top: MediaQuery.of(context).size.height * 0.04),
              child: Text(Translations.get(
                  'trueMoneyWalletInfoText', widget.locale, context)),
            ),
            ValueListenableBuilder(
                valueListenable: trueMoneyWalletController,
                builder: (context, state, _) {
                  bool isNextButtonEnabled =
                      ValidationUtils.validatePhoneNumber(
                              context: context,
                              locale: widget.locale,
                              phoneNumber: state.phoneNumber) ==
                          null;
                  bool isLoading = state.sourceLoadingStatus == Status.loading;
                  return IgnorePointer(
                    ignoring: isLoading,
                    child: Opacity(
                      opacity: isLoading ? 0.5 : 1,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).size.height * 0.06),
                            child: RoundedTextField(
                              title: Translations.get(
                                  'phone', widget.locale, context),
                              validationType: ValidationType.phoneNumber,
                              enabled: !isLoading,
                              keyboardType: TextInputType.phone,
                              useValidationTypeAsKey: true,
                              onChange: (phoneNumber) {
                                var newState =
                                    state.copyWith(phoneNumber: phoneNumber);
                                trueMoneyWalletController.updateState(newState);
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  onPressed: (isNextButtonEnabled && !isLoading)
                                      ? () {
                                          trueMoneyWalletController
                                              .createSource();
                                        }
                                      : null,
                                  child: Text(
                                    Translations.get(
                                        'next', widget.locale, context),
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
