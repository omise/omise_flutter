import 'package:flutter/material.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/controllers/econtext_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/omise_payment_result.dart';
import 'package:omise_flutter/src/services/method_channel_service.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:omise_flutter/src/utils/message_display_utils.dart';
import 'package:omise_flutter/src/widgets/rounded_text_field.dart';

class EcontextPage extends StatefulWidget {
  /// The amount that will be used to create a source.
  final int amount;

  /// The currency that will be used to create a source.
  final Currency currency;

  /// The custom locale passed by the merchant.
  final OmiseLocale? locale;

  /// An instance of [OmiseApiService] for interacting with the Omise API.
  final OmiseApiService omiseApiService;

  /// The selected econtext payment method.
  final CustomPaymentMethod econtextMethod;

  final EcontextController? econtextController;

  /// The function name that is communicated through channels methods for native integrations.
  final String? nativeResultMethodName;

  const EcontextPage({
    super.key,
    this.locale,
    this.econtextController,
    required this.omiseApiService,
    required this.amount,
    required this.currency,
    required this.econtextMethod,
    this.nativeResultMethodName,
  });

  @override
  State<EcontextPage> createState() => _EcontextPageState();
}

class _EcontextPageState extends State<EcontextPage> {
  late final EcontextController econtextController =
      widget.econtextController ??
          EcontextController(
            omiseApiService: widget.omiseApiService,
          );
  @override
  void initState() {
    super.initState();
    econtextController.setSourceCreationParams(
      amount: widget.amount,
      currency: widget.currency,
    );
    econtextController.addListener(() {
      if (econtextController.value.sourceLoadingStatus == Status.error) {
        MessageDisplayUtils.showSnackBar(
            context, econtextController.value.sourceErrorMessage!);
        // reset the status so that the snackbar does not appear every time the user types
        econtextController.updateState(econtextController.value
            .copyWith(sourceLoadingStatus: Status.idle));
      } else if (econtextController.value.sourceLoadingStatus ==
          Status.success) {
        final omisePaymentResult =
            OmisePaymentResult(source: econtextController.value.source);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.get(widget.econtextMethod.name, widget.locale, context),
        ),
        centerTitle: false,
      ),
      body: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, top: 40),
          child: ValueListenableBuilder(
              valueListenable: econtextController,
              builder: (context, state, _) {
                bool isNextButtonEnabled =
                    state.sourceLoadingStatus != Status.loading;
                final keys = state.textFieldValidityStatuses.keys.toList();

                bool fieldsNotValid = !keys
                        .contains(ValidationType.phoneNumber.name) ||
                    !keys.contains(ValidationType.name.name) ||
                    !keys.contains(ValidationType.email.name) ||
                    state.textFieldValidityStatuses.values.contains(false) ||
                    state.textFieldValidityStatuses.isEmpty;
                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: RoundedTextField(
                        useValidationTypeAsKey: true,
                        title: Translations.get('name', widget.locale, context),
                        validationType: ValidationType.name,
                        keyboardType: TextInputType.name,
                        enabled: isNextButtonEnabled,
                        onChange: (name) {
                          var newState = state.copyWith();
                          if (name.trim().isEmpty) {
                            newState.createSourceRequest!.name = null;
                          } else {
                            newState.createSourceRequest!.name = name.trim();
                          }
                          econtextController.updateState(newState);
                        },
                        updateValidationList: (fieldKey, isValid) {
                          econtextController.setTextFieldValidityStatuses(
                              fieldKey, isValid);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: RoundedTextField(
                        useValidationTypeAsKey: true,
                        title:
                            Translations.get('email', widget.locale, context),
                        validationType: ValidationType.email,
                        keyboardType: TextInputType.emailAddress,
                        enabled: isNextButtonEnabled,
                        onChange: (email) {
                          var newState = state.copyWith();
                          if (email.trim().isEmpty) {
                            newState.createSourceRequest!.email = null;
                          } else {
                            newState.createSourceRequest!.email = email.trim();
                          }
                          econtextController.updateState(newState);
                        },
                        updateValidationList: (fieldKey, isValid) {
                          econtextController.setTextFieldValidityStatuses(
                              fieldKey, isValid);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: RoundedTextField(
                        useValidationTypeAsKey: true,
                        title:
                            Translations.get('phone', widget.locale, context),
                        validationType: ValidationType.phoneNumber,
                        keyboardType: TextInputType.phone,
                        enabled: isNextButtonEnabled,
                        onChange: (phone) {
                          var newState = state.copyWith();
                          if (phone.trim().isEmpty) {
                            newState.createSourceRequest!.phoneNumber = null;
                          } else {
                            newState.createSourceRequest!.phoneNumber =
                                phone.trim();
                          }
                          econtextController.updateState(newState);
                        },
                        updateValidationList: (fieldKey, isValid) {
                          econtextController.setTextFieldValidityStatuses(
                              fieldKey, isValid);
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: (isNextButtonEnabled && !fieldsNotValid)
                                ? () {
                                    econtextController.createSource();
                                  }
                                : null,
                            child: Text(
                              Translations.get('next', widget.locale, context),
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                );
              })),
    );
  }
}
