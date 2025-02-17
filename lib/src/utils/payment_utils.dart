import 'package:omise_dart/omise_dart.dart';
import 'package:omise_flutter/src/enums/enums.dart';

class PaymentUtils {
  static Set<PaymentMethodName> sharedScbAssets = {
    PaymentMethodName.installmentScb,
    PaymentMethodName.installmentWlbScb,
  };

  static Set<PaymentMethodName> sharedBblAssets = {
    PaymentMethodName.installmentBbl,
    PaymentMethodName.installmentWlbBbl,
  };

  static Set<PaymentMethodName> sharedBayAssets = {
    PaymentMethodName.installmentBay,
    PaymentMethodName.installmentWlbBay,
  };

  static String getPaymentMethodImageName(
      {CustomPaymentMethod? customPaymentMethod,
      PaymentMethodName? paymentMethod}) {
    if (sharedScbAssets.contains(paymentMethod)) {
      return 'assets/installment_scb.png';
    }
    if (sharedBblAssets.contains(paymentMethod)) {
      return 'assets/installment_bbl.png';
    }
    if (sharedBayAssets.contains(paymentMethod)) {
      return 'assets/installment_bay.png';
    }
    // Default behavior: Use method name as filename
    return 'assets/${customPaymentMethod?.value ?? paymentMethod!.value.replaceAll('_wlb', '')}.png';
  }
}
