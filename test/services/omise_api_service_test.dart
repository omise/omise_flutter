import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/services/omise_api_service.dart';

import '../mocks.dart';

void main() {
  late MockOmiseApi mockOmiseApi;
  late MockCapabilityResource mockCapabilityResource;
  late MockTokenResource mockTokenResource;
  late MockSourceResource mockSourceResource;
  late OmiseApiService omiseApiService;

  setUp(() {
    mockOmiseApi = MockOmiseApi();
    mockCapabilityResource = MockCapabilityResource();
    mockTokenResource = MockTokenResource();
    mockSourceResource = MockSourceResource();

    // Provide the mock capability resource to OmiseApi
    when(() => mockOmiseApi.capability).thenReturn(mockCapabilityResource);

    // Provide the mock token resource to OmiseApi
    when(() => mockOmiseApi.tokens).thenReturn(mockTokenResource);

    // Provide the mock token resource to OmiseApi
    when(() => mockOmiseApi.sources).thenReturn(mockSourceResource);

    // Create the service with the mocked OmiseApi instance
    omiseApiService = OmiseApiService(publicKey: 'test_public_key');
    omiseApiService.omiseApi = mockOmiseApi; // Inject the mocked API instance
  });

  group('OmiseApiService', () {
    test('getCapabilities should call OmiseApi.capability.get', () async {
      final mockCapability = MockCapability();

      // Stub the capability.get method to return a mock capability
      when(() => mockCapabilityResource.get())
          .thenAnswer((_) async => mockCapability);

      // Call the getCapabilities method
      final result = await omiseApiService.getCapabilities();

      // Verify that the capability.get method was called
      verify(() => mockCapabilityResource.get()).called(1);

      // Ensure the result is the mock capability
      expect(result, equals(mockCapability));
    });

    test(
        'getCapabilities should throw an error when OmiseApi.capability.get fails',
        () async {
      // Stub the capability.get method to throw an exception
      when(() => mockCapabilityResource.get())
          .thenThrow(Exception('API error'));

      // Call the getCapabilities method and expect an exception
      expect(
          () async => await omiseApiService.getCapabilities(), throwsException);
    });
    test('createToken should call OmiseApi.tokens.create', () async {
      final mockToken = MockToken();

      final tokenRequest = CreateTokenRequest(
          name: "name",
          number: "number",
          expirationMonth: "expirationMonth",
          expirationYear: "expirationYear");

      // Stub the OmiseApi.tokens.create method to return a mock token
      when(() => mockTokenResource.create(tokenRequest))
          .thenAnswer((_) async => mockToken);

      // Call the getCapabilities method
      final result = await omiseApiService.createToken(tokenRequest);

      // Verify that the token.create method was called
      verify(() => mockTokenResource.create(tokenRequest)).called(1);

      // Ensure the result is the mock capability
      expect(result, equals(mockToken));
    });
    test('createSource should call OmiseApi.sources.create', () async {
      final mockSource = MockSource();

      final sourceRequest = CreateSourceRequest(
        amount: 1000,
        currency: Currency.thb,
        type: PaymentMethodName.promptpay,
      );

      // Stub the OmiseApi.tokens.create method to return a mock token
      when(() => mockSourceResource.create(sourceRequest))
          .thenAnswer((_) async => mockSource);

      // Call the getCapabilities method
      final result = await omiseApiService.createSource(sourceRequest);

      // Verify that the source.create method was called
      verify(() => mockSourceResource.create(sourceRequest)).called(1);

      // Ensure the result is the mock capability
      expect(result, equals(mockSource));
    });
    test('getUserAgent returns the correct format', () {
      final userAgent = omiseApiService.getUserAgent();

      final expectedUserAgentPattern =
          RegExp(r'^dart/\d+\.\d+\.\d+ .+/\d+\.\d+\.\d+ \(.+ .+\)$');
      expect(userAgent, matches(expectedUserAgentPattern));
    });
  });
}
