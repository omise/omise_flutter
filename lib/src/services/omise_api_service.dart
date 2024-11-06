import 'dart:io';

import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/utils/package_info.dart';

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

        userAgent: getUserAgent()); // User agent for Flutter
  }

  /// The instance of [OmiseApi] used for making API calls.
  late OmiseApi omiseApi;

  /// Retrieves a user agent string that includes the Dart SDK version, the SDK package information,
  /// and the operating system details.
  ///
  /// The user agent string follows the format:
  /// `dart/<DartSDKVersion> package:<PackageName> sdkVersion:<PackageVersion> (<OperatingSystem> <OSVersion>)`
  ///
  /// For example, it might return:
  /// `dart/3.5.0 (stable) (Tue Jul 30 02:17:59 2024 -0700) on "android_arm64" omise_flutter/0.1.0 (android TE1A.220922.012)`
  ///
  /// This function is useful for tracking the environment and SDK version in which your application
  /// is running, often needed for analytics, logging, or debugging.
  ///
  /// Returns:
  ///   A [String] containing the user agent.
  String getUserAgent() {
    const sdkVersion = PackageInfo.packageVersion;
    const packageName = PackageInfo.packageName;
    return 'dart/${Platform.version} $packageName/$sdkVersion (${Platform.operatingSystem} ${Platform.operatingSystemVersion})';
  }

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
