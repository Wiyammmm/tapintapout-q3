import 'package:get/get.dart';
import 'package:tps530/core/utls.dart';

class NfcController extends GetxController {
  var tagId = "".obs;
  var nfcData = "Waiting for NFC Data...".obs;
  Duration debounceDuration = const Duration(seconds: 3);
  DateTime? _lastExecutionTime;
  var nfcIsStart = false.obs;
  int i = 0;
  Future<void> startNfc() async {
    await nfcService.openNfc();
    await nfcService.checkNfc();
    nfcIsStart.value = true;
  }

  Future<void> readNFC() async {
    await nfcService.checkNfc();
  }

  Future<void> closeNfcRead() async {
    await nfcService.closeNfc();
    nfcIsStart.value = false;
  }

  Future<void> nfcDataReceived() async {
    nfcService.onNfcDataReceived((data) {
      DateTime now = DateTime.now();
      if (_lastExecutionTime == null ||
          now.difference(_lastExecutionTime!) > debounceDuration) {
        print('data $i: $data');
        i++;
        udpController.sendMessage(data);
        // endpointMap.forEach((key, value) {
        //   showSnackbar("uid: $data");
        //   Nearby().sendBytesPayload(key, Uint8List.fromList(data.codeUnits));
        // });

        nfcData.value = data;

        _lastExecutionTime = now;
      }
    });
  }
}
