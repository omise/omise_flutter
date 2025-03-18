import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/atome_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/omise_payment_result.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:omise_flutter/src/utils/message_display_utils.dart';
import 'package:omise_flutter/src/utils/package_info.dart';
import 'package:omise_flutter/src/widgets/rounded_text_field.dart';

class AtomePage extends StatefulWidget {
  /// The amount that will be used to create a source.
  final int amount;

  /// The currency that will be used to create a source.
  final Currency currency;

  /// The custom locale passed by the merchant.
  final OmiseLocale? locale;

  /// An instance of [OmiseApiService] for interacting with the Omise API.
  final OmiseApiService omiseApiService;

  /// Allows passing an instance of the controller to facilitate testing.
  final AtomeController? atomeController;

  /// The list of items in the atome payment.
  final List<Item> items;

  const AtomePage({
    super.key,
    required this.omiseApiService,
    required this.amount,
    required this.currency,
    required this.items,
    this.atomeController,
    this.locale,
  });

  @override
  State<AtomePage> createState() => _AtomePageState();
}

class _AtomePageState extends State<AtomePage> {
  late final AtomeController atomeController = widget.atomeController ??
      AtomeController(
        omiseApiService: widget.omiseApiService,
      );
  @override
  void initState() {
    super.initState();
    atomeController.setSourceCreationParams(
        amount: widget.amount, currency: widget.currency, items: widget.items);
    atomeController.addListener(() {
      if (atomeController.value.sourceLoadingStatus == Status.error) {
        MessageDisplayUtils.showSnackBar(
            context, atomeController.value.sourceErrorMessage!);
        // reset the status so that the snackbar does not appear every time the user types
        atomeController.updateState(
            atomeController.value.copyWith(sourceLoadingStatus: Status.idle));
      } else if (atomeController.value.sourceLoadingStatus == Status.success) {
        while (Navigator.of(context).canPop()) {
          Navigator.of(context)
              .pop(OmisePaymentResult(source: atomeController.value.source));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.get('atome', widget.locale, context),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20,
        ),
        child: ListView(
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.1),
              child: Image.asset(
                'assets/atome.png',
                width: MediaQuery.of(context).size.width * 0.65,
                height: MediaQuery.of(context).size.height * 0.12,
                package: PackageInfo.packageName,
                alignment: Alignment.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.04,
                  top: MediaQuery.of(context).size.height * 0.04),
              child: Text(
                  Translations.get('atomeInfoText', widget.locale, context)),
            ),
            // The Form widget is not used as we want field by field validation and not all fields to be validated at the same time
            // since this will result in fields highlighted as invalid but the user did not enter anything yet in those fields which is not the best experience.
            ValueListenableBuilder(
                valueListenable: atomeController,
                builder: (context, state, _) {
                  // Determine if the form should be enabled based on the token loading status.
                  bool isFormEnabled =
                      state.sourceLoadingStatus != Status.loading;
                  final keys = state.textFieldValidityStatuses.keys.toList();
                  bool fieldsNotValid = !keys
                          .contains(ValidationType.phoneNumber.name) ||
                      !keys.contains(ValidationType.address.name) ||
                      !keys.contains(ValidationType.postalCode.name) ||
                      !keys.contains(ValidationType.city.name) ||
                      !keys.contains(ValidationType.countryCode.name) ||
                      state.textFieldValidityStatuses.values.contains(false) ||
                      state.textFieldValidityStatuses.isEmpty;
                  return Opacity(
                    opacity: isFormEnabled ? 1 : 0.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: RoundedTextField(
                            key: Key(ValidationType.name.name),
                            enabled: isFormEnabled,
                            isOptional: true,
                            title: Translations.get(
                                'nameOptional', widget.locale, context),
                            validationType: ValidationType.name,
                            keyboardType: TextInputType.name,
                            onChange: (name) {
                              var newState = state.copyWith();
                              if (name.trim().isEmpty) {
                                newState.createSourceRequest!.name = null;
                              } else {
                                newState.createSourceRequest!.name =
                                    name.trim();
                              }
                              atomeController.updateState(newState);
                            },
                            updateValidationList: (fieldKey, isValid) {
                              atomeController.setTextFieldValidityStatuses(
                                  fieldKey, isValid);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: RoundedTextField(
                            key: Key(ValidationType.email.name),
                            enabled: isFormEnabled,
                            isOptional: true,
                            title: Translations.get(
                                'emailOptional', widget.locale, context),
                            validationType: ValidationType.email,
                            keyboardType: TextInputType.emailAddress,
                            onChange: (email) {
                              var newState = state.copyWith();
                              if (email.trim().isEmpty) {
                                newState.createSourceRequest!.email = null;
                              } else {
                                newState.createSourceRequest!.email =
                                    email.trim();
                              }
                              atomeController.updateState(newState);
                            },
                            updateValidationList: (fieldKey, isValid) {
                              atomeController.setTextFieldValidityStatuses(
                                  fieldKey, isValid);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: RoundedTextField(
                            key: Key(ValidationType.phoneNumber.name),
                            enabled: isFormEnabled,
                            title: Translations.get(
                                'phone', widget.locale, context),
                            validationType: ValidationType.phoneNumber,
                            keyboardType: TextInputType.phone,
                            onChange: (phoneNumber) {
                              var newState = state.copyWith();
                              if (phoneNumber.trim().isEmpty) {
                                newState.createSourceRequest!.phoneNumber =
                                    null;
                              } else {
                                newState.createSourceRequest!.phoneNumber =
                                    phoneNumber.trim();
                              }
                              atomeController.updateState(newState);
                            },
                            updateValidationList: (fieldKey, isValid) {
                              atomeController.setTextFieldValidityStatuses(
                                  fieldKey, isValid);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Opacity(
                            opacity: 0.5,
                            child: Text(
                              Translations.get(
                                  'shippingAddress', widget.locale, context),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: RoundedTextField(
                            key: Key(ValidationType.address.name),
                            enabled: isFormEnabled,
                            title: Translations.get(
                                'street', widget.locale, context),
                            validationType: ValidationType.address,
                            keyboardType: TextInputType.streetAddress,
                            onChange: (street) {
                              var newState = state.copyWith();
                              if (street.trim().isEmpty) {
                                newState.createSourceRequest!.shipping!
                                    .street1 = null;
                              } else {
                                newState.createSourceRequest!.shipping!
                                    .street1 = street.trim();
                              }
                              atomeController.updateState(newState);
                            },
                            updateValidationList: (fieldKey, isValid) {
                              atomeController.setTextFieldValidityStatuses(
                                  fieldKey, isValid);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: RoundedTextField(
                            key: Key(ValidationType.postalCode.name),
                            enabled: isFormEnabled,
                            title: Translations.get(
                                'postalCode', widget.locale, context),
                            validationType: ValidationType.postalCode,
                            keyboardType: TextInputType.phone,
                            onChange: (postalCode) {
                              var newState = state.copyWith();
                              if (postalCode.trim().isEmpty) {
                                newState.createSourceRequest!.shipping!
                                    .postalCode = null;
                              } else {
                                newState.createSourceRequest!.shipping!
                                    .postalCode = postalCode.trim();
                              }
                              atomeController.updateState(newState);
                            },
                            updateValidationList: (fieldKey, isValid) {
                              atomeController.setTextFieldValidityStatuses(
                                  fieldKey, isValid);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: RoundedTextField(
                            key: Key(ValidationType.city.name),
                            enabled: isFormEnabled,
                            title: Translations.get(
                                'city', widget.locale, context),
                            validationType: ValidationType.city,
                            keyboardType: TextInputType.text,
                            onChange: (city) {
                              var newState = state.copyWith();
                              if (city.trim().isEmpty) {
                                newState.createSourceRequest!.shipping!.city =
                                    null;
                              } else {
                                newState.createSourceRequest!.shipping!.city =
                                    city.trim();
                              }
                              atomeController.updateState(newState);
                            },
                            updateValidationList: (fieldKey, isValid) {
                              atomeController.setTextFieldValidityStatuses(
                                  fieldKey, isValid);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: RoundedTextField(
                            key: Key(ValidationType.countryCode.name),
                            enabled: isFormEnabled,
                            title: Translations.get(
                                'countryCode', widget.locale, context),
                            validationType: ValidationType.countryCode,
                            keyboardType: TextInputType.phone,
                            onChange: (countryCode) {
                              var newState = state.copyWith();
                              if (countryCode.trim().isEmpty) {
                                newState.createSourceRequest!.shipping!
                                    .country = null;
                              } else {
                                newState.createSourceRequest!.shipping!
                                    .country = countryCode.trim();
                              }
                              atomeController.updateState(newState);
                            },
                            updateValidationList: (fieldKey, isValid) {
                              atomeController.setTextFieldValidityStatuses(
                                  fieldKey, isValid);
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                                key: const Key('checkBox'),
                                value: state.shippingSameAsBilling,
                                onChanged: (same) {
                                  atomeController
                                      .setShippingSameAsBilling(same);
                                }),
                            Text(Translations.get('sameBillingAndShipping',
                                widget.locale, context))
                          ],
                        ),
                        if (!state.shippingSameAsBilling)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Opacity(
                                  opacity: 0.5,
                                  child: Text(
                                    Translations.get('billingAddressOptional',
                                        widget.locale, context),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: RoundedTextField(
                                  key: Key(
                                      '${ValidationType.address.name}_billing'),
                                  enabled: isFormEnabled,
                                  isOptional: true,
                                  title: Translations.get(
                                      'street', widget.locale, context),
                                  validationType: ValidationType.address,
                                  keyboardType: TextInputType.phone,
                                  onChange: (street) {
                                    var newState = state.copyWith();
                                    if (street.trim().isEmpty) {
                                      newState.createSourceRequest!.billing!
                                          .street1 = null;
                                    } else {
                                      newState.createSourceRequest!.billing!
                                          .street1 = street.trim();
                                    }
                                    atomeController.updateState(newState);
                                  },
                                  updateValidationList: (fieldKey, isValid) {
                                    atomeController
                                        .setTextFieldValidityStatuses(
                                            '${fieldKey}_billing', isValid);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: RoundedTextField(
                                  key: Key(
                                      '${ValidationType.postalCode.name}_billing'),
                                  enabled: isFormEnabled,
                                  isOptional: true,
                                  title: Translations.get(
                                      'postalCode', widget.locale, context),
                                  validationType: ValidationType.postalCode,
                                  keyboardType: TextInputType.phone,
                                  onChange: (postalCode) {
                                    var newState = state.copyWith();
                                    if (postalCode.trim().isEmpty) {
                                      newState.createSourceRequest!.billing!
                                          .postalCode = null;
                                    } else {
                                      newState.createSourceRequest!.billing!
                                          .postalCode = postalCode.trim();
                                    }
                                    atomeController.updateState(newState);
                                  },
                                  updateValidationList: (fieldKey, isValid) {
                                    atomeController
                                        .setTextFieldValidityStatuses(
                                            '${fieldKey}_billing', isValid);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: RoundedTextField(
                                  key: Key(
                                      '${ValidationType.city.name}_billing'),
                                  enabled: isFormEnabled,
                                  isOptional: true,
                                  title: Translations.get(
                                      'city', widget.locale, context),
                                  validationType: ValidationType.city,
                                  keyboardType: TextInputType.phone,
                                  onChange: (city) {
                                    var newState = state.copyWith();
                                    if (city.trim().isEmpty) {
                                      newState.createSourceRequest!.billing!
                                          .city = null;
                                    } else {
                                      newState.createSourceRequest!.billing!
                                          .city = city.trim();
                                    }
                                    atomeController.updateState(newState);
                                  },
                                  updateValidationList: (fieldKey, isValid) {
                                    atomeController
                                        .setTextFieldValidityStatuses(
                                            '${fieldKey}_billing', isValid);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: RoundedTextField(
                                  key: Key(
                                      '${ValidationType.countryCode.name}_billing'),
                                  enabled: isFormEnabled,
                                  isOptional: true,
                                  title: Translations.get(
                                      'countryCode', widget.locale, context),
                                  validationType: ValidationType.countryCode,
                                  keyboardType: TextInputType.phone,
                                  onChange: (countryCode) {
                                    var newState = state.copyWith();
                                    if (countryCode.trim().isEmpty) {
                                      newState.createSourceRequest!.billing!
                                          .country = null;
                                    } else {
                                      newState.createSourceRequest!.billing!
                                          .country = countryCode.trim();
                                    }
                                    atomeController.updateState(newState);
                                  },
                                  updateValidationList: (fieldKey, isValid) {
                                    atomeController
                                        .setTextFieldValidityStatuses(
                                            '${fieldKey}_billing', isValid);
                                  },
                                ),
                              ),
                            ],
                          ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  onPressed: !fieldsNotValid && isFormEnabled
                                      ? () {
                                          atomeController.createSource();
                                        }
                                      : null,
                                  child: Text(
                                    Translations.get(
                                        'next', widget.locale, context),
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
