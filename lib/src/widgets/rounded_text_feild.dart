import 'package:flutter/material.dart';

enum ValidationType {
  cardNumber,
  name,
  expiryDate,
  cvv,
}

class RoundedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? title;
  final TextInputType keyboardType;
  final bool obscureText;
  final ValidationType validationType;

  const RoundedTextField({
    super.key,
    this.controller,
    this.title,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.validationType,
  });

  @override
  _RoundedTextFieldState createState() => _RoundedTextFieldState();
}

class _RoundedTextFieldState extends State<RoundedTextField> {
  String? _errorMessage;

  // Validation functions
  String? _validateInput(String? value) {
    switch (widget.validationType) {
      case ValidationType.cardNumber:
        return _validateCardNumber(value);
      case ValidationType.name:
        return _validateName(value);
      case ValidationType.expiryDate:
        return _validateExpiryDate(value);
      case ValidationType.cvv:
        return _validateCVV(value);
      default:
        return null;
    }
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    } else if (value.length != 16) {
      return 'Card number must be 16 digits';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    } else if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    } else {
      // Expiry date validation logic, e.g., MM/YY format
      RegExp regExp = RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$');
      if (!regExp.hasMatch(value)) {
        return 'Expiry date must be in MM/YY format';
      }
    }
    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    } else if (value.length != 3) {
      return 'CVV must be 3 digits';
    }
    return null;
  }

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
              _errorMessage = _validateInput(value);
            });
          },
        ),
      ],
    );
  }
}
