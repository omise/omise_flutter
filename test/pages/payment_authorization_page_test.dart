import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_flutter/omise_flutter.dart';
import 'package:omise_flutter/src/controllers/payment_authorization_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/pages/payment_authorization_page.dart';

// ignore: depend_on_referenced_packages
import 'package:webview_flutter_android/webview_flutter_android.dart';
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../mocks.dart';

void main() {
  late MockPaymentAuthorizationController mockPaymentAuthorizationController;
  late MockWebViewController mockWebViewController;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockPaymentAuthorizationController = MockPaymentAuthorizationController();
    mockWebViewController = MockWebViewController();
    WebViewPlatform.instance = AndroidWebViewPlatform();
  });
  Future<void> pumpAuthorizationPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
          home: PaymentAuthorizationPage(
        authorizeUri: Uri.parse("https://example.com/auth"),
        expectedReturnUrls: const ['https://example.com/success'],
        enableDebug: true,
        paymentAuthorizationController: mockPaymentAuthorizationController,
        customWebViewController: mockWebViewController,
      )),
    );
  }

  group("Payment authorization flow using auth uri", () {
    testWidgets('Initial URL loads in WebView', (WidgetTester tester) async {
      when(() => mockPaymentAuthorizationController.value).thenReturn(
        PaymentAuthorizationState(
          webViewLoadingStatus: Status.success,
          enableDebug: false,
        ),
      );
      when(() => mockWebViewController.loadRequest(any()))
          .thenAnswer((_) async => Future.value());
      when(() => mockWebViewController.platform).thenReturn(
          PlatformWebViewController(
              const PlatformWebViewControllerCreationParams()));

      await pumpAuthorizationPage(tester);

      // Wait for the initial URL to be loaded (you can adjust the duration as needed)
      await tester.pumpAndSettle();
      verify(() => mockWebViewController
          .loadRequest(Uri.parse('https://example.com/auth'))).called(1);
    });
    testWidgets('Shows loading indicator when loading',
        (WidgetTester tester) async {
      when(() => mockPaymentAuthorizationController.value).thenReturn(
        PaymentAuthorizationState(
          webViewLoadingStatus: Status.loading,
          enableDebug: false,
        ),
      );
      when(() => mockWebViewController.loadRequest(any()))
          .thenAnswer((_) async => Future.value());
      when(() => mockWebViewController.platform).thenReturn(
          PlatformWebViewController(
              const PlatformWebViewControllerCreationParams()));

      await pumpAuthorizationPage(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    testWidgets('Navigates to return URL and verifies behavior',
        (WidgetTester tester) async {
      when(() => mockPaymentAuthorizationController.value).thenReturn(
        PaymentAuthorizationState(
          webViewLoadingStatus: Status.success,
          enableDebug: false,
        ),
      );

      when(() => mockWebViewController.loadRequest(any()))
          .thenAnswer((_) async => Future.value());
      when(() => mockWebViewController.platform).thenReturn(
          PlatformWebViewController(
              const PlatformWebViewControllerCreationParams()));

      await pumpAuthorizationPage(tester);
      await tester.pumpAndSettle();

      // Set the return URL to be the one we want to simulate
      const returnUrl = "https://example.com/success";
      when(() => mockPaymentAuthorizationController.value).thenReturn(
        PaymentAuthorizationState(
          webViewLoadingStatus: Status.success,
          enableDebug: false,
          currentWebViewUrl: returnUrl,
          expectedReturnUrls: [returnUrl],
        ),
      );

      // Simulate setting the navigation delegate and navigating to the return URL
      mockWebViewController.simulateNavigation(returnUrl);

      await tester.pumpAndSettle();

      expect(find.byType(PaymentAuthorizationPage), findsNothing);
    });
  });
  testWidgets(
    'After payment authorization, the result is returned to the integrator',
    (WidgetTester tester) async {
      OmiseAuthorizationResult?
          capturedResult; // To capture the result from the navigator pop

      when(() => mockPaymentAuthorizationController.value).thenReturn(
        PaymentAuthorizationState(
          webViewLoadingStatus: Status.success,
          enableDebug: false,
        ),
      );

      when(() => mockWebViewController.loadRequest(any()))
          .thenAnswer((_) async => Future.value());
      when(() => mockWebViewController.platform).thenReturn(
          PlatformWebViewController(
              const PlatformWebViewControllerCreationParams()));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PaymentAuthorizationPage(
                        authorizeUri: Uri.parse("https://example.com/auth"),
                        expectedReturnUrls: const [
                          'https://example.com/success'
                        ],
                        enableDebug: true,
                        paymentAuthorizationController:
                            mockPaymentAuthorizationController,
                        customWebViewController: mockWebViewController,
                      ),
                    ),
                  );
                  capturedResult =
                      result; // Capture the result from Navigator.pop
                },
                child: const Text('Open Auth Page'),
              );
            },
          ),
        ),
      );

      // Simulate opening the auth page
      await tester.tap(find.text('Open Auth Page'));

      await tester.pumpAndSettle();

      // Set the return URL to be the one we want to simulate
      const returnUrl = "https://example.com/success";
      when(() => mockPaymentAuthorizationController.value).thenReturn(
        PaymentAuthorizationState(
          webViewLoadingStatus: Status.success,
          enableDebug: false,
          currentWebViewUrl: returnUrl,
          expectedReturnUrls: [returnUrl],
        ),
      );

      // Simulate setting the navigation delegate and navigating to the return URL
      mockWebViewController.simulateNavigation(returnUrl);
      await tester.pumpAndSettle();

      // Check if the result is captured correctly after the page is popped
      expect(
          capturedResult?.isWebViewAuthorized, true); // Verify result from pop

      // Ensure the PaymentAuthorizationPage is no longer in the widget tree (i.e., the page was popped)
      expect(find.byType(PaymentAuthorizationPage), findsNothing);
    },
  );
}
