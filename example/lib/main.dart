import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:omise_flutter/omise_flutter.dart';

void main() {
  runApp(const MyApp());
}

// The main app widget that sets up the application's theme and home page.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(
          title:
              'Flutter Demo Home Page'), // Sets MyHomePage as the home screen
    );
  }
}

// The main page widget containing UI and payment functions
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// State class for MyHomePage that handles payment actions
class _MyHomePageState extends State<MyHomePage> {
  // Omise payment instance, replace "pkey" with your actual Omise public key
  final omisePayment = OmisePayment(publicKey: "pkey", enableDebug: true);

  // Opens a page to select payment methods and handle token creation
  Future<void> _openPaymentMethodsPage() async {
    final OmisePaymentResult? omisePaymentResult =
        await Navigator.push<OmisePaymentResult>(
      context,
      MaterialPageRoute(
          builder: (context) => omisePayment.selectPaymentMethod(
              amount: 1000, currency: Currency.thb)),
    );

    // Check if payment result is available
    if (omisePaymentResult == null) {
      log('No payment'); // Logs if no payment was made
    } else {
      // Logs token ID if available
      if (omisePaymentResult.token != null) {
        log(omisePaymentResult.token!.id);
      }
      if (omisePaymentResult.source != null) {
        log(omisePaymentResult.source!.id);
      }
    }
  }

  // Opens the authorization flow to authorize the payment
  Future<void> _openAuthorizePaymentPage() async {
    final OmiseAuthorizationResult? omiseAuthorizationResult =
        await Navigator.push<OmiseAuthorizationResult>(
      context,
      MaterialPageRoute(
          builder: (context) => omisePayment.authorizePayment(
                authorizeUri: Uri.parse(
                    "https://yourAuthUri"), // Replace with actual authorization URL
                expectedReturnUrls: [
                  "https://www.example.com/complete"
                ], // Expected return URL after authorization
              )),
    );

    // If authorization was completed in the WebView
    if (omiseAuthorizationResult != null) {
      if (omiseAuthorizationResult.isWebViewAuthorized == true) {
        log("Payment authorized"); // Logs if payment was authorized
      }
      // Note: Always verify payment status on backend after authorization
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _openPaymentMethodsPage(); // Button triggers payment method selection
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
              height: 20, // Space between buttons
            ),
            ElevatedButton(
              onPressed: () {
                _openAuthorizePaymentPage(); // Button triggers authorization page
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
