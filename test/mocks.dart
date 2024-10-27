import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_dart/src/services/capability_api.dart';
import 'package:omise_dart/src/services/tokens_api.dart';
import 'package:omise_flutter/src/controllers/credit_card_payment_method_controller.dart';
import 'package:omise_flutter/src/controllers/payment_method_selector_controller.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';

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
