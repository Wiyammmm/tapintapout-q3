import 'package:get/get.dart';

class DataController extends GetxController {
  var coopData = <String, dynamic>{
    "cooperativeName": "Unknown",
    "cooperativeCodeName": "Unknown"
  }.obs;

  Future<void> updateCoopData(Map<String, dynamic> data) async {
    coopData.value = data;
    coopData.refresh();
  }

  Future<void> resetCoopData() async {
    coopData.value = {
      "cooperativeName": "Unknown",
      "cooperativeCodeName": "Unknown"
    };
    coopData.refresh();
  }
}
