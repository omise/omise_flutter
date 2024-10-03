import 'package:flutter/material.dart';
import 'package:omise_flutter/src/models/payment_method.dart';
import 'package:omise_flutter/src/widgets/payment_method_tile.dart';

class SelectPaymentMethodPage extends StatelessWidget {
  const SelectPaymentMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a payment method"),
        automaticallyImplyLeading: false,
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ],
      ),
      body: ListView(
        children: [
          paymentMethodTile(
            paymentMethod: PaymentMethod(
              name: "Credit Card",
              leadingIcon: Image.asset(
                'assets/credit.png',
                package: "omise_flutter",
              ),
              trailingIcon: Icons.arrow_outward,
              onTap: () {},
            ),
          )
        ],
      ),
    );
  }
}
