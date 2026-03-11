import 'package:flutter/services.dart';
import 'package:omise_flutter/src/models/card_brand.dart';

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Retain only numeric characters
    String numericText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Attempt to identify the active card brand
    final brand = CardBrand.getActiveBrand(numericText);

    // Determine the grouping pattern and max length based on the card brand
    List<int> groupLengths = [4, 4, 4, 4, 4]; // Default: 4-4-4-4-X grouping
    int maxLength = 19; // Safe default upper limit

    if (brand == CardBrand.amex) {
      groupLengths = [4, 6, 5];
      maxLength = 15;
    } else if (brand == CardBrand.diners) {
      groupLengths = [4, 6, 4];
      maxLength = 14;
    } else if (brand != null) {
      maxLength = brand.maxLength;
    }

    if (numericText.length > maxLength) {
      numericText = numericText.substring(0, maxLength);
    }

    String formattedText = '';
    int currentIdx = 0;
    for (int length in groupLengths) {
      if (currentIdx >= numericText.length) break;
      int endIdx = currentIdx + length;
      if (endIdx > numericText.length) endIdx = numericText.length;

      formattedText += numericText.substring(currentIdx, endIdx);
      currentIdx = endIdx;

      if (currentIdx < numericText.length) {
        formattedText += ' ';
      }
    }

    // Calculate cursor position after formatting
    int nonSpaceCount = 0;
    int cursorPosition = newValue.selection.end;
    if (cursorPosition < 0) {
      cursorPosition = newValue.text.length;
    }

    for (int i = 0; i < newValue.text.length && i < cursorPosition; i++) {
      if (newValue.text[i] != ' ') {
        nonSpaceCount++;
      }
    }

    int finalCursorPosition = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (nonSpaceCount == 0) break;
      if (formattedText[i] != ' ') {
        nonSpaceCount--;
      }
      finalCursorPosition++;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: finalCursorPosition),
    );
  }
}
