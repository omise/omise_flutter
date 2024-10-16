import 'package:omise_dart/omise_dart.dart';

/// [OmiseApiService] is a service class that provides methods to interact
/// with the omise dart package. It initializes the API client with necessary parameters
/// like the public key and debug options.
class OmiseApiService {
  /// Creates an instance of [OmiseApiService].
  ///
  /// Requires a [publicKey] for authenticating requests to the Omise API.
  ///
  /// An optional [enableDebug] parameter can be set to enable debugging
  /// logs for API requests and responses.
  OmiseApiService({
    required String publicKey,
    bool? enableDebug,
  }) {
    // Initialize the OmiseApi instance with the provided public key
    // and other configurations.
    omiseApi = OmiseApi(
        enableDebug: enableDebug,
        publicKey: publicKey,
        ignoreNullKeys: true, // Ignore null keys in requests
        // TODO: set up flutter userAgent
        userAgent: "flutterUserAgent"); // User agent for Flutter
  }

  /// The instance of [OmiseApi] used for making API calls.
  late OmiseApi omiseApi;

  /// Retrieves the capabilities of the Omise API, which includes
  /// information about the payment methods available and other
  /// configuration details.
  ///
  /// Returns a [Future<Capability>] that resolves to the capabilities
  /// data from the Omise API.
  Future<Capability> getCapabilities() {
    return omiseApi.capability.get();
  }

  Future<Token> createToken(CreateTokenRequest createTokenRequest) {
    return omiseApi.tokens.create(createTokenRequest);
  }
}
