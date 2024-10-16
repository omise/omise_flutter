import 'package:flutter/material.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/utils/validationUtils.dart';

class RoundedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? title;
  final TextInputType keyboardType;
  final bool obscureText;
  final ValidationType validationType;
  final String? hintText;
  final Function(String)? onChange; // Passes the text as an argument

  const RoundedTextField({
    super.key,
    this.controller,
    this.title,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.validationType,
    this.hintText,
    this.onChange,
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
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
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
            if (widget.onChange != null) {
              widget.onChange!(value);
            }
          },
        ),
      ],
    );
  }
}
