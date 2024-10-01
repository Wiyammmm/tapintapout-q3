import 'package:flutter/services.dart';
import 'package:tps530/core/utls.dart';

class NfcServiceMethodChannel {
  static const platform = MethodChannel('com.example.tps530/nfc');
  static const eventChannel = MethodChannel('com.example.tps530/nfc');

  Future<void> openNfc() async {
    try {
      final result = await platform.invokeMethod('nfcOpen');
      print(result);
    } on PlatformException catch (e) {
      nfcController.nfcIsStart.value = false;
      print("Failed to open NFC: '${e.message}'.");
    }
  }

  Future<void> checkNfc() async {
    try {
      final result = await platform.invokeMethod('nfcCheck');
      print(result);
    } on PlatformException catch (e) {
      print("Failed to check NFC: '${e.message}'.");
    }
  }

  Future<void> closeNfc() async {
    try {
      final result = await platform.invokeMethod('nfcClose');
      print(result);
    } on PlatformException catch (e) {
      print("Failed to close NFC: '${e.message}'.");
    }
  }

  void onNfcDataReceived(Function(String) onData) {
    platform.setMethodCallHandler((call) async {
      if (call.method == "onNfcDataReceived") {
        String tagId = call.arguments;
        onData(tagId);
      }
    });
  }
}
