import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_dart/src/services/capability_api.dart';
import 'package:omise_flutter/src/controllers/payment_method_selector_controller.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';

// Mock classes
class MockOmiseApi extends Mock implements OmiseApi {}

class MockCapability extends Mock implements Capability {}

class MockCapabilityResource extends Mock implements CapabilityApi {}

class MockOmiseApiService extends Mock implements OmiseApiService {}

class MockPaymentMethodSelectorController extends Mock
    implements PaymentMethodSelectorController {}

// Mock class for callback
class MockCallback extends Mock {
  void call();
}
