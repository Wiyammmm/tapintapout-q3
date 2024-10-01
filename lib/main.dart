import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tps530/core/theme.dart';
import 'package:tps530/core/utls.dart';
import 'package:tps530/pages/settingsPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await udpController.connectUDP();
  // await nfcController.startNfc();
  // await nfcController.readNFC();
  // await nfcController.nfcDataReceived();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Filipay',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: SettingsPage(),
    );
  }
}
