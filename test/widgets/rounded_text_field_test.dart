import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/widgets/rounded_text_feild.dart';

void main() {
  testWidgets('RoundedTextField renders correctly',
      (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoundedTextField(
            controller: controller,
            validationType: ValidationType.name,
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Error message is displayed when input is invalid',
      (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoundedTextField(
            controller: controller,
            validationType: ValidationType.name,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), ' ');
    await tester.pump();

    expect(find.text('Name is required'), findsOneWidget);
  });

  testWidgets('onChange is called when text is updated',
      (WidgetTester tester) async {
    final controller = TextEditingController();
    String changedText = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoundedTextField(
            controller: controller,
            validationType: ValidationType.name,
            onChange: (value) {
              changedText = value;
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'NewName');
    await tester.pump();

    expect(changedText, 'NewName');
  });

  testWidgets('TextField is disabled when enabled is set to false',
      (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoundedTextField(
            controller: controller,
            validationType: ValidationType.name,
            enabled: false,
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, false);
  });

  testWidgets(
      'updateValidationList is called with correct arguments on valid input',
      (WidgetTester tester) async {
    final controller = TextEditingController();
    bool? validationResult;
    String? validationKey;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoundedTextField(
            controller: controller,
            validationType: ValidationType.name,
            updateValidationList: (key, isValid) {
              validationKey = key;
              validationResult = isValid;
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'ValidName');
    await tester.pump();

    expect(validationKey, ValidationType.name.name);
    expect(validationResult, true); // Assuming 'ValidName' is a valid name.
  });

  testWidgets('InputFormatters are applied correctly',
      (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoundedTextField(
            controller: controller,
            validationType: ValidationType.cardNumber,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '123abc456');
    await tester.pump();

    expect(controller.text, '123456'); // Digits only should remain.
  });
}
