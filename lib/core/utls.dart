import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:tps530/controllers/data_controller.dart';
import 'package:tps530/controllers/nfc_controller.dart';
import 'package:tps530/controllers/udp_controller.dart';
import 'package:tps530/services/dialog.dart';
import 'package:tps530/services/nfc_services_methodChannel.dart';

final NfcServiceMethodChannel nfcService = NfcServiceMethodChannel();
NfcController nfcController = Get.put(NfcController());
DataController dataController = Get.put(DataController());
UdpServices udpController = Get.put(UdpServices());
DialogServices dialogServices = DialogServices();
FlutterTts flutterTts = FlutterTts();
