import 'package:get/get.dart';
import 'package:tps530/core/utls.dart';
import 'package:tps530/services/nfc_services_methodChannel.dart';

class NfcController extends GetxController {
  // var tagId = "".obs;
  // var nfcData = "Waiting for NFC Data...".obs;
  Duration debounceDuration = const Duration(seconds: 3);
  DateTime? _lastExecutionTime;
  var nfcIsStart = false.obs;
  int i = 0;
  // Future<void> startNfc() async {
  //   await nfcService.openNfc();
  //   await nfcService.checkNfc();
  //   nfcIsStart.value = true;
  // }

  // Future<void> readNFC() async {
  //   await nfcService.checkNfc();
  // }

  // Future<void> closeNfcRead() async {
  //   await nfcService.closeNfc();
  //   nfcIsStart.value = false;
  // }

  // Future<void> nfcDataReceived() async {
  //   nfcService.onNfcDataReceived((data) {
  //     DateTime now = DateTime.now();
  //     if (_lastExecutionTime == null ||
  //         now.difference(_lastExecutionTime!) > debounceDuration) {
  //       print('data $i: $data');
  //       i++;
  //       udpController.sendMessage(data);
  //       // endpointMap.forEach((key, value) {
  //       //   showSnackbar("uid: $data");
  //       //   Nearby().sendBytesPayload(key, Uint8List.fromList(data.codeUnits));
  //       // });

  //       nfcData.value = data;

  //       _lastExecutionTime = now;
  //     }
  //   });
  // }

// new

  final NfcServiceMethodChannel cardReader = NfcServiceMethodChannel();
  var nfcData = "".obs; // Observable string
  var tagId = "".obs;
  // @override
  // void onInit() {
  //   super.onInit();
  //   _openNfc();
  //   detectCard();
  // }

  Future<void> openNfc() async {
    await cardReader.openNfc();
    nfcIsStart.value = true;
  }

  bool isMessageSent = false;
  Future<void> detectCard() async {
    print("detectCard called");
    final id = await cardReader.getCardID();
    tagId.value = id ?? "Failed to read card ID"; // Update observable

    DateTime now = DateTime.now();

    if (_lastExecutionTime == null ||
        now.difference(_lastExecutionTime!) > debounceDuration) {
      tagId.value = id ?? "Failed to read card ID"; // Update observable
      if (id != null) {
        String idFinal = "";

        try {
          int number = int.parse(id);
          if (number <= 0) {
            detectCard();
          } else {
            idFinal = id;
          }
        } catch (e) {
          print(e);
          idFinal = id;
        }
        isMessageSent = true;

        udpController.sendMessage("uid:$idFinal");

        nfcData.value = id;

        _lastExecutionTime = now;
      }
    }
    if (id == null) {
      isMessageSent = false;
    }
    await Future.delayed(Duration(seconds: 3));
    detectCard();
  }

  Future<void> closeNfc() async {
    await cardReader.closeNfc();
    nfcIsStart.value = false;
  }
// end new
}
