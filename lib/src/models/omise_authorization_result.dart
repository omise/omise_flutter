class OmiseAuthorizationResult {
  /// A parameter indicating if the web authorization flow was processed to the point of automatically closing the webview
  /// using the return uri from the merchant.
  /// Does not indicate that the authorization was successful.
  final bool? isWebViewAuthorized;

  OmiseAuthorizationResult({this.isWebViewAuthorized});

  Map<String, dynamic> toJson() {
    return {
      'isWebViewAuthorized': isWebViewAuthorized,
    };
  }
}
