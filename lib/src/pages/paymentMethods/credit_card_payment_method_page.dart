import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:omise_flutter/src/widgets/rounded_text_feild.dart';

class CreditCardPaymentMethodPage extends StatefulWidget {
  final bool automaticallyImplyLeading;
  const CreditCardPaymentMethodPage(
      {super.key, this.automaticallyImplyLeading = true});

  @override
  State<CreditCardPaymentMethodPage> createState() =>
      _CreditCardPaymentMethodPageState();
}

class _CreditCardPaymentMethodPageState
    extends State<CreditCardPaymentMethodPage> {
  final countryPicker = const FlCountryCodePicker();
  var selectedCountry = CountryCode.fromCode("TH")!;
  var avsCountries = [
    CountryCode.fromCode("US")!,
    CountryCode.fromCode("CA"),
    CountryCode.fromCode("GB")!
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Credit Card"),
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 20, right: 20),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 20.0, top: 20),
            child: RoundedTextField(
                title: "Card Number",
                validationType: ValidationType.cardNumber),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: RoundedTextField(
                title: "Name on card", validationType: ValidationType.name),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: 12.0,
                    ),
                    child: RoundedTextField(
                        title: "Expiry date",
                        validationType: ValidationType.expiryDate),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 12.0,
                    ),
                    child: RoundedTextField(
                        title: "Security code",
                        validationType: ValidationType.cvv),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              "Country or region",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: GestureDetector(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: Colors.grey, // Same as the TextField border color
                    width: 1.0,
                  ),
                ),
                child: Text(
                  selectedCountry.name,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
              ),
              onTap: () async {
                // Show the country code picker when tapped.
                final picked = await countryPicker.showPicker(context: context);
                // Null check
                if (picked != null) selectedCountry = picked;
                setState(() {});
              },
            ),
          ),
          if (avsCountries.contains(selectedCountry))
            const Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: RoundedTextField(
                      title: "Address", validationType: ValidationType.name),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: RoundedTextField(
                      title: "City", validationType: ValidationType.name),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: RoundedTextField(
                      title: "State", validationType: ValidationType.name),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: RoundedTextField(
                      title: "Postal code",
                      validationType: ValidationType.name),
                ),
              ],
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Filled blue color
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8.0), // Matching rounded corners
              ),
            ),
            child: const Text(
              'Pay',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white, // White text for contrast
              ),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
