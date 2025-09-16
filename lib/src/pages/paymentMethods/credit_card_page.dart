import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/credit_card_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/omise_payment_result.dart';
import 'package:omise_flutter/src/services/method_channel_service.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:omise_flutter/src/utils/expiry_date_formatter.dart';
import 'package:omise_flutter/src/utils/message_display_utils.dart';
import 'package:omise_flutter/src/widgets/rounded_text_field.dart';

/// A page that allows users to enter their credit card payment information.
///
/// This widget provides fields for card number, name on card, expiry date,
/// security code, country or region, and optional address fields (address,
/// city, state, postal code). It also handles the logic for creating a token
/// from the provided credit card information through the Omise API.
class CreditCardPage extends StatefulWidget {
  /// An instance of [OmiseApiService] for interacting with the Omise API.
  final OmiseApiService omiseApiService;

  /// Allows passing an instance of the controller to facilitate testing.
  final CreditCardController? creditCardPaymentMethodController;

  /// A flag to control whether the leading icon in the AppBar is automatically implied.
  final bool automaticallyImplyLeading;

  /// The capability to enable specific features in the payment method.
  final Capability? capability;

  /// The custom locale passed by the merchant.
  final OmiseLocale? locale;

  /// The payment method selected if coming from wlb installments screen
  final PaymentMethodName? paymentMethod;

  /// The currency if coming from wlb installments screen
  final Currency? currency;

  /// The amount if coming from wlb installments screen
  final int? amount;

  /// The term if coming from wlb installments screen
  final int? term;

  /// The function name that is communicated through channels methods for native integrations.
  final String? nativeResultMethodName;

  /// Stores information about the cardholder required for passkey-based authentication flows.
  final List<CardHolderData>? cardHolderData;

  const CreditCardPage({
    super.key,
    this.automaticallyImplyLeading = true,
    required this.omiseApiService,
    this.creditCardPaymentMethodController,
    this.capability,
    this.paymentMethod,
    this.locale,
    this.currency,
    this.amount,
    this.term,
    this.nativeResultMethodName,
    this.cardHolderData,
  });

  @override
  State<CreditCardPage> createState() => _CreditCardPageState();
}

class _CreditCardPageState extends State<CreditCardPage> {
  final countryPicker = const FlCountryCodePicker();

  /// The controller responsible for fetching and filtering payment methods.
  late final CreditCardController creditCardController =
      widget.creditCardPaymentMethodController ??
          CreditCardController(
            omiseApiService: widget.omiseApiService,
          );
  final expiryDateTextController = TextEditingController();
  final securityCodeTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // set the source parameters when dealing with wlb installments
    creditCardController.setInstallmentsSourceParameters(
        amount: widget.amount,
        currency: widget.currency,
        paymentMethod: widget.paymentMethod,
        term: widget.term);
    creditCardController.setCardHolderData(
        cardHolderData: widget.cardHolderData);

    // Load capabilities and set up listeners for token loading status.
    creditCardController.loadCapabilities(capability: widget.capability);
    creditCardController.addListener(() {
      if (creditCardController.value.tokenAndSourceLoadingStatus ==
          Status.error) {
        MessageDisplayUtils.showSnackBar(
            context, creditCardController.value.tokenAndSourceErrorMessage!);
        // reset the status so that the snackbar does not appear every time the user types
        creditCardController.updateState(creditCardController.value
            .copyWith(tokenAndSourceLoadingStatus: Status.idle));
      } else if (creditCardController.value.tokenAndSourceLoadingStatus ==
          Status.success) {
        final omisePaymentResult = OmisePaymentResult(
            token: creditCardController.value.token,
            source: creditCardController.value.source);
        if (widget.nativeResultMethodName != null) {
          MethodChannelService.sendResultToNative(
            widget.nativeResultMethodName!,
            omisePaymentResult.toJson(),
          );
        } else {
          while (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(omisePaymentResult);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    expiryDateTextController.dispose();
    securityCodeTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.get('card', widget.locale, context)),
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        centerTitle: false,
        actions: [
          if (!widget.automaticallyImplyLeading)
            IconButton(
              onPressed: () {
                // Close the page when the 'X' icon is pressed
                if (widget.nativeResultMethodName != null) {
                  MethodChannelService.sendResultToNative(
                      widget.nativeResultMethodName!, null);
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.close),
            )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: creditCardController,
        builder: (context, state, _) {
          // Display a loading indicator or an error message if necessary.
          if ([Status.loading, Status.idle]
              .contains(state.capabilityLoadingStatus)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.capabilityLoadingStatus == Status.error) {
            return Center(child: Text(state.capabilityErrorMessage!));
          }

          // Determine if the form should be enabled based on the token loading status.
          bool isFormEnabled =
              state.tokenAndSourceLoadingStatus != Status.loading;

          return ListView(
            padding: const EdgeInsets.only(left: 20, right: 20),
            children: [
              // Card Number Input
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 20),
                child: RoundedTextField(
                  title: Translations.get('cardNumber', widget.locale, context),
                  validationType: ValidationType.cardNumber,
                  enabled: isFormEnabled,
                  keyboardType: TextInputType.number,
                  useValidationTypeAsKey: true,
                  onChange: (cardNumber) {
                    var newState = state.copyWith();
                    newState.createTokenRequest.number = cardNumber;
                    if (state.isLoanCard) {
                      expiryDateTextController.text = '';
                      securityCodeTextController.text = '';
                      newState = state.copyWith();
                      newState.createTokenRequest.expirationMonth = null;
                      newState.createTokenRequest.expirationYear = null;
                      newState.createTokenRequest.securityCode = null;
                      newState.textFieldValidityStatuses
                          .remove(ValidationType.cvv.name);
                      newState.textFieldValidityStatuses
                          .remove(ValidationType.expiryDate.name);
                    }
                    creditCardController.updateState(newState);
                  },
                  updateValidationList: (fieldKey, isValid) {
                    creditCardController.setTextFieldValidityStatuses(
                        fieldKey, isValid);
                  },
                ),
              ),

              // Name on Card Input
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: RoundedTextField(
                  title: Translations.get('nameOnCard', widget.locale, context),
                  validationType: ValidationType.name,
                  enabled: isFormEnabled,
                  useValidationTypeAsKey: true,
                  onChange: (name) {
                    var newState = state.copyWith();
                    newState.createTokenRequest.name = name;
                    creditCardController.updateState(newState);
                  },
                  updateValidationList: (fieldKey, isValid) {
                    creditCardController.setTextFieldValidityStatuses(
                        fieldKey, isValid);
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
                          controller: expiryDateTextController,
                          hintText: Translations.get(
                              'hintExpiry', widget.locale, context),
                          title: Translations.get(
                              'expiryDate', widget.locale, context),
                          validationType: ValidationType.expiryDate,
                          enabled: state.isLoanCard ? false : isFormEnabled,
                          inputFormatters: [ExpiryDateFormatter()],
                          useValidationTypeAsKey: true,
                          onChange: (expiryDate) {
                            creditCardController.setExpiryDate(expiryDate);
                          },
                          updateValidationList: (fieldKey, isValid) {
                            creditCardController.setTextFieldValidityStatuses(
                                fieldKey, isValid);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: RoundedTextField(
                          controller: securityCodeTextController,
                          title: Translations.get(
                              'securityCode', widget.locale, context),
                          validationType: ValidationType.cvv,
                          enabled: state.isLoanCard ? false : isFormEnabled,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          useValidationTypeAsKey: true,
                          onChange: (securityCode) {
                            var newState = state.copyWith();
                            newState.createTokenRequest.securityCode =
                                securityCode;
                            creditCardController.updateState(newState);
                          },
                          updateValidationList: (fieldKey, isValid) {
                            creditCardController.setTextFieldValidityStatuses(
                                fieldKey, isValid);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Country or Region Selector
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  Translations.get('countryRegion', widget.locale, context),
                  style: const TextStyle(fontSize: 16),
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
                              creditCardController.updateState(newState);
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
              if (state.cardHolderData?.contains(CardHolderData.email) == true)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: RoundedTextField(
                    key: Key(ValidationType.email.name),
                    enabled: isFormEnabled,
                    isOptional: true,
                    title: Translations.get('email', widget.locale, context),
                    validationType: ValidationType.email,
                    keyboardType: TextInputType.emailAddress,
                    onChange: (email) {
                      var newState = state.copyWith();
                      newState.createTokenRequest.email =
                          email.isEmpty ? null : email;
                      creditCardController.updateState(newState);
                    },
                    updateValidationList: (fieldKey, isValid) {
                      creditCardController.setTextFieldValidityStatuses(
                          fieldKey, isValid,
                          keyValue: state.createTokenRequest.email);
                    },
                  ),
                ),
              if (state.cardHolderData?.contains(CardHolderData.phoneNumber) ==
                  true)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: RoundedTextField(
                    key: Key(ValidationType.phoneNumber.name),
                    enabled: isFormEnabled,
                    title: Translations.get('phone', widget.locale, context),
                    validationType: ValidationType.phoneNumber,
                    keyboardType: TextInputType.phone,
                    onChange: (phoneNumber) {
                      var newState = state.copyWith();
                      newState.createTokenRequest.phoneNumber =
                          phoneNumber.isEmpty ? null : phoneNumber;
                      creditCardController.updateState(newState);
                    },
                    updateValidationList: (fieldKey, isValid) {
                      creditCardController.setTextFieldValidityStatuses(
                          fieldKey, isValid,
                          keyValue: state.createTokenRequest.phoneNumber);
                    },
                  ),
                ),
              // Conditional Address Fields
              if (state.shouldShowAddressFields)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: RoundedTextField(
                        title: Translations.get(ValidationType.address.name,
                            widget.locale, context),
                        validationType: ValidationType.address,
                        enabled: isFormEnabled,
                        useValidationTypeAsKey: true,
                        onChange: (address) {
                          var newState = state.copyWith();
                          newState.createTokenRequest.street1 = address;
                          creditCardController.updateState(newState);
                        },
                        updateValidationList: (fieldKey, isValid) {
                          creditCardController.setTextFieldValidityStatuses(
                              fieldKey, isValid);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: RoundedTextField(
                        title: Translations.get(
                            ValidationType.city.name, widget.locale, context),
                        validationType: ValidationType.city,
                        enabled: isFormEnabled,
                        useValidationTypeAsKey: true,
                        onChange: (city) {
                          var newState = state.copyWith();
                          newState.createTokenRequest.city = city;
                          creditCardController.updateState(newState);
                        },
                        updateValidationList: (fieldKey, isValid) {
                          creditCardController.setTextFieldValidityStatuses(
                              fieldKey, isValid);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: RoundedTextField(
                        title:
                            Translations.get('state', widget.locale, context),
                        validationType: ValidationType.state,
                        enabled: isFormEnabled,
                        useValidationTypeAsKey: true,
                        onChange: (addressState) {
                          var newState = state.copyWith();
                          newState.createTokenRequest.state = addressState;
                          creditCardController.updateState(newState);
                        },
                        updateValidationList: (fieldKey, isValid) {
                          creditCardController.setTextFieldValidityStatuses(
                              fieldKey, isValid);
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
                          creditCardController.updateState(newState);
                        },
                        updateValidationList: (fieldKey, isValid) {
                          creditCardController.setTextFieldValidityStatuses(
                              fieldKey, isValid);
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
                          creditCardController.createSourceAndToken();
                        },
                  child: Text(
                    Translations.get('pay', widget.locale, context),
                    style: const TextStyle(
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
