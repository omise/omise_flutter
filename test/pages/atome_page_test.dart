import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_flutter/src/controllers/atome_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/pages/paymentMethods/atome_page.dart';
import 'package:omise_dart/omise_dart.dart';

import '../mocks.dart';

void main() {
  late MockOmiseApiService mockOmiseApiService;
  late AtomeController mockController;

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
    mockController = MockAtomeController();
  });
  setUpAll(() {
    registerFallbackValue(MockCreateSourceRequest());
  });

  const amount = 1000;
  const currency = Currency.thb;
  final mockItem =
      Item(name: "Test Item", quantity: 1, amount: amount, sku: 'sku');

  group(
    "Atome Page Tests",
    () {
      testWidgets('form displayed properly', (WidgetTester tester) async {
        when(() => mockController.value).thenReturn(AtomePageState(
          shippingSameAsBilling: true,
          sourceLoadingStatus: Status.idle,
          textFieldValidityStatuses: {},
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: AtomePage(
              omiseApiService: mockOmiseApiService,
              atomeController: mockController,
              amount: amount,
              currency: currency,
              items: [mockItem],
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
        when(() => mockController.value).thenReturn(AtomePageState(
          shippingSameAsBilling: false,
          sourceLoadingStatus: Status.idle,
          textFieldValidityStatuses: {
            'name': false,
          },
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: AtomePage(
              omiseApiService: mockOmiseApiService,
              atomeController: mockController,
              amount: amount,
              currency: currency,
              items: [mockItem],
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
          AtomePageState(
              shippingSameAsBilling: false,
              sourceLoadingStatus: Status.idle,
              textFieldValidityStatuses: {
                'phoneNumber': true,
                'address': true,
                'postalCode': true,
                'city': true,
                'countryCode': true,
              }),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: AtomePage(
              omiseApiService: mockOmiseApiService,
              atomeController: mockController,
              amount: amount,
              currency: currency,
              items: [mockItem],
            ),
          ),
        );

        final nextButton = find.byType(ElevatedButton);
        expect(nextButton, findsOneWidget);
        expect(tester.widget<ElevatedButton>(nextButton).enabled,
            isTrue); // Button should be enabled
      });
      testWidgets('Pay button click disables fields and button',
          (WidgetTester tester) async {
        when(() => mockController.value).thenReturn(
          AtomePageState(
              shippingSameAsBilling: true,
              sourceLoadingStatus: Status.loading,
              textFieldValidityStatuses: {
                'phoneNumber': true,
                'address': true,
                'postalCode': true,
                'city': true,
                'countryCode': true,
              }),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: AtomePage(
              omiseApiService: mockOmiseApiService,
              atomeController: mockController,
              amount: amount,
              currency: currency,
              items: [mockItem],
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
            home: AtomePage(
              omiseApiService: mockOmiseApiService,
              atomeController:
                  AtomeController(omiseApiService: mockOmiseApiService),
              amount: amount,
              currency: currency,
              items: [mockItem],
            ),
          ),
        );

        // Find the TextFields
        final nameField = find.byKey(Key(ValidationType.name.name));
        final emailField = find.byKey(Key(ValidationType.email.name));
        final phoneNumberField =
            find.byKey(Key(ValidationType.phoneNumber.name));
        final streetField = find.byKey(Key(ValidationType.address.name));
        final postalCodeField = find.byKey(Key(ValidationType.postalCode.name));
        final cityField = find.byKey(Key(ValidationType.city.name));
        final countryCodeField =
            find.byKey(Key(ValidationType.countryCode.name));

        // Type into the text fields
        await tester.enterText(emailField, 'test@gmail.com');
        await tester.enterText(phoneNumberField, '0645123321');
        await tester.enterText(streetField, 'street');
        await tester.enterText(nameField, 'John Doe');
        await tester.enterText(postalCodeField, '12345');
        await tester.enterText(cityField, 'city');
        await tester.enterText(countryCodeField, 'TH');

        // Rebuild the widget after the state has changed
        await tester.pump();

        // Check that the fields contain the entered text
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('test@gmail.com'), findsOneWidget);
        expect(find.text('0645123321'), findsOneWidget);
        expect(find.text('street'), findsOneWidget);
        expect(find.text('12345'), findsOneWidget);
        expect(find.text('city'), findsOneWidget);
        expect(find.text('TH'), findsOneWidget);
      });

      testWidgets('should show billing fields when billing is enabled',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AtomePage(
              omiseApiService: mockOmiseApiService,
              atomeController:
                  AtomeController(omiseApiService: mockOmiseApiService),
              amount: amount,
              currency: currency,
              items: [mockItem],
            ),
          ),
        );

        await tester.ensureVisible(find.byKey(const Key('checkBox')));
        await tester.pumpAndSettle();
// disable the checkbox
        await tester.tap(find.byType(Checkbox));
        await tester.pump();
        // Find the TextFields
        final nameField = find.byKey(Key(ValidationType.name.name));
        final emailField = find.byKey(Key(ValidationType.email.name));
        final phoneNumberField =
            find.byKey(Key(ValidationType.phoneNumber.name));
        final streetField = find.byKey(Key(ValidationType.address.name));
        final postalCodeField = find.byKey(Key(ValidationType.postalCode.name));
        final cityField = find.byKey(Key(ValidationType.city.name));
        final countryCodeField =
            find.byKey(Key(ValidationType.countryCode.name));
        final streetFieldBilling =
            find.byKey(Key('${ValidationType.address.name}_billing'));
        final postalCodeFieldBilling =
            find.byKey(Key('${ValidationType.postalCode.name}_billing'));
        final cityFieldBilling =
            find.byKey(Key('${ValidationType.city.name}_billing'));
        final countryCodeFieldBilling =
            find.byKey(Key('${ValidationType.countryCode.name}_billing'));

        // Type into the text fields
        await tester.enterText(emailField, 'test@gmail.com');
        await tester.enterText(phoneNumberField, '0645123321');
        await tester.enterText(streetField, 'street');
        await tester.enterText(nameField, 'John Doe');
        await tester.enterText(postalCodeField, '12345');
        await tester.enterText(cityField, 'city');
        await tester.enterText(countryCodeField, 'TH');
        await tester.enterText(streetFieldBilling, 'street2');
        await tester.enterText(postalCodeFieldBilling, '123456');
        await tester.enterText(cityFieldBilling, 'city2');
        await tester.enterText(countryCodeFieldBilling, 'MY');

        // Rebuild the widget after the state has changed
        await tester.pump();

        // Check that the fields contain the entered text
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('test@gmail.com'), findsOneWidget);
        expect(find.text('0645123321'), findsOneWidget);
        expect(find.text('street'), findsOneWidget);
        expect(find.text('12345'), findsOneWidget);
        expect(find.text('city'), findsOneWidget);
        expect(find.text('TH'), findsOneWidget);
        expect(find.text('street2'), findsOneWidget);
        expect(find.text('123456'), findsOneWidget);
        expect(find.text('city2'), findsOneWidget);
        expect(find.text('MY'), findsOneWidget);
      });
    },
  );
}
