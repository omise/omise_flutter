import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/payment_method_selector_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/omise_payment_result.dart';
import 'package:omise_flutter/src/models/payment_method.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/utils/message_display_utils.dart';
import 'package:omise_flutter/src/utils/package_info.dart';
import 'package:omise_flutter/src/widgets/payment_method_tile.dart';

/// [SelectPaymentMethodPage] is a stateful widget that presents the user with
/// a list of available payment methods based on capabilities retrieved from
/// Omise's API.
class SelectPaymentMethodPage extends StatefulWidget {
  /// An instance of [OmiseApiService] for interacting with the Omise API.
  final OmiseApiService omiseApiService;

  /// The amount that will be used to create a source.
  final int amount;

  /// The currency that will be used to create a source.
  final Currency currency;

  /// Allow passing an instance of the controller to facilitate testing
  final PaymentMethodSelectorController? paymentMethodSelectorController;

  /// A list of selected payment methods that should be displayed in the UI.
  /// If null, all supported payment methods will be shown.
  final List<PaymentMethodName>? selectedPaymentMethods;

  /// Constructor for creating a [SelectPaymentMethodPage] widget.
  /// Takes [omiseApiService] as a required parameter and [selectedPaymentMethods] as optional.
  const SelectPaymentMethodPage({
    super.key,
    required this.omiseApiService,
    required this.amount,
    required this.currency,
    this.selectedPaymentMethods,
    this.paymentMethodSelectorController,
  });

  @override
  State<SelectPaymentMethodPage> createState() =>
      _SelectPaymentMethodPageState();
}

class _SelectPaymentMethodPageState extends State<SelectPaymentMethodPage> {
  /// The controller responsible for fetching and filtering payment methods.
  late final PaymentMethodSelectorController paymentMethodSelectorController =
      widget.paymentMethodSelectorController ??
          PaymentMethodSelectorController(
              omiseApiService: widget.omiseApiService,
              selectedPaymentMethods: widget.selectedPaymentMethods);

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
        amount: widget.amount, currency: widget.currency);
    paymentMethodSelectorController.loadCapabilities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a payment method"),
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
            return const Center(
              child: Text("No payment methods available to display"),
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

                  // Render each payment method as a tile with an icon and arrow
                  return paymentMethodTile(
                    customTitle: customEnum?.title,
                    paymentMethod: PaymentMethodTileData(
                      name: paymentMethod.name, // Name of the payment method
                      leadingIcon:
                          // condition for testing as the image will not load in test mode
                          widget.paymentMethodSelectorController != null
                              ? const SizedBox()
                              : Image.asset(
                                  'assets/${customEnum?.value ?? paymentMethod.name.value}.png', // Icon for payment method
                                  package: PackageInfo.packageName,
                                  alignment: Alignment.center,
                                ),
                      trailingIcon: paymentMethodSelectorController
                                  .getPaymentMethodsMap(
                                      context: context)[paymentMethod.name]
                                  ?.isNextPage ==
                              true
                          ? Icons.arrow_forward_ios
                          : Icons.arrow_outward, // Arrow icon
                      onTap: () {
                        paymentMethodSelectorController
                            .getPaymentMethodsMap(
                                context: context,
                                object:
                                    paymentMethod.object)[paymentMethod.name]
                            ?.function();
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
