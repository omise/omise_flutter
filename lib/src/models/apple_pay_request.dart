class ApplePayRequest {
  final String provider;
  final ApplePayData data;

  ApplePayRequest({
    required this.provider,
    required this.data,
  });

  factory ApplePayRequest.fromJson(Map<String, dynamic> json) {
    return ApplePayRequest(
      provider: json['provider'],
      data: ApplePayData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'data': data.toJson(),
    };
  }
}

class ApplePayData {
  final String merchantIdentifier;
  final List<String> supportedNetworks;
  final List<String> merchantCapabilities;
  final String countryCode;
  final String currencyCode;
  final List<String> requiredShippingContactFields;
  final List<String> requiredBillingContactFields;
  ApplePayData({
    required this.supportedNetworks,
    required this.merchantCapabilities,
    required this.merchantIdentifier,
    required this.countryCode,
    required this.currencyCode,
    required this.requiredShippingContactFields,
    required this.requiredBillingContactFields,
  });
  factory ApplePayData.fromJson(Map<String, dynamic> json) {
    return ApplePayData(
      supportedNetworks: List<String>.from(json['supportedNetworks']),
      merchantCapabilities: List<String>.from(json['merchantCapabilities']),
      merchantIdentifier: json['merchantIdentifier'],
      countryCode: json['countryCode'],
      currencyCode: json['currencyCode'],
      requiredShippingContactFields:
          List<String>.from(json['requiredShippingContactFields']),
      requiredBillingContactFields:
          List<String>.from(json['requiredBillingContactFields']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "merchantIdentifier": merchantIdentifier,
      "merchantCapabilities": merchantCapabilities,
      "supportedNetworks": supportedNetworks,
      "countryCode": countryCode,
      "currencyCode": currencyCode,
      "requiredBillingContactFields": requiredBillingContactFields,
      "requiredShippingContactFields": requiredShippingContactFields,
    };
  }
}
