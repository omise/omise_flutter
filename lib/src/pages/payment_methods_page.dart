import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/payment_methods_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/omise_payment_result.dart';
import 'package:omise_flutter/src/models/payment_method.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:omise_flutter/src/utils/message_display_utils.dart';
import 'package:omise_flutter/src/utils/package_info.dart';
import 'package:omise_flutter/src/utils/payment_utils.dart';
import 'package:omise_flutter/src/widgets/payment_method_tile.dart';

/// [PaymentMethodsPage] is a stateful widget that presents the user with
/// a list of available payment methods based on capabilities retrieved from
/// Omise's API.
class PaymentMethodsPage extends StatefulWidget {
  /// An instance of [OmiseApiService] for interacting with the Omise API.
  final OmiseApiService omiseApiService;

  /// The amount that will be used to create a source.
  final int amount;

  /// The currency that will be used to create a source.
  final Currency currency;

  /// Allow passing an instance of the controller to facilitate testing
  final PaymentMethodsController? paymentMethodSelectorController;

  /// A list of selected payment methods that should be displayed in the UI.
  /// If null, all supported payment methods will be shown.
  final List<PaymentMethodName>? selectedPaymentMethods;

  /// A list of selected tokenization methods that should be displayed in the UI.
  /// If null, all supported tokenization methods will be shown.
  final List<TokenizationMethod>? selectedTokenizationMethods;

  /// The custom locale passed by the merchant.
  final OmiseLocale? locale;

  /// The custom list of card brands
  final List<String>? cardBrands;

  /// The google merchant id.
  final String? googlePayMerchantId;

  /// If the billing address should be requested.
  final bool requestBillingAddress;

  /// If the phone number should be requested.
  final bool requestPhoneNumber;

  /// The environment for google pay.
  final String? googlePayEnvironment;

  /// The pkey required for google pay.
  final String pkey;

  /// The description of the item being purchased.
  final String? googlePayItemDescription;

  /// The list of atome items.
  final List<Item>? atomeItems;

  /// Constructor for creating a [PaymentMethodsPage] widget.
  /// Takes [omiseApiService] as a required parameter and [selectedPaymentMethods] as optional.
  const PaymentMethodsPage({
    super.key,
    required this.omiseApiService,
    required this.amount,
    required this.currency,
    required this.pkey,
    this.selectedPaymentMethods,
    this.selectedTokenizationMethods,
    this.paymentMethodSelectorController,
    this.locale,
    this.cardBrands,
    this.requestBillingAddress = false,
    this.requestPhoneNumber = false,
    this.googlePayMerchantId,
    this.googlePayEnvironment,
    this.googlePayItemDescription,
    this.atomeItems,
  });

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  /// The controller responsible for fetching and filtering payment methods.
  late final PaymentMethodsController paymentMethodSelectorController =
      widget.paymentMethodSelectorController ??
          PaymentMethodsController(
              omiseApiService: widget.omiseApiService,
              selectedPaymentMethods: widget.selectedPaymentMethods,
              selectedTokenizationMethods: widget.selectedTokenizationMethods,
              pkey: widget.pkey);

  /// Initializes the state and loads the payment methods on page load.
  @override
  void initState() {
    super.initState();
    paymentMethodSelectorController.addListener(() {
      if (paymentMethodSelectorController.value.sourceLoadingStatus ==
          Status.error) {
        MessageDisplayUtils.showSnackBar(
            context, paymentMethodSelectorController.value.sourceErrorMessage!);
      } else if (paymentMethodSelectorController.value.sourceLoadingStatus ==
          Status.success) {
        while (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(OmisePaymentResult(
              source: paymentMethodSelectorController.value.source));
        }
      }
    });
    paymentMethodSelectorController.setSourceCreationParams(
      amount: widget.amount,
      currency: widget.currency,
      googlePayMerchantId: widget.googlePayMerchantId,
      requestBillingAddress: widget.requestBillingAddress,
      requestPhoneNumber: widget.requestPhoneNumber,
      cardBrands: widget.cardBrands,
      googlePayEnvironment: widget.googlePayEnvironment,
      googlePayItemDescription: widget.googlePayItemDescription,
      atomeItems: widget.atomeItems,
    );
    paymentMethodSelectorController.loadCapabilities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            Translations.get('selectPaymentMethod', widget.locale, context)),
        automaticallyImplyLeading: false, // Disable the default back button
        centerTitle: false, // Align the title to the left
        actions: [
          IconButton(
            onPressed: () {
              // Close the page when the 'X' icon is pressed
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: paymentMethodSelectorController,
        builder: (context, state, _) {
          // Display a loading spinner if the controller status is idle or loading
          if ([Status.loading, Status.idle]
              .contains(state.capabilityLoadingStatus)) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show the error message if the controller status is error
          if (state.capabilityLoadingStatus == Status.error) {
            return Center(
              child: Text(state.capabilityErrorMessage!),
            );
          }

          // Get the list of filtered payment methods
          final paymentMethods = state.viewablePaymentMethods!;

          // Show a message if no payment methods are available
          if (paymentMethods.isEmpty) {
            return Center(
              child: Text(
                  Translations.get('noPaymentMethods', widget.locale, context)),
            );
          }
          final isSourceLoading = state.sourceLoadingStatus == Status.loading;
          // Display a list of payment methods using a ListView
          return IgnorePointer(
            ignoring: isSourceLoading,
            child: Opacity(
              opacity: isSourceLoading ? 0.5 : 1,
              child: ListView.builder(
                itemCount: paymentMethods.length, // Number of payment methods
                itemBuilder: (context, index) {
                  final paymentMethod = paymentMethods[index];
                  CustomPaymentMethod? customEnum;
                  if (paymentMethod.name == PaymentMethodName.unknown) {
                    customEnum = CustomPaymentMethodNameExtension.fromString(
                        paymentMethod.object);
                  }
                  final paymentMethodParams =
                      paymentMethodSelectorController.getPaymentMethodParams(
                          paymentMethodName: paymentMethod.name,
                          context: context,
                          object: paymentMethod.object,
                          locale: widget.locale);
                  // Render each payment method as a tile with an icon and arrow
                  return paymentMethodTile(
                    context: context,
                    customTitle: customEnum?.title(
                        context: context, locale: widget.locale),
                    paymentMethod: PaymentMethodTileData(
                      name: paymentMethod.name, // Name of the payment method
                      leadingIcon:
                          // condition for testing as the image will not load in test mode
                          widget.paymentMethodSelectorController != null
                              ? const SizedBox()
                              : Image.asset(
                                  PaymentUtils.getPaymentMethodImageName(
                                      customPaymentMethod: customEnum,
                                      paymentMethod: paymentMethod
                                          .name), // Icon for payment method
                                  package: PackageInfo.packageName,
                                  alignment: Alignment.center,
                                ),
                      trailingIcon: paymentMethodParams.isNextPage == true
                          ? Icons.arrow_forward_ios
                          : Icons.arrow_outward, // Arrow icon
                      onTap: () {
                        paymentMethodParams.function();
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
