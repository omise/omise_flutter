import 'package:flutter/services.dart';
import 'package:omise_flutter/omise_flutter.dart';
import 'package:omise_flutter_module/controllers/method_channel_controller.dart';
import 'package:omise_flutter_module/enums.dart';

class MethodChannelService {
  static MethodChannel methodChannel =
      const MethodChannel('omiseFlutterChannel');

  static void setupMethodChannel(
      MethodChannelController methodChannelController) {
    methodChannel.setMethodCallHandler((MethodCall call) async {
      final parsedArgs = Map<String, dynamic>.from(call.arguments as Map);
      methodChannelController.setMethodChannelArguments(
        methodName: MethodNamesExtension.fromString(call.method),
        pkey: parsedArgs['pkey'],
        amount: parsedArgs['amount'],
        currency:
            CurrencyExtension.fromString(parsedArgs['currency'] as String?),
        authUrl: parsedArgs['authUrl'],
        expectedReturnUrls: parsedArgs['expectedReturnUrls'],
        selectedPaymentMethods: (parsedArgs['selectedPaymentMethods'] as List?)
            ?.map((e) => PaymentMethodNameExtension.fromString(e))
            .toList(),
        selectedTokenizationMethods:
            (parsedArgs['selectedTokenizationMethods'] as List?)
                ?.map((e) => TokenizationMethodExtension.fromString(e))
                .toList(),
        googlePayMerchantId: parsedArgs['googlePayMerchantId'],
        googlePayRequestBillingAddress:
            parsedArgs['googlePayRequestBillingAddress'],
        googlePayRequestPhoneNumber: parsedArgs['googlePayRequestPhoneNumber'],
        googlePayCardBrands: (parsedArgs['googlePayCardBrands'] as List?)
            ?.map((e) => e.toString())
            .toList(),
        googlePayEnvironment: parsedArgs['googlePayEnvironment'],
        googlePayItemDescription: parsedArgs['googlePayItemDescription'],
        applePayMerchantId: parsedArgs['applePayMerchantId'],
        applePayRequiredBillingContactFields:
            (parsedArgs['applePayRequiredBillingContactFields'] as List?)
                ?.map((e) => e.toString())
                .toList(),
        applePayRequiredShippingContactFields:
            (parsedArgs['applePayRequiredShippingContactFields'] as List?)
                ?.map((e) => e.toString())
                .toList(),
        applePayCardBrands: (parsedArgs['applePayCardBrands'] as List?)
            ?.map((e) => e.toString())
            .toList(),
        applePayItemDescription: parsedArgs['applePayItemDescription'],
        atomeItems: parsedArgs['atomeItems'] != null
            ? (parsedArgs['atomeItems'] as List)
                .map((e) => Item.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : null,
        environment: EnvironmentExtension.fromString(parsedArgs['environment']),
        cardHolderData: (parsedArgs['cardHolderData'] as List?)
            ?.map((e) => CardHolderDataExtension.fromString(e))
            .toList(),
      );
    });
  }
}
