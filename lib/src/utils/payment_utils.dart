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

  static Set<PaymentMethodName> sharedShopeeAssets = {
    PaymentMethodName.shopeePay,
    PaymentMethodName.shopeePayJumpapp,
  };
  static Set<PaymentMethodName> sharedTruemoneyAssets = {
    PaymentMethodName.truemoney,
    PaymentMethodName.truemoneyJumpapp,
  };
  static Set<String> sharedMayBankAssets = {
    PaymentMethodName.mayBankQr.value,
    BankCode.maybank2e.value,
    BankCode.maybank2u.value,
  };
  static Set<String> sharedUobAssets = {
    PaymentMethodName.installmentUob.value,
    PaymentMethodName.installmentWlbUob.value,
    BankCode.uob.value,
  };

  static Set<PaymentMethodName> grabPartners = {PaymentMethodName.grabpay};
  static Set<PaymentMethodName> alipayPartners = {
    PaymentMethodName.alipayCn,
    PaymentMethodName.alipayHk,
    PaymentMethodName.touchNGo,
    PaymentMethodName.dana,
    PaymentMethodName.gcash,
    PaymentMethodName.kakaopay,
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
    if (sharedShopeeAssets.contains(paymentMethod)) {
      return 'assets/payment_shopeepay.png';
    }
    if (sharedTruemoneyAssets.contains(paymentMethod)) {
      return 'assets/payment_truemoney.png';
    }
    if (sharedMayBankAssets.contains(paymentMethod?.value)) {
      return 'assets/payment_maybank.png';
    }
    if (sharedUobAssets.contains(paymentMethod?.value)) {
      return 'assets/payment_uob.png';
    }
    // Default behavior: Use method name as filename
    return 'assets/${customPaymentMethod?.value ?? paymentMethod!.value.replaceAll('_wlb', '')}.png';
  }

  static String getBankImageName(BankCode bankName) {
    if (sharedMayBankAssets.contains(bankName.value)) {
      return 'assets/payment_maybank.png';
    }
    if (sharedUobAssets.contains(bankName.value)) {
      return 'assets/payment_uob.png';
    }
    return 'assets/fpxBanks/${bankName.value}.png';
  }
}
