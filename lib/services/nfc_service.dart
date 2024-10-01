import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcService extends GetxController {
  var nfcData = ''.obs;

  void startNfcSession() async {
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (!isAvailable) {
      nfcData.value = "NFC is not available on this device.";
      return;
    }

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      NfcManager.instance.stopSession();
      // Extracting the NFC data
      nfcData.value = tag.data.toString();
    });
  }
}
