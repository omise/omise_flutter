import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/installments_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/omise_payment_result.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:omise_flutter/src/utils/message_display_utils.dart';

class TermsPage extends StatefulWidget {
  final List<int> terms;

  /// An instance of [OmiseApiService] for interacting with the Omise API.
  final OmiseApiService omiseApiService;

  /// The amount that will be used to create a source.
  final int amount;

  /// The currency that will be used to create a source.
  final Currency currency;

  /// The selected installments payment method
  final PaymentMethodName installmentPaymentMethod;

  /// The custom locale passed by the merchant.
  final OmiseLocale? locale;

  /// The capability to pass to the credit card page
  final Capability capability;

  /// Allow passing an instance of the controller to facilitate testing
  final InstallmentsController? installmentsPaymentMethodSelectorController;
  const TermsPage({
    super.key,
    required this.terms,
    required this.omiseApiService,
    required this.amount,
    required this.currency,
    required this.installmentPaymentMethod,
    required this.capability,
    this.installmentsPaymentMethodSelectorController,
    this.locale,
  });

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  late final InstallmentsController
      installmentsPaymentMethodSelectorController =
      widget.installmentsPaymentMethodSelectorController ??
          InstallmentsController(
            omiseApiService: widget.omiseApiService,
          );
  @override
  void initState() {
    super.initState();
    installmentsPaymentMethodSelectorController.addListener(() {
      if (installmentsPaymentMethodSelectorController
              .value.sourceLoadingStatus ==
          Status.error) {
        MessageDisplayUtils.showSnackBar(
            context,
            installmentsPaymentMethodSelectorController
                .value.sourceErrorMessage!);
      } else if (installmentsPaymentMethodSelectorController
              .value.sourceLoadingStatus ==
          Status.success) {
        while (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(OmisePaymentResult(
              source:
                  installmentsPaymentMethodSelectorController.value.source));
        }
      }
    });
    installmentsPaymentMethodSelectorController.setSourceCreationParams(
        amount: widget.amount,
        currency: widget.currency,
        paymentMethod: widget.installmentPaymentMethod,
        capability: widget.capability,
        terms: widget.terms);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Translations.get(
              widget.installmentPaymentMethod.name, widget.locale, context)),
        ),
        body: ValueListenableBuilder(
            valueListenable: installmentsPaymentMethodSelectorController,
            builder: (context, state, _) {
              final isSourceLoading =
                  state.sourceLoadingStatus == Status.loading;
              return Opacity(
                opacity: isSourceLoading ? 0.5 : 1,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.terms.length,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(
                              '${widget.terms[index]} ${Translations.get('months', widget.locale, context)}'),
                          onTap: () {
                            installmentsPaymentMethodSelectorController
                                .processInstallment(
                                    widget.terms[index], context);
                          },
                          trailing: Icon(widget.installmentPaymentMethod.value
                                  .contains(('_wlb_'))
                              ? Icons.arrow_forward_ios
                              : Icons.arrow_outward),
                        ));
                  },
                ),
              );
            }));
  }
}
