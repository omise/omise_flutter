import 'package:flutter/material.dart';
import 'package:omise_flutter/omise_flutter.dart';
import 'package:omise_flutter_module/enums.dart';

/// The [MethodChannelController] manages the state and logic for
/// creating a mobile banking source from Omise API.
class MethodChannelController extends ValueNotifier<MethodChannelState> {
  /// Constructor for initializing [MethodChannelController].
  MethodChannelController() : super(MethodChannelState());

  void setMethodChannelArguments({
    required MethodNames methodName,
    String? pkey,
    int? amount,
    Currency? currency,
    String? authUrl,
    List<String>? expectedReturnUrls,
  }) {
    _setValue(value.copyWith(
        methodName: methodName,
        amount: amount,
        currency: currency,
        authUrl: authUrl,
        expectedReturnUrls: expectedReturnUrls,
        pkey: pkey));
  }

  /// Internal helper function to update the state of [ValueNotifier].
  void _setValue(MethodChannelState state) {
    value = state;
  }
}

/// State class that holds the values for [MethodChannelController].
class MethodChannelState {
  /// The method name passed from native to flutter
  final MethodNames? methodName;

  // The pkey passed from native to flutter
  final String? pkey;

  /// The amount used in source creation.
  final int? amount;

  /// The currency used in source creation.
  final Currency? currency;

  /// The url to authorize the charge
  final String? authUrl;

  /// A list of URLs that are expected as return URLs from the WebView.
  final List<String>? expectedReturnUrls;

  /// Constructor for creating a [MethodChannelState].
  MethodChannelState({
    this.pkey,
    this.amount,
    this.currency,
    this.methodName,
    this.authUrl,
    this.expectedReturnUrls,
  });

  /// Creates a copy of the current state while allowing overriding of
  /// specific fields. This is needed since in order to trigger a rebuild on the value notifier level, we need a new instance to be created for non primitive types.
  MethodChannelState copyWith({
    String? pkey,
    int? amount,
    Currency? currency,
    MethodNames? methodName,
    String? authUrl,
    List<String>? expectedReturnUrls,
  }) {
    return MethodChannelState(
        pkey: pkey ?? this.pkey,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        methodName: methodName ?? this.methodName,
        authUrl: authUrl ?? this.authUrl,
        expectedReturnUrls: expectedReturnUrls ?? this.expectedReturnUrls);
  }
}
