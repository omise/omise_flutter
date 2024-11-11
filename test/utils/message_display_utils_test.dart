import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omise_flutter/src/utils/message_display_utils.dart'; // Adjust the import path as per your project structure

void main() {
  group('MessageDisplayUtils', () {
    testWidgets('shows SnackBar with correct message and background color',
        (WidgetTester tester) async {
      const testMessage = 'This is a test message';

      // Create a basic app structure for testing
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    MessageDisplayUtils.showSnackBar(context, testMessage);
                  },
                  child: const Text('Show SnackBar'),
                );
              },
            ),
          ),
        ),
      );

      // Trigger the button to show the SnackBar
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Trigger a frame

      // Verify that the SnackBar appears with the correct message
      expect(find.text(testMessage), findsOneWidget);

      // Verify that the SnackBar has the correct background color (red)
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red);
    });
  });
}
