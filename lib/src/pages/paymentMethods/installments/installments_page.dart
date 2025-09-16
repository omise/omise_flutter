import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/payment_method.dart';
import 'package:omise_flutter/src/pages/paymentMethods/installments/terms_page.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:omise_flutter/src/utils/package_info.dart';
import 'package:omise_flutter/src/utils/payment_utils.dart';
import 'package:omise_flutter/src/widgets/payment_method_tile.dart';

class InstallmentsPage extends StatefulWidget {
  final List<PaymentMethod> installmentPaymentMethods;

  /// An instance of [OmiseApiService] for interacting with the Omise API.
  final OmiseApiService omiseApiService;

  /// The amount that will be used to create a source.
  final int amount;

  /// The currency that will be used to create a source.
  final Currency currency;

  /// The custom locale passed by the merchant.
  final OmiseLocale? locale;

  /// The capability to pass to the credit terms page
  final Capability capability;

  /// The function name that is communicated through channels methods for native integrations.
  final String? nativeResultMethodName;

  /// Stores information about the cardholder required for passkey-based authentication flows.
  final List<CardHolderData>? cardHolderData;

  const InstallmentsPage({
    super.key,
    required this.installmentPaymentMethods,
    required this.omiseApiService,
    required this.amount,
    required this.currency,
    required this.capability,
    this.locale,
    this.nativeResultMethodName,
    this.cardHolderData,
  });

  @override
  State<InstallmentsPage> createState() => _InstallmentsPageState();
}

class _InstallmentsPageState extends State<InstallmentsPage> {
  @override
  Widget build(BuildContext context) {
    final isBelowAllowedAmount =
        widget.amount < widget.capability.limits.installmentAmount.min;
    return Scaffold(
        appBar: AppBar(
          title: Text(CustomPaymentMethod.installments
              .title(context: context, locale: widget.locale)),
        ),
        body: Column(
          children: [
            isBelowAllowedAmount
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            Translations.get(
                                'installmentsAmountLowerThanMonthlyLimit',
                                widget.locale,
                                context),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            IgnorePointer(
              ignoring: isBelowAllowedAmount,
              child: Opacity(
                opacity: isBelowAllowedAmount ? 0.5 : 1,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.installmentPaymentMethods.length,
                  itemBuilder: (context, index) {
                    final paymentMethod =
                        widget.installmentPaymentMethods[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: paymentMethodTile(
                        context: context,
                        paymentMethod: PaymentMethodTileData(
                          name:
                              paymentMethod.name, // Name of the payment method
                          leadingIcon:
                              // condition for testing as the image will not load in test mode
                              Image.asset(
                            PaymentUtils.getPaymentMethodImageName(
                                paymentMethod: paymentMethod
                                    .name), // Icon for payment method
                            package: PackageInfo.packageName,
                            alignment: Alignment.center,
                          ),
                          trailingIcon: Icons.arrow_forward_ios,
                          onTap: () {
                            // open the installment terms page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TermsPage(
                                        omiseApiService: widget.omiseApiService,
                                        locale: widget.locale,
                                        amount: widget.amount,
                                        currency: widget.currency,
                                        installmentPaymentMethod:
                                            paymentMethod.name,
                                        terms: paymentMethod.installmentTerms ??
                                            [],
                                        capability: widget.capability,
                                        nativeResultMethodName:
                                            widget.nativeResultMethodName,
                                        cardHolderData: widget.cardHolderData,
                                      )),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
