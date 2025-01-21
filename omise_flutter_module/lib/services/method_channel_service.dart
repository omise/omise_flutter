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
      final String pkey = parsedArgs['pkey'];
      final int? amount = parsedArgs['amount'];
      final Currency? currency =
          CurrencyExtension.fromString(parsedArgs['currency'] as String?);
      final String? authUrl = parsedArgs['authUrl'];
      final List<String>? expectedReturnUrls = parsedArgs['expectedReturnUrls'];
      methodChannelController.setMethodChannelArguments(
          methodName: MethodNamesExtension.fromString(call.method),
          pkey: pkey,
          amount: amount,
          currency: currency,
          authUrl: authUrl,
          expectedReturnUrls: expectedReturnUrls);
    });
  }

  static Future<void> sendResultToNative(
      String nativeResultMethodName, Map<String, dynamic> result) async {
    await methodChannel.invokeMethod(nativeResultMethodName, result);
  }
}
