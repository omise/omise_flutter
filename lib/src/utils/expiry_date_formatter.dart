import 'package:flutter/services.dart';

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Handle deletion, allow removal of the `/`
    if (newValue.selection.baseOffset < oldValue.selection.baseOffset) {
      return newValue;
    }

    if (newText.length > 4) {
      newText = newText.substring(0, 4); // Keep the first 4 characters (MMYY)
    }

    // Format the text as MM/YY
    String formattedText = '';
    if (newText.length >= 2) {
      formattedText = '${newText.substring(0, 2)}/${newText.substring(2)}';
    } else {
      formattedText = newText;
    }

    // Return the new value with the proper selection position
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
