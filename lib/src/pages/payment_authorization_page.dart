import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:omise_flutter/src/controllers/payment_authorization_controller.dart';
import 'package:omise_flutter/src/enums/enums.dart';
import 'package:omise_flutter/src/models/omise_authorization_result.dart';
import 'package:omise_flutter/src/translations/translations.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A page for handling payment authorization using a WebView.
/// This page displays the authorization URL and manages navigation within the WebView.
/// It supports detecting expected return URLs and launching external links.
class PaymentAuthorizationPage extends StatefulWidget {
  /// The URI to be loaded in the WebView for authorization.
  final Uri authorizeUri;

  /// A list of URLs that are considered valid return URLs for the authorization flow.
  final List<String>? expectedReturnUrls;

  /// Enables debug logging if set to `true`.
  final bool? enableDebug;

  /// Allows passing an existing instance of [PaymentAuthorizationController] for easier testing.
  final PaymentAuthorizationController? paymentAuthorizationController;

  /// custom WebViewController for testing
  final WebViewController? customWebViewController;

  /// The custom locale passed by the merchant.
  final OmiseLocale? locale;

  /// Constructs a [PaymentAuthorizationPage] with the required authorization URL
  /// and optional expected return URLs, controller, locale and debug mode.
  const PaymentAuthorizationPage({
    required this.authorizeUri,
    this.expectedReturnUrls,
    this.paymentAuthorizationController,
    this.enableDebug = false,
    super.key,
    this.customWebViewController,
    this.locale,
  });

  @override
  State<PaymentAuthorizationPage> createState() =>
      _PaymentAuthorizationPageState();
}

class _PaymentAuthorizationPageState extends State<PaymentAuthorizationPage> {
  /// Controller to manage WebView navigation and interactions.
  late final WebViewController webViewController;

  /// Controller to manage the state of payment authorization and update UI based on status.
  late final PaymentAuthorizationController paymentAuthorizationController;

  @override
  void initState() {
    super.initState();
    // Initialize the payment authorization controller, or use the provided one.
    paymentAuthorizationController = widget.paymentAuthorizationController ??
        PaymentAuthorizationController(enableDebug: widget.enableDebug);
    // Update the controller's state to include expected return URLs.
    paymentAuthorizationController.updateState(
        paymentAuthorizationController.value.copyWith(
            expectedReturnUrls: widget.expectedReturnUrls,
            authorizeUri: widget.authorizeUri));

    if (paymentAuthorizationController.value.isPassKeyUrl) {
      // open external browser app
      paymentAuthorizationController.openInExternalBrowser();
      // close the auth page
      Navigator.pop(context);
    } else {
      // Set up the WebView controller with initial settings and navigation handling.
      webViewController = widget.customWebViewController ?? WebViewController()
        ..setBackgroundColor(Colors.white)
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            // Handles navigation requests within the WebView.
            onNavigationRequest: (NavigationRequest request) {
              paymentAuthorizationController.updateState(
                  paymentAuthorizationController.value
                      .copyWith(currentWebViewUrl: request.url));

              // Detect if the URL matches an expected return URL and close the WebView if it does.
              if (paymentAuthorizationController.value.isReturnUrl) {
                Navigator.of(context)
                    .pop(OmiseAuthorizationResult(isWebViewAuthorized: true));
                // do not prevent the navigation on iOS as it will cause an error
                if (!Platform.isIOS) {
                  return NavigationDecision.prevent;
                }
              }

              // Check if the URL is external and open it outside the WebView if true.
              if (paymentAuthorizationController.value.isExternalURL) {
                paymentAuthorizationController.openDeepLink();
                return NavigationDecision.prevent;
              }

              // Allow WebView to navigate to the requested URL.
              return NavigationDecision.navigate;
            },
            // Updates loading status when a new page starts loading.
            onPageStarted: (_) {
              paymentAuthorizationController.updateState(
                  paymentAuthorizationController.value
                      .copyWith(webViewLoadingStatus: Status.loading));
            },
            // Updates loading status when a page finishes loading.
            onPageFinished: (_) {
              paymentAuthorizationController.updateState(
                  paymentAuthorizationController.value
                      .copyWith(webViewLoadingStatus: Status.success));
            },
            // Handles any WebView resource errors.
            onWebResourceError: (WebResourceError error) {
              if (widget.enableDebug == true) {
                log("Omise webview error", error: error.description);
              }
              paymentAuthorizationController.updateState(
                  paymentAuthorizationController.value.copyWith(
                      webViewLoadingStatus: Status.error,
                      currentWebViewUrl: error.description));
            },
          ),
        )
        // Load the initial authorization URL.
        ..loadRequest(widget.authorizeUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, data) {
        // This means that the user exited using the phone's native integration (back gestures)
        if (!didPop) {
          if (data == null) {
            Navigator.pop(
                context, OmiseAuthorizationResult(isWebViewAuthorized: false));
          } else {
            Navigator.pop(context, data);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title:
              Text(Translations.get('secureCheckout', widget.locale, context)),
        ),
        body: Stack(
          children: [
            // Display the WebView within the page.
            if (!paymentAuthorizationController.value.isPassKeyUrl)
              WebViewWidget(controller: webViewController),
            // Show a loading indicator based on the WebView loading status.
            ValueListenableBuilder(
                valueListenable: paymentAuthorizationController,
                builder: (context, state, _) {
                  if (state.webViewLoadingStatus == Status.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Container();
                })
          ],
        ),
      ),
    );
  }
}
