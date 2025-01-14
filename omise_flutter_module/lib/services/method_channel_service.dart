import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omise_flutter/omise_flutter.dart';

class MethodChannelService {
  static MethodChannel methodChannel =
      const MethodChannel('omiseFlutterChannel');

  static void setupMethodChannel(BuildContext context) {
    methodChannel.setMethodCallHandler((MethodCall call) async {
      final parsedArgs = jsonDecode(call.arguments) as Map<String, dynamic>;
      final String pkey = parsedArgs['pkey'];
      final OmisePayment omisePayment = OmisePayment(publicKey: pkey);
      switch (call.method) {
        case 'selectPaymentMethod':
          _openPaymentMethodsPage(context, omisePayment, parsedArgs);

        case 'authorizePayment':
          _openAuthorizePaymentPage(context, omisePayment, parsedArgs);

        default:
          throw PlatformException(
            code: 'METHOD_NOT_IMPLEMENTED',
            message:
                'The method ${call.method} is not implemented in omise flutter module',
          );
      }
    });
  }

  // Opens a page to select payment methods and handle token/source creation
  static Future<void> _openPaymentMethodsPage(BuildContext context,
      OmisePayment omisePayment, Map<String, dynamic> args) async {
    final OmisePaymentResult? omisePaymentResult =
        await Navigator.push<OmisePaymentResult>(
      context,
      MaterialPageRoute(
          builder: (context) => omisePayment.selectPaymentMethod(
              amount: args['amount'] as int,
              currency:
                  CurrencyExtension.fromString(args['currency'] as String))),
    );

    methodChannel.invokeMethod(
        'paymentMethodResult', jsonEncode(omisePaymentResult?.toJson()));
  }

  // Opens the authorization flow to authorize the payment
  static Future<void> _openAuthorizePaymentPage(BuildContext context,
      OmisePayment omisePayment, Map<String, dynamic> args) async {
    final OmiseAuthorizationResult? omiseAuthorizationResult =
        await Navigator.push<OmiseAuthorizationResult>(
      context,
      MaterialPageRoute(
          builder: (context) => omisePayment.authorizePayment(
                authorizeUri: Uri.parse(args['authUrl'] as String),
                expectedReturnUrls: args['expectedReturnUrls'] as List<String>?,
              )),
    );
    methodChannel.invokeMethod(
        'authorizationResult', jsonEncode(omiseAuthorizationResult?.toJson()));
  }
}
