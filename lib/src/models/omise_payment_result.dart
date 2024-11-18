import 'package:omise_dart/omise_dart.dart';

class OmisePaymentResult {
  final Token? token;
  final Source? source;

  OmisePaymentResult({this.token, this.source});
}
