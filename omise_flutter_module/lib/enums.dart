enum MethodNames {
  selectPaymentMethod,
  authorizePayment,
  openGooglePay,
  openCardPage,
  unknown
}

extension MethodNamesExtension on MethodNames {
  static MethodNames fromString(String? methodName) {
    return MethodNames.values.firstWhere(
      (method) => method.name.toLowerCase() == methodName?.toLowerCase(),
      orElse: () => MethodNames.unknown,
    );
  }
}
