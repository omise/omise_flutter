import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart'; // Import this for ValueNotifier
import 'package:flutter/material.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:url_launcher/url_launcher.dart';

typedef LaunchUrlFunction = Future<void> Function(Uri uri, {LaunchMode mode});

/// [PaymentAuthorizationController] manages the authorization flow for payments
/// within a WebView, using [ValueNotifier] to notify listeners of state updates.
class PaymentAuthorizationController
    extends ValueNotifier<PaymentAuthorizationState> {
  /// Indicates if debugging logs should be enabled.
  final bool? enableDebug;

  // Added for testing purposes
  final LaunchUrlFunction launchUrlFunction;

  /// Creates an instance of [PaymentAuthorizationController], initializing the
  /// controller state to [idle] and enabling debug logging if specified.
  PaymentAuthorizationController({
    this.enableDebug = false,
    this.launchUrlFunction = launchUrl,
  }) : super(PaymentAuthorizationState(
            webViewLoadingStatus: Status.idle,
            enableDebug: enableDebug ?? false));

  /// Internal helper function to update the state of [ValueNotifier] directly.
  void _setValue(PaymentAuthorizationState state) {
    value = state;
  }

  /// Updates the controller state with the provided [newState]. This method
  /// allows for additional logic prior to state change if needed.
  void updateState(PaymentAuthorizationState newState) {
    _setValue(newState);
  }

  /// Attempts to open a deep link with the current URL from [currentWebViewUrl].
  /// This method logs any errors if [enableDebug] is enabled.
  Future<void> openDeepLink() async {
    try {
      final uri = Uri.parse(value.currentWebViewUrl!);
      await launchUrlFunction(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (enableDebug == true) {
        log("Unable to launch deep link",
            error: jsonEncode(
                {"error": e.toString(), "deepLink": value.currentWebViewUrl}));
      }
    }
  }

  /// Opens the [authorizeUri] in the external browser (default browser).
  Future<void> openInExternalBrowser() async {
    try {
      final uri = value.authorizeUri!;
      await launchUrlFunction(uri, mode: LaunchMode.externalApplication);
    } catch (e, stack) {
      if (enableDebug == true) {
        log("Unable to open external browser",
            error:
                jsonEncode({"error": e.toString(), "url": value.authorizeUri}),
            stackTrace: stack);
      }
    }
  }
}

/// [PaymentAuthorizationState] represents the state of the payment authorization
/// process within the WebView, including loading status, URLs, and errors.
class PaymentAuthorizationState {
  /// The current loading status of the WebView (e.g., idle, loading, success, or error).
  final Status webViewLoadingStatus;

  /// The current URL being displayed within the WebView.
  final String? currentWebViewUrl;

  /// Error message for any issues encountered in the WebView.
  final String? webViewError;

  /// A list of URLs that are expected as return URLs from the WebView.
  final List<String>? expectedReturnUrls;

  /// Indicates whether debugging logs are enabled.
  final bool enableDebug;

  final Uri? authorizeUri;

  /// Checks if the [currentWebViewUrl] matches one of the [expectedReturnUrls].
  bool get isReturnUrl =>
      expectedReturnUrls?.contains(currentWebViewUrl) ?? false;

  /// Verifies if [currentWebViewUrl] is an external URL that does not match
  /// expected schemes such as 'http', 'https', or 'about'.
  /// This check is used to determine if the WebView should open the URL externally.
  bool get isExternalURL {
    try {
      final uri = Uri.parse(currentWebViewUrl!);
      return uri.scheme != 'http' &&
          uri.scheme != 'https' &&
          uri.scheme != 'about';
    } catch (e) {
      if (enableDebug) {
        log("Omise webview error", error: e);
      }
      return false;
    }
  }

  /// Detects if the url is a passkey url in order to open the external browser
  bool get isPassKeyUrl {
    if (authorizeUri == null) return false;

    try {
      return authorizeUri!.queryParameters.containsKey('signature');
    } catch (e, stack) {
      if (enableDebug) {
        log("Omise webview error", error: e, stackTrace: stack);
      }
      return false;
    }
  }

  /// Constructs a new instance of [PaymentAuthorizationState] with the specified
  /// values for [webViewLoadingStatus], [currentWebViewUrl], [webViewError],
  /// [expectedReturnUrls], and [enableDebug].
  PaymentAuthorizationState({
    required this.webViewLoadingStatus,
    this.currentWebViewUrl,
    this.webViewError,
    this.expectedReturnUrls,
    required this.enableDebug,
    this.authorizeUri,
  });

  /// Creates a new instance of [PaymentAuthorizationState] with modified values
  /// for specific fields, copying other fields from the current instance.
  PaymentAuthorizationState copyWith({
    Status? webViewLoadingStatus,
    String? currentWebViewUrl,
    String? webViewError,
    List<String>? expectedReturnUrls,
    Uri? authorizeUri,
  }) {
    return PaymentAuthorizationState(
        webViewLoadingStatus: webViewLoadingStatus ?? this.webViewLoadingStatus,
        currentWebViewUrl: currentWebViewUrl ?? this.currentWebViewUrl,
        webViewError: webViewError ?? this.webViewError,
        expectedReturnUrls: expectedReturnUrls ?? this.expectedReturnUrls,
        enableDebug: enableDebug,
        authorizeUri: authorizeUri ?? this.authorizeUri);
  }
}
