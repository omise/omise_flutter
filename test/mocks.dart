import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_dart/src/services/capability_api.dart';
import 'package:omise_dart/src/services/tokens_api.dart';
import 'package:omise_dart/src/services/sources_api.dart';
import 'package:omise_flutter/src/controllers/atome_controller.dart';
import 'package:omise_flutter/src/controllers/credit_card_controller.dart';
import 'package:omise_flutter/src/controllers/bank_selector_controller.dart';
import 'package:omise_flutter/src/controllers/google_pay_controller.dart';
import 'package:omise_flutter/src/controllers/installments_controller.dart';
import 'package:omise_flutter/src/controllers/mobile_banking_controller.dart';
import 'package:omise_flutter/src/controllers/payment_authorization_controller.dart';
import 'package:omise_flutter/src/controllers/payment_methods_controller.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Mock classes
class MockOmiseApi extends Mock implements OmiseApi {}

class MockCapability extends Mock implements Capability {}

class MockToken extends Mock implements Token {}

class MockSource extends Mock implements Source {}

class MockCapabilityResource extends Mock implements CapabilityApi {}

class MockTokenResource extends Mock implements TokensApi {}

class MockSourceResource extends Mock implements SourcesApi {}

class MockOmiseApiService extends Mock implements OmiseApiService {}

class MockPaymentMethodSelectorController extends Mock
    implements PaymentMethodsController {}

class MockCreditCardPaymentMethodController extends Mock
    implements CreditCardController {}

class MockMobileBankingPaymentMethodSelectorController extends Mock
    implements MobileBankingController {}

class MockInstallmentsController extends Mock
    implements InstallmentsController {}

class MockBankSelectorController extends Mock
    implements BankSelectorController {}

class MockCreateTokenRequest extends Mock implements CreateTokenRequest {}

class MockCreateSourceRequest extends Mock implements CreateSourceRequest {}

class MockBuildContext extends Mock implements BuildContext {}

class MockGooglePayController extends Mock implements GooglePayController {}

class MockAtomeController extends Mock implements AtomeController {}

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
