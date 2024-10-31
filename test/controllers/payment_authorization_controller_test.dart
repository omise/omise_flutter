import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_flutter/src/controllers/payment_authorization_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:url_launcher/url_launcher.dart';

import '../mocks.dart';

void main() {
  late PaymentAuthorizationController controller;
  late MockUriLauncher mockUriLauncher;

  setUp(() {
    mockUriLauncher = MockUriLauncher();
    controller = PaymentAuthorizationController(
        enableDebug: true, launchUrlFunction: mockUriLauncher.launchUrl);
  });

  group('PaymentAuthorizationController', () {
    test('initial state is idle', () {
      expect(controller.value.webViewLoadingStatus, Status.idle);
      expect(controller.value.enableDebug, true);
    });

    test('updateState updates the controller state', () {
      // New state to apply
      final newState = PaymentAuthorizationState(
        webViewLoadingStatus: Status.loading,
        currentWebViewUrl: 'https://example.com',
        enableDebug: true,
      );

      controller.updateState(newState);

      // Check if the controller's value is updated
      expect(controller.value.webViewLoadingStatus, Status.loading);
      expect(controller.value.currentWebViewUrl, 'https://example.com');
    });

    test('openDeepLink launches a URL successfully', () async {
      // Set a valid URL in the state
      controller.updateState(controller.value.copyWith(
        currentWebViewUrl: 'customScheme://somepath',
      ));

      await controller.openDeepLink();

      verify(() => mockUriLauncher.launchUrl(
            Uri.parse('customScheme://somePath'),
            mode: LaunchMode.externalApplication,
          )).called(1);
    });

    test('isReturnUrl correctly identifies return URL', () {
      // Update expected return URLs and current URL
      final newState = controller.value.copyWith(
        currentWebViewUrl: 'https://example.com/success',
        expectedReturnUrls: ['https://example.com/success'],
      );

      controller.updateState(newState);

      expect(controller.value.isReturnUrl, true);
    });

    test('isExternalURL detects non-http/https URLs', () {
      controller.updateState(
        controller.value.copyWith(currentWebViewUrl: 'customscheme://somepath'),
      );

      expect(controller.value.isExternalURL, true);
    });

    test('isExternalURL returns false for http and https URLs', () {
      controller.updateState(
        controller.value.copyWith(currentWebViewUrl: 'https://example.com'),
      );

      expect(controller.value.isExternalURL, false);
    });
  });
}
