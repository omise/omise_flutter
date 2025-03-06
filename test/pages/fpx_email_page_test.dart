import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/pages/paymentMethods/fpx/fpx_banks_page.dart';
import 'package:omise_flutter/src/pages/paymentMethods/fpx/fpx_email_page.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:omise_flutter/src/widgets/rounded_text_field.dart';

class MockOmiseApiService extends Mock implements OmiseApiService {}

void main() {
  late MockOmiseApiService mockOmiseApiService;
  const testAmount = 1000;
  const testCurrency = Currency.thb;
  const testEmail = 'test@example.com';
  final testFpxBanks = [Bank(code: BankCode.affin, name: 'name', active: true)];

  setUp(() {
    mockOmiseApiService = MockOmiseApiService();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: FpxEmailPage(
        omiseApiService: mockOmiseApiService,
        amount: testAmount,
        currency: testCurrency,
        fpxBanks: testFpxBanks,
      ),
    );
  }

  testWidgets('Renders UI correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.textContaining('FPX'), findsWidgets);
    expect(find.byType(RoundedTextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Enables button when valid email is entered',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.enterText(find.byType(RoundedTextField), testEmail);
    await tester.pump();

    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isTrue);
  });

  testWidgets('Disables button when invalid email is entered',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.enterText(find.byType(RoundedTextField), 'invalid-email');
    await tester.pump();

    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isFalse);
  });

  testWidgets('Navigates to FpxBanksPage when button is tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.enterText(find.byType(RoundedTextField), testEmail);
    await tester.pump();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(FpxEmailPage), findsNothing);
    expect(find.byType(FpxBanksPage), findsOneWidget);
  });
}
