import 'package:flutter/services.dart';

class SafetyNetService {
  static const MethodChannel _channel = MethodChannel('safetynet_channel');

  Future<String> verifyRecaptcha(String siteKey) async {
    try {
      final String userResponseToken = await _channel.invokeMethod(
        'verifyRecaptcha',
        {'siteKey': siteKey},
      );
      return userResponseToken;
    } on PlatformException catch (e) {
      return "Error: ${e.message}";
    }
  }
}