# omise_flutter

**omise_flutter** is a Flutter plugin for integrating Omise's payment API. This package provides a user-friendly interface for handling tokenization, payment authorization, and other payment-related functionalities directly in Flutter applications.

## Features

- Direct integration with Omise's payment gateway in Flutter apps.
- Easy-to-use tokenization and authorization flows.
- Easy-to-use source creation flows.
  - Supported sources:
    - `promptpay`
- Built-in support for common error handling in payment processing.

## Getting Started

To use the package, add it to your project by including the following in your `pubspec.yaml`:

```yaml
dependencies:
  omise_flutter: ^0.1.0
```

Run:

```bash
flutter pub get
```

You will also need an Omise account and public/private keys, which you can obtain by signing up at the [Omise Dashboard](https://dashboard.omise.co).

## Usage

Here's an example of how to create a token using **omise_flutter**:

```dart
import 'package:flutter/material.dart';
import 'package:omise_flutter/omise_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omise Flutter Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

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
          builder: (context) =>
              omisePayment.selectPaymentMethod(selectedPaymentMethods: [
                PaymentMethodName.card, // Only showing card as payment method
              ])),
    );

    // Check if payment result is available
    if (omisePaymentResult == null) {
      log('No payment'); // Logs if no payment was made
    } else {
      // Logs token ID if available
      if (omisePaymentResult.token != null) {
        log(omisePaymentResult.token!.id);
      }
      // Other payment results (like source creation) can be handled here
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
          ],
        ),
      ),
    );
  }
}
```

## Example

In the `example/` folder, you will find more comprehensive examples showing various use cases, such as:

- Creating a token
- Authorizing a payment

To run the examples:

1. Clone the repository.
2. Run the Flutter example using:

```bash
flutter run example/lib/main.dart
```

## Documentation

Complete API documentation is available at [pub.dev documentation](https://pub.dev/documentation/omise_flutter/latest).

For the Omise API documentation, refer to the official [Omise API docs](https://www.omise.co/docs).

## Contributing

We welcome contributions! Please follow these steps to contribute:

1. Fork this repository.
2. Create a feature branch: `git checkout -b my-feature`.
3. Commit your changes: `git commit -m 'Add some feature'`.
4. Push to the branch: `git push origin my-feature`.
5. Open a pull request.

For bugs or feature requests, please [create an issue](https://github.com/omise/omise_flutter/issues).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
