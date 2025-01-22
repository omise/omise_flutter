import 'package:omise_dart/omise_dart.dart';

class OmisePaymentResult {
  final Token? token;
  final Source? source;

  OmisePaymentResult({this.token, this.source});

  Map<String, dynamic> toJson() {
    return {
      'token': token?.toJson(),
      'source': source?.toJson(),
    };
  }
}
