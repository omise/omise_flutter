import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/utils/validation_utils.dart';

/// A customizable text field with rounded corners, validation, and support for various input types.
///
/// The [RoundedTextField] is a stateful widget that encapsulates a [TextField] with
/// additional features such as validation, input formatting, and dynamic error messages.
/// It can be used in forms where user input needs to be validated against specific
/// criteria (defined by [ValidationType]).
class RoundedTextField extends StatefulWidget {
  /// Creates a [RoundedTextField].
  ///
  /// The [validationType] parameter is required to specify the type of validation
  /// to be applied to the input. All other parameters are optional.
  const RoundedTextField({
    super.key,
    this.controller,
    this.title,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.validationType,
    this.hintText,
    this.onChange,
    this.enabled = true,
    this.inputFormatters,
    this.updateValidationList,
    this.useValidationTypeAsKey = false,
    this.isOptional = false,
  });

  /// An optional controller for controlling the text being edited.
  final TextEditingController? controller;

  /// An optional title for the text field, displayed above it.
  final String? title;

  /// The type of keyboard to use for this text field, defaults to [TextInputType.text].
  final TextInputType keyboardType;

  /// If true, the text field will obscure the text being entered (e.g., for passwords).
  final bool obscureText;

  /// The validation type to be applied to the input.
  final ValidationType validationType;

  /// An optional hint text displayed when the field is empty.
  final String? hintText;

  /// Whether the text field is enabled or disabled. Defaults to true.
  final bool? enabled;

  /// An optional list of input formatters to be applied to the input.
  final List<TextInputFormatter>? inputFormatters;

  /// A callback function invoked when the text in the field changes.
  final Function(String)? onChange;

  /// A callback function used to update the validation status in the parent widget.
  final Function(String, bool)? updateValidationList;

  /// If true, the [validationType] will be used as the key for error validation.
  final bool? useValidationTypeAsKey;

  /// Is the field optional
  final bool? isOptional;

  @override
  State<RoundedTextField> createState() => _RoundedTextFieldState();
}

class _RoundedTextFieldState extends State<RoundedTextField> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the title if it is provided
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.title!,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        TextField(
          // Use validationType as key if specified to ensure that all text fields will hold unique keys for the updateValidationList function to work properly.
          key: widget.useValidationTypeAsKey == true
              ? Key(widget.validationType.name)
              : null,
          enabled: widget.enabled,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 2.0,
              ),
            ),
            errorText: _errorMessage,
          ),
          onChanged: (value) {
            setState(() {
              // Validate input and set error message if any
              _errorMessage = ValidationUtils.validateInput(
                validationType: widget.validationType,
                value: value,
                context: context,
                isOptional: widget.isOptional,
              );
            });
            // Update validation status in parent widget
            if (widget.updateValidationList != null) {
              if (_errorMessage == null) {
                widget.updateValidationList!(widget.validationType.name, true);
              } else {
                widget.updateValidationList!(widget.validationType.name, false);
              }
            }
            // Call onChange callback if provided
            if (widget.onChange != null) {
              widget.onChange!(value);
            }
          },
        ),
      ],
    );
  }
}
