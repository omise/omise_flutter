import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_flutter/src/controllers/econtext_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/pages/paymentMethods/econtext_page.dart';

import '../mocks.dart';

void main() {
  late MockOmiseApiService mockOmiseApiService;
  late MockEcontextController mockController;

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
    mockController = MockEcontextController();
  });
  setUpAll(() {
    registerFallbackValue(MockCreateSourceRequest());
  });

  const amount = 1000;
  const currency = Currency.thb;
  const econtextMethod = CustomPaymentMethod.convenienceStore;

  group("Econtext Page Tests", () {
    testWidgets('form displayed properly', (WidgetTester tester) async {
      when(() => mockController.value).thenReturn(EcontextPageState(
        sourceLoadingStatus: Status.idle,
        textFieldValidityStatuses: {},
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: EcontextPage(
            omiseApiService: mockOmiseApiService,
            amount: amount,
            currency: currency,
            econtextMethod: econtextMethod,
          ),
        ),
      );

      expect(find.byType(TextField),
          findsWidgets); // Ensures form fields are shown
      expect(find.byType(ElevatedButton),
          findsWidgets); // Ensures the next button is displayed
    });
    testWidgets('Next button remains disabled with invalid input',
        (WidgetTester tester) async {
      when(() => mockController.value).thenReturn(EcontextPageState(
        sourceLoadingStatus: Status.idle,
        textFieldValidityStatuses: {
          'name': false,
        },
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: EcontextPage(
            omiseApiService: mockOmiseApiService,
            econtextController: mockController,
            amount: amount,
            currency: currency,
            econtextMethod: econtextMethod,
          ),
        ),
      );

      final nextButton = find.byType(ElevatedButton);
      expect(nextButton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(nextButton).enabled, isFalse);
    });
    testWidgets('Pay button is enabled with valid input',
        (WidgetTester tester) async {
      when(() => mockController.value).thenReturn(
        EcontextPageState(
            sourceLoadingStatus: Status.idle,
            textFieldValidityStatuses: {
              'phoneNumber': true,
              'email': true,
              'name': true,
            }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EcontextPage(
            omiseApiService: mockOmiseApiService,
            econtextController: mockController,
            amount: amount,
            currency: currency,
            econtextMethod: econtextMethod,
          ),
        ),
      );

      final nextButton = find.byType(ElevatedButton);
      expect(nextButton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(nextButton).enabled,
          isTrue); // Button should be enabled
    });
    testWidgets('Next button click disables fields and button',
        (WidgetTester tester) async {
      when(() => mockController.value).thenReturn(
        EcontextPageState(
            sourceLoadingStatus: Status.loading,
            textFieldValidityStatuses: {
              'phoneNumber': true,
              'email': true,
              'name': true,
            }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EcontextPage(
            omiseApiService: mockOmiseApiService,
            econtextController: mockController,
            amount: amount,
            currency: currency,
            econtextMethod: econtextMethod,
          ),
        ),
      );

      final nextButton = find.byType(ElevatedButton);
      await tester.pumpAndSettle();

      // Check if fields and button are disabled after click
      final disabledFields = find
          .byType(TextField)
          .evaluate()
          .every((element) => (element.widget as TextField).enabled == false);
      expect(disabledFields, isTrue);
      expect(tester.widget<ElevatedButton>(nextButton).enabled,
          isFalse); // Button should be disabled
    });

    testWidgets('allows typing into the text fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EcontextPage(
            omiseApiService: mockOmiseApiService,
            econtextController:
                EcontextController(omiseApiService: mockOmiseApiService),
            amount: amount,
            currency: currency,
            econtextMethod: econtextMethod,
          ),
        ),
      );

      // Find the TextFields
      final nameField = find.byKey(Key(ValidationType.name.name));
      final emailField = find.byKey(Key(ValidationType.email.name));
      final phoneNumberField = find.byKey(Key(ValidationType.phoneNumber.name));

      // Type into the text fields
      await tester.enterText(emailField, 'test@gmail.com');
      await tester.enterText(phoneNumberField, '0645123321');
      await tester.enterText(nameField, 'John Doe');

      // Rebuild the widget after the state has changed
      await tester.pump();

      // Check that the fields contain the entered text
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('test@gmail.com'), findsOneWidget);
      expect(find.text('0645123321'), findsOneWidget);
    });
  });
}
