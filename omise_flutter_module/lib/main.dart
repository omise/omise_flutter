import 'package:flutter/material.dart';
import 'package:omise_flutter_module/services/method_channel_service.dart';

void main() {
  runApp(const FlutterUIBridge());
}

/// An intermediate UI class that displays and empty container
/// in order to be able to initialize the method channel code
/// with a context that enables navigation.
class FlutterUIBridge extends StatefulWidget {
  const FlutterUIBridge({super.key});

  @override
  State<FlutterUIBridge> createState() => _FlutterUIBridgeState();
}

class _FlutterUIBridgeState extends State<FlutterUIBridge> {
  @override
  void initState() {
    super.initState();
    MethodChannelService.setupMethodChannel(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
