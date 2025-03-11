class GooglePayRequest {
  final String provider;
  final GooglePayData data;

  GooglePayRequest({
    required this.provider,
    required this.data,
  });

  factory GooglePayRequest.fromJson(Map<String, dynamic> json) {
    return GooglePayRequest(
      provider: json['provider'],
      data: GooglePayData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'data': data.toJson(),
    };
  }
}

class GooglePayData {
  final String environment;
  final int apiVersion;
  final int apiVersionMinor;
  final MerchantInfo merchantInfo;
  final List<AllowedPaymentMethod> allowedPaymentMethods;
  final TransactionInfo transactionInfo;
  GooglePayData({
    required this.environment,
    required this.apiVersion,
    required this.apiVersionMinor,
    required this.merchantInfo,
    required this.allowedPaymentMethods,
    required this.transactionInfo,
  });
  factory GooglePayData.fromJson(Map<String, dynamic> json) {
    return GooglePayData(
      environment: json['environment'],
      apiVersion: json['apiVersion'],
      apiVersionMinor: json['apiVersionMinor'],
      merchantInfo: MerchantInfo.fromJson(json['merchantInfo']),
      allowedPaymentMethods: (json['allowedPaymentMethods'] as List)
          .map((e) => AllowedPaymentMethod.fromJson(e))
          .toList(),
      transactionInfo: TransactionInfo.fromJson(json['transactionInfo']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'environment': environment,
      'apiVersion': apiVersion,
      'apiVersionMinor': apiVersionMinor,
      'merchantInfo': merchantInfo.toJson(),
      'allowedPaymentMethods':
          allowedPaymentMethods.map((e) => e.toJson()).toList(),
      'transactionInfo': transactionInfo.toJson(),
    };
  }
}

class MerchantInfo {
  final String merchantId;

  MerchantInfo({required this.merchantId});

  factory MerchantInfo.fromJson(Map<String, dynamic> json) {
    return MerchantInfo(
      merchantId: json['merchantId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchantId': merchantId,
    };
  }
}

class AllowedPaymentMethod {
  final String type;
  final PaymentParameters parameters;
  final TokenizationSpecification tokenizationSpecification;

  AllowedPaymentMethod({
    required this.type,
    required this.parameters,
    required this.tokenizationSpecification,
  });

  factory AllowedPaymentMethod.fromJson(Map<String, dynamic> json) {
    return AllowedPaymentMethod(
      type: json['type'],
      parameters: PaymentParameters.fromJson(json['parameters']),
      tokenizationSpecification:
          TokenizationSpecification.fromJson(json['tokenizationSpecification']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'parameters': parameters.toJson(),
      'tokenizationSpecification': tokenizationSpecification.toJson(),
    };
  }
}

class PaymentParameters {
  final List<String> allowedAuthMethods;
  final List<String> allowedCardNetworks;
  final bool billingAddressRequired;
  final BillingAddressParameters billingAddressParameters;

  PaymentParameters({
    required this.allowedAuthMethods,
    required this.allowedCardNetworks,
    required this.billingAddressRequired,
    required this.billingAddressParameters,
  });

  factory PaymentParameters.fromJson(Map<String, dynamic> json) {
    return PaymentParameters(
      allowedAuthMethods: List<String>.from(json['allowedAuthMethods']),
      allowedCardNetworks: List<String>.from(json['allowedCardNetworks']),
      billingAddressRequired: json['billingAddressRequired'],
      billingAddressParameters:
          BillingAddressParameters.fromJson(json['billingAddressParameters']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowedAuthMethods': allowedAuthMethods,
      'allowedCardNetworks': allowedCardNetworks,
      'billingAddressRequired': billingAddressRequired,
      'billingAddressParameters': billingAddressParameters.toJson(),
    };
  }
}

class BillingAddressParameters {
  final String format;
  final bool phoneNumberRequired;

  BillingAddressParameters({
    required this.format,
    required this.phoneNumberRequired,
  });

  factory BillingAddressParameters.fromJson(Map<String, dynamic> json) {
    return BillingAddressParameters(
      format: json['format'],
      phoneNumberRequired: json['phoneNumberRequired'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'format': format,
      'phoneNumberRequired': phoneNumberRequired,
    };
  }
}

class TokenizationSpecification {
  final String type;
  final Map<String, String> parameters;

  TokenizationSpecification({
    required this.type,
    required this.parameters,
  });

  factory TokenizationSpecification.fromJson(Map<String, dynamic> json) {
    return TokenizationSpecification(
      type: json['type'],
      parameters: Map<String, String>.from(json['parameters']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'parameters': parameters,
    };
  }
}

class TransactionInfo {
  final String totalPriceStatus;
  final String currencyCode;

  TransactionInfo({
    required this.totalPriceStatus,
    required this.currencyCode,
  });

  factory TransactionInfo.fromJson(Map<String, dynamic> json) {
    return TransactionInfo(
      totalPriceStatus: json['totalPriceStatus'],
      currencyCode: json['currencyCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPriceStatus': totalPriceStatus,
      'currencyCode': currencyCode,
    };
  }
}
