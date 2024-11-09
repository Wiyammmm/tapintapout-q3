import 'package:flutter/services.dart';
import 'package:tps530/core/utls.dart';

class NfcServiceMethodChannel {
  static const MethodChannel platform = MethodChannel('com.example.tps530/nfc');

  Future<String?> getCardID() async {
    try {
      final String? cardID = await platform.invokeMethod('nfcListen');
      return cardID;
    } on PlatformException catch (e) {
      print("Failed to get card ID: '${e.message}'.");
      return null;
    }
  }

  Future<String?> openNfc() async {
    final String nfcOpen = await platform.invokeMethod('nfcOpen');
    print('nfcOpen: $nfcOpen');
    return nfcOpen;
  }

  Future<void> closeNfc() async {
    final String nfcClose = await platform.invokeMethod('nfcClose');
    print('nfcOpen: $nfcClose');
  }
}
