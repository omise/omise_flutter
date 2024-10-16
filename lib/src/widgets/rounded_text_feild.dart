import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/utils/validation_utils.dart';

class RoundedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? title;
  final TextInputType keyboardType;
  final bool obscureText;
  final ValidationType validationType;
  final String? hintText;
  final bool? enabled;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChange;
  final Function(String, bool)? updateValidationList;
  final bool? useValidationTypeAsKey;

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
  });

  @override
  _RoundedTextFieldState createState() => _RoundedTextFieldState();
}

class _RoundedTextFieldState extends State<RoundedTextField> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              _errorMessage =
                  ValidationUtils.validateInput(widget.validationType, value);
            });
            if (widget.updateValidationList != null) {
              if (_errorMessage == null) {
                widget.updateValidationList!(widget.validationType.name, true);
              } else {
                widget.updateValidationList!(widget.validationType.name, false);
              }
            }
            if (widget.onChange != null) {
              widget.onChange!(value);
            }
          },
        ),
      ],
    );
  }
}
