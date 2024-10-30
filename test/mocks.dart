import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_dart/src/services/capability_api.dart';
import 'package:omise_dart/src/services/tokens_api.dart';
import 'package:omise_flutter/src/controllers/credit_card_payment_method_controller.dart';
import 'package:omise_flutter/src/controllers/payment_authorization_controller.dart';
import 'package:omise_flutter/src/controllers/payment_method_selector_controller.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Mock classes
class MockOmiseApi extends Mock implements OmiseApi {}

class MockCapability extends Mock implements Capability {}

class MockToken extends Mock implements Token {}

class MockCapabilityResource extends Mock implements CapabilityApi {}

class MockTokenResource extends Mock implements TokensApi {}

class MockOmiseApiService extends Mock implements OmiseApiService {}

class MockPaymentMethodSelectorController extends Mock
    implements PaymentMethodSelectorController {}

class MockCreditCardPaymentMethodController extends Mock
    implements CreditCardPaymentMethodController {}

class MockCreateTokenRequest extends Mock implements CreateTokenRequest {}

// Mock class for callback
class MockCallback extends Mock {
  void call();
}

// Mock the URL launcher to avoid actual deep link launches in tests.
class MockUriLauncher extends Mock {
  Future<void> launchUrl(Uri uri, {LaunchMode? mode});
}

class MockPaymentAuthorizationController extends Mock
    implements PaymentAuthorizationController {}

class FakeUri extends Fake implements Uri {}

class MockWebViewController extends Mock implements WebViewController {
  NavigationDelegate? _navigationDelegate;

  @override
  Future<void> setNavigationDelegate(NavigationDelegate delegate) {
    _navigationDelegate = delegate;
    return Future.value();
  }

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) {
    return Future.value();
  }

  @override
  Future<void> setBackgroundColor(Color color) {
    return Future.value();
  }

  void simulateNavigation(String url) {
    // Call the delegate with the simulated URL
    if (_navigationDelegate != null) {
      _navigationDelegate!.onNavigationRequest!(NavigationRequest(
        url: url,
        isMainFrame: true,
        // Add any additional parameters that might be needed
      ));
    }
  }
}
