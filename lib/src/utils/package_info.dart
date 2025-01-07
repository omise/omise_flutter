/// A utility class that provides static information about the package.
///
/// This class contains the name and version of the package, which
/// can be used for logging, attaching to requests, or displaying in the UI.
class PackageInfo {
  /// The name of the package.
  ///
  /// This constant holds the package's name as defined in `pubspec.yaml`.
  static const String packageName = 'omise_flutter';

  /// The version of the package.
  ///
  /// This constant holds the package's version as defined in `pubspec.yaml`.
  static const String packageVersion = '0.2.0';

  static const userAgentIdentifier = 'OmiseFlutter';
}
