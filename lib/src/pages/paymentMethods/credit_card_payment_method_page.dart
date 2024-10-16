import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:omise_flutter/src/controllers/credit_card_payment_method_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/widgets/rounded_text_feild.dart';

class CreditCardPaymentMethodPage extends StatefulWidget {
  /// An instance of [OmiseApiService] for interacting with the Omise API.
  final OmiseApiService omiseApiService;

  /// Allow passing an instance of the controller to facilitate testing
  final CreditCardPaymentMethodController? creditCardPaymentMethodController;
  final bool automaticallyImplyLeading;
  const CreditCardPaymentMethodPage(
      {super.key,
      this.automaticallyImplyLeading = true,
      required this.omiseApiService,
      this.creditCardPaymentMethodController});

  @override
  State<CreditCardPaymentMethodPage> createState() =>
      _CreditCardPaymentMethodPageState();
}

class _CreditCardPaymentMethodPageState
    extends State<CreditCardPaymentMethodPage> {
  final countryPicker = const FlCountryCodePicker();

  /// The controller responsible for fetching and filtering payment methods.
  late final CreditCardPaymentMethodController
      creditCardPaymentMethodController =
      widget.creditCardPaymentMethodController ??
          CreditCardPaymentMethodController(
            omiseApiService: widget.omiseApiService,
          );
  @override
  void initState() {
    super.initState();
    creditCardPaymentMethodController.loadCapabilities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Credit Card"),
          automaticallyImplyLeading: widget.automaticallyImplyLeading,
          centerTitle: false,
        ),
        body: ValueListenableBuilder(
            valueListenable: creditCardPaymentMethodController,
            builder: (context, state, widget) {
              if ([Status.loading, Status.idle].contains(state.status)) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state.status == Status.error) {
                return Center(
                  child: Text(state.errorMessage!),
                );
              }
              return ListView(
                padding: const EdgeInsets.only(left: 20, right: 20),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0, top: 20),
                    child: RoundedTextField(
                      title: "Card Number",
                      validationType: ValidationType.cardNumber,
                      onChange: (cardNumber) {
                        var newState = state.copyWith();
                        newState.createTokenRequest.number = cardNumber;
                        creditCardPaymentMethodController.updateState(newState);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: RoundedTextField(
                      title: "Name on card",
                      validationType: ValidationType.name,
                      onChange: (name) {
                        var newState = state.copyWith();
                        newState.createTokenRequest.name = name;
                        creditCardPaymentMethodController.updateState(newState);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 12.0,
                            ),
                            child: RoundedTextField(
                              title: "Expiry date",
                              validationType: ValidationType.expiryDate,
                              onChange: (expiryDate) {
                                creditCardPaymentMethodController
                                    .setExpiryDate(expiryDate);
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 12.0,
                            ),
                            child: RoundedTextField(
                              title: "Security code",
                              validationType: ValidationType.cvv,
                              onChange: (securityCode) {
                                var newState = state.copyWith();
                                newState.createTokenRequest.securityCode =
                                    securityCode;
                                creditCardPaymentMethodController
                                    .updateState(newState);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      "Country or region",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: Colors
                                .grey, // Same as the TextField border color
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          state.createTokenRequest.country ?? '',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      onTap: () async {
                        // Show the country code picker when tapped.
                        final picked =
                            await countryPicker.showPicker(context: context);
                        // Null check
                        if (picked != null) {
                          var newState = state.copyWith();
                          newState.createTokenRequest.country = picked.code;
                          creditCardPaymentMethodController
                              .updateState(newState);
                        }
                      },
                    ),
                  ),
                  if (state.shouldShowAddressFields)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: RoundedTextField(
                            title: "Address",
                            validationType: ValidationType.name,
                            onChange: (address) {
                              var newState = state.copyWith();
                              newState.createTokenRequest.street1 = address;
                              creditCardPaymentMethodController
                                  .updateState(newState);
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: RoundedTextField(
                              title: "City",
                              validationType: ValidationType.name),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: RoundedTextField(
                            title: "State",
                            validationType: ValidationType.name,
                            onChange: (addressState) {
                              var newState = state.copyWith();
                              newState.createTokenRequest.state = addressState;
                              creditCardPaymentMethodController
                                  .updateState(newState);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: RoundedTextField(
                            title: "Postal code",
                            validationType: ValidationType.name,
                            onChange: (postalCode) {
                              var newState = state.copyWith();
                              newState.createTokenRequest.postalCode =
                                  postalCode;
                              creditCardPaymentMethodController
                                  .updateState(newState);
                            },
                          ),
                        ),
                      ],
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Filled blue color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8.0), // Matching rounded corners
                      ),
                    ),
                    child: const Text(
                      'Pay',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white, // White text for contrast
                      ),
                    ),
                    onPressed: () {},
                  ),
                ],
              );
            }));
  }
}
