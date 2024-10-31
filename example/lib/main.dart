import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:omise_flutter/omise_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final omisePayment = OmisePayment(publicKey: "pkey", enableDebug: true);
  Future<void> _openPaymentMethodsPage() async {
    final OmisePaymentResult? omisePaymentResult =
        await Navigator.push<OmisePaymentResult>(
      context,
      MaterialPageRoute(
          builder: (context) =>
              omisePayment.selectPaymentMethod(selectedPaymentMethods: [
                PaymentMethodName.card,
              ])),
    );
    if (omisePaymentResult == null) {
      log('No payment');
    } else {
      if (omisePaymentResult.token != null) {
        log(omisePaymentResult.token!.id);
      }
      // Handle other payment results like source creation
    }
  }

  Future<void> _openAuthorizePaymentPage() async {
    final OmiseAuthorizationResult? omiseAuthorizationResult =
        await Navigator.push<OmiseAuthorizationResult>(
      context,
      MaterialPageRoute(
          builder: (context) => omisePayment.authorizePayment(
                authorizeUri: Uri.parse("https://yourAuthUri"),
                expectedReturnUrls: ["https://www.example.com/complete"],
              )),
    );
    if (omiseAuthorizationResult != null) {
      if (omiseAuthorizationResult.isWebViewAuthorized == true) {
        // This indicates that the payment has been authorized using the expected flow, you can check the status using your backend integration.
        // If you receive null/false this does not mean that the payment has not been authorized, you should check the status of the payment
        // after the authorization page has been closed.
        log("Payment authorized");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _openPaymentMethodsPage();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 12.0),
              ),
              child: const Text('Choose payment method'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                _openAuthorizePaymentPage();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 12.0),
              ),
              child: const Text('Authorize payment'),
            )
          ],
        ),
      ),
    );
  }
}
