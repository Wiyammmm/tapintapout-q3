import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:tps530/core/utls.dart';
import 'package:tps530/pages/settingsPage.dart';
import 'package:udp/udp.dart';
import 'dart:convert';

class UdpServices extends GetxService {
  Rx<UDP?> sender = Rx<UDP?>(null);
  var myIp = "".obs;
  RxList<String> messages = <String>[].obs;
  var isConnected = false.obs;
  int sunmiPort = 1212;
  int myPort = 1515;

  Future<void> connectUDP() async {
    try {
      _getIp();
      // Set up the sender
      // sender = await UDP.bind(Endpoint.any(port: Port(sunmiPort)));
      sender.value = await UDP.bind(
        Endpoint.unicast(
          InternetAddress(myIp.toString()),
          port: Port(myPort), // Specify the local port you want to bind
        ),
      );

      await sendMessage('test message from tps530');

      // Listen for incoming messages
      sender.value?.asStream().listen((datagram) async {
        var str = String.fromCharCodes(datagram!.data);

        await checkMessage(str);

        // messages.add("Received: $str");
        messages.add("${messages.length}. Received from driver's device");
        messages.refresh();
      }, onDone: () {
        isConnected.value = false;
        messages.clear();
      }, onError: (e) {
        isConnected.value = false;
        messages.clear();
      });

      isConnected.value = true;
      messages.refresh();
      isConnected.refresh();
      sender.refresh();
    } catch (e) {
      print("Error setting up UDP: $e");
    }
  }

  // Send a message
  Future<void> sendMessage(String message) async {
    try {
      if (sender != null) {
        message += ",ip:$myIp";
        var dataLength = await sender.value?.send(
          message.codeUnits,
          Endpoint.broadcast(port: Port(sunmiPort)),
          // Endpoint.loopback(port: Port(sunmiPort)),
        );
        if (dataLength != null && dataLength > 0) {
          // messages.add('sent: $message');
          messages.add('${messages.length}. sent message');
          messages.refresh();
        } else {
          print('not connected');
          if (Navigator.of(Get.context!).canPop()) {
            Navigator.of(Get.context!)
                .pop(); // This will close the dialog if it's open
          } else {
            print("No active dialog to close.");
          }
          speak("Disconnected to Driver's device!");
          dialogServices.showErrorDialog(Get.context!, 'Disconnected',
              "Please connect to driver's device");
        }

        print("$dataLength bytes sent.");
      }
    } catch (e) {
      print('send message error: $e');
      if (Navigator.of(Get.context!).canPop()) {
        Navigator.of(Get.context!)
            .pop(); // This will close the dialog if it's open
      } else {
        print("No active dialog to close.");
      }
      speak("Disconnected to Driver's device!");
      dialogServices.showErrorDialog(
          Get.context!, 'Disconnected', "Please connect to driver's device");
    }
  }

  Future<void> closeUDP() async {
    await sendMessage('close:true');

    messages.clear();
    isConnected.value = false;
    messages.refresh();
    isConnected.refresh();
    if (sender.value != null) {
      sender.value?.close();
    }
    await dataController.resetCoopData();
    sender.refresh();
  }

  Future<void> _getIp() async {
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();
    if (wifiIP != null) {
      myIp.value = wifiIP;
    }

    print("wifiIP: $wifiIP");
  }

  Future<void> checkMessage(String input) async {
    if (Get.context != null) {
      if (Navigator.of(Get.context!).canPop()) {
        Navigator.of(Get.context!)
            .pop(); // This will close the dialog if it's open
      } else {
        print("No active dialog to close.");
      }
    }

    print('received: $input');
    // Regular expression to match 'close' and 'ip'
    RegExp regexClose = RegExp(r'close:(true|false)');
    // RegExp regexTapin = RegExp(r'tapin:(true|false)');
    // RegExp tapoutRegex = RegExp(r'tapout:([0-9.]+)');
    RegExp errorRegex = RegExp(r'error:\s*(.+)');
    bool isCoopData = input.contains('coopData:');

    // Match the pattern
    var matchClose = regexClose.firstMatch(input);
    // var matchTapin = regexTapin.firstMatch(input);
    // var matchTapout = tapoutRegex.firstMatch(input);
    var matchError = errorRegex.firstMatch(input);
    if (matchClose != null) {
      // Extract the close status and IP address
      String closeStatus = matchClose.group(1)!; // true or false

      print('close: $closeStatus');

      await closeUDP();
      Get.offAll(() => SettingsPage());
    } else if (input.contains('tapin:')) {
      print('tapin');
      String extractedString = input.split('tapin:')[1].trim();
      extractedString = extractedString.replaceAll("'", '"');
      try {
        Map<String, dynamic> tapinMap = jsonDecode(extractedString);
        if (Get.context != null) {
          speak('Tap-in Successfully!');
          dialogServices.showTapin(Get.context!, tapinMap['fare']);
        }
      } catch (e) {
        print("Error decoding JSON: $e");
      }
      // showLoadingDialog('Welcome!', 'Have a safe ride');
    } else if (input.contains('tapout:')) {
      print('tapout');
      String extractedString = input.split('tapout:')[1].trim();
      extractedString = extractedString.replaceAll("'", '"');
      try {
        // Decode the string into a Map<String, dynamic>
        Map<String, dynamic> tapoutMap = jsonDecode(extractedString);
//  String tapoutValue = matchTapout.group(1)!;
        if (Get.context != null) {
          speak('Tap-out Successfully!');
          dialogServices.showTapout(Get.context!, tapoutMap);
        }
        // Print the Map to verify
        print(tapoutMap);
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    } else if (matchError != null) {
      print('error');
      String errorMessage = matchError.group(1)!.trim();
      speak('$errorMessage');
      showLoadingDialog('${errorMessage}', '');
    } else if (isCoopData) {
      String jsonString =
          input.replaceFirst('coopData: ', '').replaceAll(RegExp(r'{|}'), '');

      // Split by comma and then split each pair by the colon
      Map<String, dynamic> result = {};
      List<String> keyValuePairs = jsonString.split(', ');

      for (String pair in keyValuePairs) {
        List<String> keyValue = pair.split(': ');
        if (keyValue.length == 2) {
          String key = keyValue[0];
          String value = keyValue[1];
          result[key] = value;
        }
      }
      if (result.isNotEmpty) {
        await dataController.updateCoopData(result);
        speak('Data Received!');
      }
      print('result: $result');
    } else {
      // Handle case when 'close' and 'ip' are not found
      print('No match found');
    }
  }

  Future<void> showLoadingDialog(String title, String label) async {
    if (Get.context != null) {
      showDialog<void>(
        context: Get.context!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 25),
                ),
              ],
            ),
          );
        },
      );
    } else {
      print("No context found for showing the dialog.");
    }
  }

  Future speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.2);
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.speak(text);
  }
}
