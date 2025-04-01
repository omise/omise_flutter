import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/internet_banking_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/omise_payment_result.dart';
import 'package:omise_flutter/src/models/payment_method.dart';
import 'package:omise_flutter/src/services/method_channel_service.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/utils/message_display_utils.dart';
import 'package:omise_flutter/src/utils/package_info.dart';
import 'package:omise_flutter/src/utils/payment_utils.dart';
import 'package:omise_flutter/src/widgets/payment_method_tile.dart';

class InternetBankingPage extends StatefulWidget {
  final List<PaymentMethod> internetBankingPaymentMethods;

  /// An instance of [OmiseApiService] for interacting with the Omise API.
  final OmiseApiService omiseApiService;

  /// The amount that will be used to create a source.
  final int amount;

  /// The currency that will be used to create a source.
  final Currency currency;

  /// The custom locale passed by the merchant.
  final OmiseLocale? locale;

  /// The function name that is communicated through channels methods for native integrations.
  final String? nativeResultMethodName;

  /// Allow passing an instance of the controller to facilitate testing
  final InternetBankingController? internetBankingController;
  const InternetBankingPage({
    super.key,
    required this.internetBankingPaymentMethods,
    required this.omiseApiService,
    required this.amount,
    required this.currency,
    this.internetBankingController,
    this.locale,
    this.nativeResultMethodName,
  });

  @override
  State<InternetBankingPage> createState() => _InternetBankingPageState();
}

class _InternetBankingPageState extends State<InternetBankingPage> {
  late final InternetBankingController internetBankingController =
      widget.internetBankingController ??
          InternetBankingController(
            omiseApiService: widget.omiseApiService,
          );
  @override
  void initState() {
    super.initState();
    internetBankingController.addListener(() {
      if (internetBankingController.value.sourceLoadingStatus == Status.error) {
        MessageDisplayUtils.showSnackBar(
            context, internetBankingController.value.sourceErrorMessage!);
      } else if (internetBankingController.value.sourceLoadingStatus ==
          Status.success) {
        final omisePaymentResult =
            OmisePaymentResult(source: internetBankingController.value.source);
        if (widget.nativeResultMethodName != null) {
          MethodChannelService.sendResultToNative(
              widget.nativeResultMethodName!, omisePaymentResult.toJson());
        } else {
          while (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(omisePaymentResult);
          }
        }
      }
    });
    internetBankingController.setSourceCreationParams(
        amount: widget.amount, currency: widget.currency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(CustomPaymentMethod.internetBanking
              .title(context: context, locale: widget.locale)),
        ),
        body: ValueListenableBuilder(
            valueListenable: internetBankingController,
            builder: (context, state, _) {
              final isSourceLoading =
                  state.sourceLoadingStatus == Status.loading;
              return IgnorePointer(
                ignoring: isSourceLoading,
                child: Opacity(
                  opacity: isSourceLoading ? 0.5 : 1,
                  child: ListView.builder(
                    itemCount: widget.internetBankingPaymentMethods.length,
                    itemBuilder: (context, index) {
                      final paymentMethod =
                          widget.internetBankingPaymentMethods[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: paymentMethodTile(
                          context: context,
                          paymentMethod: PaymentMethodTileData(
                            name: paymentMethod
                                .name, // Name of the payment method
                            leadingIcon:
                                // condition for testing as the image will not load in test mode
                                widget.internetBankingController != null
                                    ? const SizedBox()
                                    : Image.asset(
                                        PaymentUtils.getPaymentMethodImageName(
                                            paymentMethod: paymentMethod
                                                .name), // Icon for payment method
                                        package: PackageInfo.packageName,
                                        alignment: Alignment.center,
                                      ),
                            trailingIcon: Icons.arrow_forward_ios,
                            onTap: () {
                              internetBankingController
                                  .createSource(paymentMethod.name);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }));
  }
}
