import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omise_flutter/omise_flutter.dart';
import 'package:omise_flutter_module/controllers/method_channel_controller.dart';
import 'package:omise_flutter_module/enums.dart';
import 'package:omise_flutter_module/services/method_channel_service.dart';

void main() {
  runApp(const FlutterUIBridge());
}

/// An intermediate UI class that displays and empty container
/// in order to be able to initialize the method channel code
/// with a context that enables navigation.
class FlutterUIBridge extends StatefulWidget {
  const FlutterUIBridge({super.key});
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<FlutterUIBridge> createState() => _FlutterUIBridgeState();
}

class _FlutterUIBridgeState extends State<FlutterUIBridge> {
  final MethodChannelController methodChannelController =
      MethodChannelController();

  @override
  void initState() {
    super.initState();
    MethodChannelService.setupMethodChannel(methodChannelController);
  }

  Widget selectedPage() {
    final methodName = methodChannelController.value.methodName;
    switch (methodName) {
      case MethodNames.selectPaymentMethod:
        final OmisePayment omisePayment =
            OmisePayment(publicKey: methodChannelController.value.pkey!);
        return omisePayment.selectPaymentMethod(
            amount: methodChannelController.value.amount!,
            currency: methodChannelController.value.currency!);

      case MethodNames.authorizePayment:
        final OmisePayment omisePayment =
            OmisePayment(publicKey: methodChannelController.value.pkey!);
        return omisePayment.authorizePayment(
          authorizeUri: Uri.parse(methodChannelController.value.authUrl!),
          expectedReturnUrls: methodChannelController.value.expectedReturnUrls,
        );
      case null:
        return const SizedBox.shrink();
      case MethodNames.unknown:
        throw PlatformException(
          code: 'METHOD_NOT_IMPLEMENTED',
          message:
              'The method ${methodName.name} is not implemented in omise flutter module',
        );
    }
  }

  @override
  void dispose() {
    MethodChannelService.sendResultToNative(
        '${methodChannelController.value.methodName!.name}Result',
        {"demo": 10}).then((_) {
      super.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: FlutterUIBridge.navigatorKey,
        home: ValueListenableBuilder(
            valueListenable: methodChannelController,
            builder: (context, state, _) {
              return selectedPage();
            }));
  }
}
