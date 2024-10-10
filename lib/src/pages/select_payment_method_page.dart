import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/payment_method_selector_controller.dart';
import 'package:omise_flutter/src/enums/status.dart';
import 'package:omise_flutter/src/models/payment_method.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/widgets/payment_method_tile.dart';

/// [SelectPaymentMethodPage] is a stateful widget that presents the user with
/// a list of available payment methods based on capabilities retrieved from
/// Omise's API.
class SelectPaymentMethodPage extends StatefulWidget {
  /// An instance of [OmiseApiService] for interacting with the Omise API.
  final OmiseApiService omiseApiService;

  /// A list of selected payment methods that should be displayed in the UI.
  /// If null, all supported payment methods will be shown.
  final List<PaymentMethodName>? selectedPaymentMethods;

  /// Constructor for creating a [SelectPaymentMethodPage] widget.
  /// Takes [omiseApiService] as a required parameter and [selectedPaymentMethods] as optional.
  const SelectPaymentMethodPage(
      {super.key, required this.omiseApiService, this.selectedPaymentMethods});

  @override
  State<SelectPaymentMethodPage> createState() =>
      _SelectPaymentMethodPageState();
}

class _SelectPaymentMethodPageState extends State<SelectPaymentMethodPage> {
  /// The controller responsible for fetching and filtering payment methods.
  late final PaymentMethodSelectorController paymentMethodSelectorController =
      PaymentMethodSelectorController(
          omiseApiService: widget.omiseApiService,
          selectedPaymentMethods: widget.selectedPaymentMethods);

  /// Initializes the state and loads the payment methods on page load.
  @override
  void initState() {
    super.initState();
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
        builder: (context, controller, _) {
          // Display a loading spinner if the controller status is idle or loading
          if ([Status.loading, Status.idle].contains(controller.status)) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show the error message if the controller status is error
          if (controller.status == Status.error) {
            return Center(
              child: Text(controller.errorMessage!),
            );
          }

          // Get the list of filtered payment methods
          final paymentMethods = controller.viewablePaymentMethods!;

          // Show a message if no payment methods are available
          if (paymentMethods.isEmpty) {
            return const Center(
              child: Text("No payment methods available to display"),
            );
          }

          // Display a list of payment methods using a ListView
          return ListView.builder(
            itemCount: paymentMethods.length, // Number of payment methods
            itemBuilder: (context, index) {
              final paymentMethod = paymentMethods[index];

              // Render each payment method as a tile with an icon and arrow
              // TODO: Set up custom function to determine the properties of each payment method once more payment methods are added. For now only one is supported which is credit card.
              return paymentMethodTile(
                paymentMethod: PaymentMethodTileData(
                  name: paymentMethod.name, // Name of the payment method
                  leadingIcon: Image.asset(
                    'assets/credit.png', // Icon for payment method (example icon)
                    package: "omise_flutter",
                  ),
                  trailingIcon: Icons.arrow_forward_ios, // Arrow icon
                  onTap: () {
                    // Define what happens when a payment method is selected
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
