import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/credit_card_payment_method_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/utils/expiry_date_formatter.dart';
import 'package:omise_flutter/src/utils/messgae_display_utils.dart';
import 'package:omise_flutter/src/widgets/rounded_text_feild.dart';

/// A page that allows users to enter their credit card payment information.
///
/// This widget provides fields for card number, name on card, expiry date,
/// security code, country or region, and optional address fields (address,
/// city, state, postal code). It also handles the logic for creating a token
/// from the provided credit card information through the Omise API.
class CreditCardPaymentMethodPage extends StatefulWidget {
  /// An instance of [OmiseApiService] for interacting with the Omise API.
  final OmiseApiService omiseApiService;

  /// Allows passing an instance of the controller to facilitate testing.
  final CreditCardPaymentMethodController? creditCardPaymentMethodController;

  /// A flag to control whether the leading icon in the AppBar is automatically implied.
  final bool automaticallyImplyLeading;

  /// The capability to enable specific features in the payment method.
  final Capability? capability;

  const CreditCardPaymentMethodPage({
    super.key,
    this.automaticallyImplyLeading = true,
    required this.omiseApiService,
    this.creditCardPaymentMethodController,
    this.capability,
  });

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

    // Load capabilities and set up listeners for token loading status.
    creditCardPaymentMethodController.loadCapabilities(
        capability: widget.capability);
    creditCardPaymentMethodController.addListener(() {
      if (creditCardPaymentMethodController.value.tokenLoadingStatus ==
          Status.error) {
        MessageDisplayUtils.showSnackBar(context,
            creditCardPaymentMethodController.value.tokenErrorMessage!);
      } else if (creditCardPaymentMethodController.value.tokenLoadingStatus ==
          Status.success) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
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
          // Display a loading indicator or an error message if necessary.
          if ([Status.loading, Status.idle]
              .contains(state.capabilityLoadingStatus)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.capabilityLoadingStatus == Status.error) {
            return Center(child: Text(state.capabilityErrorMessage!));
          }

          // Determine if the form should be enabled based on the token loading status.
          bool isFormEnabled = state.tokenLoadingStatus != Status.loading;

          return ListView(
            padding: const EdgeInsets.only(left: 20, right: 20),
            children: [
              // Card Number Input
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 20),
                child: RoundedTextField(
                  title: "Card Number",
                  validationType: ValidationType.cardNumber,
                  enabled: isFormEnabled,
                  keyboardType: TextInputType.number,
                  useValidationTypeAsKey: true,
                  onChange: (cardNumber) {
                    var newState = state.copyWith();
                    newState.createTokenRequest.number = cardNumber;
                    creditCardPaymentMethodController.updateState(newState);
                  },
                  updateValidationList: (fieldKey, isValid) {
                    creditCardPaymentMethodController
                        .setTextFieldValidityStatuses(fieldKey, isValid);
                  },
                ),
              ),

              // Name on Card Input
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: RoundedTextField(
                  title: "Name on card",
                  validationType: ValidationType.name,
                  enabled: isFormEnabled,
                  useValidationTypeAsKey: true,
                  onChange: (name) {
                    var newState = state.copyWith();
                    newState.createTokenRequest.name = name;
                    creditCardPaymentMethodController.updateState(newState);
                  },
                  updateValidationList: (fieldKey, isValid) {
                    creditCardPaymentMethodController
                        .setTextFieldValidityStatuses(fieldKey, isValid);
                  },
                ),
              ),

              // Expiry Date and Security Code Inputs
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: RoundedTextField(
                          hintText: "MM/YY",
                          title: "Expiry date",
                          validationType: ValidationType.expiryDate,
                          enabled: isFormEnabled,
                          inputFormatters: [ExpiryDateFormatter()],
                          useValidationTypeAsKey: true,
                          onChange: (expiryDate) {
                            creditCardPaymentMethodController
                                .setExpiryDate(expiryDate);
                          },
                          updateValidationList: (fieldKey, isValid) {
                            creditCardPaymentMethodController
                                .setTextFieldValidityStatuses(
                                    fieldKey, isValid);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: RoundedTextField(
                          title: "Security code",
                          validationType: ValidationType.cvv,
                          enabled: isFormEnabled,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          useValidationTypeAsKey: true,
                          onChange: (securityCode) {
                            var newState = state.copyWith();
                            newState.createTokenRequest.securityCode =
                                securityCode;
                            creditCardPaymentMethodController
                                .updateState(newState);
                          },
                          updateValidationList: (fieldKey, isValid) {
                            creditCardPaymentMethodController
                                .setTextFieldValidityStatuses(
                                    fieldKey, isValid);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Country or Region Selector
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "Country or region",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Opacity(
                opacity: isFormEnabled ? 1 : 0.5,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: GestureDetector(
                    onTap: !isFormEnabled
                        ? null
                        : () async {
                            // Show the country code picker when tapped.
                            final picked = await countryPicker.showPicker(
                                context: context);
                            if (picked != null) {
                              var newState = state.copyWith();
                              newState.createTokenRequest.country = picked.code;
                              creditCardPaymentMethodController
                                  .updateState(newState);
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        state.createTokenRequest.country != null
                            ? CountryCode.fromCode(
                                    state.createTokenRequest.country!)!
                                .name
                            : '',
                        style: const TextStyle(
                            fontSize: 16.0, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),

              // Conditional Address Fields
              if (state.shouldShowAddressFields)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: RoundedTextField(
                        title: "Address",
                        validationType: ValidationType.address,
                        enabled: isFormEnabled,
                        useValidationTypeAsKey: true,
                        onChange: (address) {
                          var newState = state.copyWith();
                          newState.createTokenRequest.street1 = address;
                          creditCardPaymentMethodController
                              .updateState(newState);
                        },
                        updateValidationList: (fieldKey, isValid) {
                          creditCardPaymentMethodController
                              .setTextFieldValidityStatuses(fieldKey, isValid);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: RoundedTextField(
                        title: "City",
                        validationType: ValidationType.city,
                        enabled: isFormEnabled,
                        useValidationTypeAsKey: true,
                        onChange: (city) {
                          var newState = state.copyWith();
                          newState.createTokenRequest.city = city;
                          creditCardPaymentMethodController
                              .updateState(newState);
                        },
                        updateValidationList: (fieldKey, isValid) {
                          creditCardPaymentMethodController
                              .setTextFieldValidityStatuses(fieldKey, isValid);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: RoundedTextField(
                        title: "State",
                        validationType: ValidationType.state,
                        enabled: isFormEnabled,
                        useValidationTypeAsKey: true,
                        onChange: (addressState) {
                          var newState = state.copyWith();
                          newState.createTokenRequest.state = addressState;
                          creditCardPaymentMethodController
                              .updateState(newState);
                        },
                        updateValidationList: (fieldKey, isValid) {
                          creditCardPaymentMethodController
                              .setTextFieldValidityStatuses(fieldKey, isValid);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: RoundedTextField(
                        title: "Postal code",
                        validationType: ValidationType.postalCode,
                        enabled: isFormEnabled,
                        useValidationTypeAsKey: true,
                        onChange: (postalCode) {
                          var newState = state.copyWith();
                          newState.createTokenRequest.postalCode = postalCode;
                          creditCardPaymentMethodController
                              .updateState(newState);
                        },
                        updateValidationList: (fieldKey, isValid) {
                          creditCardPaymentMethodController
                              .setTextFieldValidityStatuses(fieldKey, isValid);
                        },
                      ),
                    ),
                  ],
                ),

              // Submit Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: !isFormEnabled || !state.isFormValid
                      ? null
                      : () {
                          creditCardPaymentMethodController.createToken();
                        },
                  child: const Text(
                    'Pay',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
