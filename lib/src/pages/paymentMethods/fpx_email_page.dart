import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/pages/paymentMethods/bank_selector_page.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:omise_flutter/src/utils/package_info.dart';
import 'package:omise_flutter/src/utils/validation_utils.dart';
import 'package:omise_flutter/src/widgets/rounded_text_field.dart';

class FpxEmailPage extends StatefulWidget {
  /// The amount that will be used to create a source.
  final int amount;

  /// The currency that will be used to create a source.
  final Currency currency;

  /// The custom locale passed by the merchant.
  final OmiseLocale? locale;

  /// An instance of [OmiseApiService] for interacting with the Omise API.
  final OmiseApiService omiseApiService;

  /// The list of FPX banks.
  final List<Bank> fpxBanks;

  const FpxEmailPage(
      {super.key,
      this.locale,
      required this.omiseApiService,
      required this.amount,
      required this.currency,
      required this.fpxBanks});

  @override
  State<FpxEmailPage> createState() => _FpxEmailPageState();
}

class _FpxEmailPageState extends State<FpxEmailPage> {
  String? fpxEmail;
  @override
  Widget build(BuildContext context) {
    // email is optional so null is allowed
    bool isNextButtonEnabled = ValidationUtils.validateEmail(
            context: context,
            locale: widget.locale,
            email: fpxEmail,
            isOptional: true) ==
        null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.get('fpx', widget.locale, context),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.only(
            left: 20.0,
            right: 20,
            top: MediaQuery.of(context).size.width * 0.2),
        child: ListView(
          children: [
            Image.asset(
              'assets/fpx.png',
              width: MediaQuery.of(context).size.width * 0.65,
              height: MediaQuery.of(context).size.height * 0.12,
              package: PackageInfo.packageName,
              alignment: Alignment.center,
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.04,
                  top: MediaQuery.of(context).size.height * 0.04),
              child:
                  Text(Translations.get('fpxInfoText', widget.locale, context)),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.06),
                  child: RoundedTextField(
                    title: Translations.get('email', widget.locale, context),
                    validationType: ValidationType.none,
                    keyboardType: TextInputType.emailAddress,
                    onChange: (email) {
                      if (email.trim().isEmpty) {
                        fpxEmail = null;
                      } else {
                        fpxEmail = email.trim();
                      }
                      // rebuild the UI to change the button state
                      setState(() {});
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
                        onPressed: (isNextButtonEnabled)
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BankSelectorPage(
                                            omiseApiService:
                                                widget.omiseApiService,
                                            amount: widget.amount,
                                            currency: widget.currency,
                                            locale: widget.locale,
                                            email: fpxEmail,
                                            fpxBanks: widget.fpxBanks,
                                            paymentMethod:
                                                PaymentMethodName.fpx,
                                          )),
                                );
                              }
                            : null,
                        child: Text(
                          Translations.get('next', widget.locale, context),
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
            )
          ],
        ),
      ),
    );
  }
}
