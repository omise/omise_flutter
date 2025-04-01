import 'package:flutter/services.dart';

// This service should not be used in omise_flutter and should only be used in the omise_flutter_module
// but in order to solve the brief black screen issue when closing the omise flutter SDK form the native side
// we have to send the result early from the omise flutter SDK directly and not from the omise flutter module.
class MethodChannelService {
  static MethodChannel methodChannel =
      const MethodChannel('omiseFlutterChannel');

  static Future<void> sendResultToNative(
      String nativeResultMethodName, Map<String, dynamic>? result) async {
    await methodChannel.invokeMethod(nativeResultMethodName, result);
  }
}
