import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:tps530/controllers/nfc_controller.dart';
import 'package:tps530/core/utls.dart';
import 'package:tps530/pages/settingsPage.dart';
import 'package:tps530/pages/widgets/appbar.dart';
import 'package:tps530/pages/widgets/basePage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Function you want to call when the widget loads
  Future<void> _initialize() async {
    // Your initialization logic here
    await nfcController.closeNfc();
    await nfcController.openNfc();
    await nfcController.detectCard();
    // await nfcController.nfcDataReceived();

    print("Initialization Complete");
  }

  int tapCount = 0;
  Timer? resetTimer;

  // Function to handle the tap
  void handleTap() {
    setState(() {
      tapCount++;
    });

    // If 7 consecutive taps are detected
    if (tapCount == 15) {
      print('naka 7 ka na');
      dialogServices.confirmationDialog(
          context, 'Confirmation', 'Do you want to go to Settings Page?', () {
        print('yes');
        Navigator.of(context).pop();
        dialogServices.showLoadingDialog(context);
        Future.delayed(Duration(seconds: 2), () async {
          await nfcController.closeNfc();
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
        });
      });
      resetTapCount(); // Reset after success
    } else {
      // Reset the tap count if no taps occur within 1 second
      resetTimer?.cancel(); // Cancel previous timer
      resetTimer = Timer(Duration(seconds: 1), () {
        resetTapCount();
      });
    }
  }

  // Function to reset the tap count
  void resetTapCount() {
    setState(() {
      tapCount = 0;
    });
  }

  @override
  void dispose() {
    resetTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
        child: RefreshIndicator(
      onRefresh: () async {
        _initialize();
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppBarWidget(),

            SizedBox(
              height: 60,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.only(right: 16),
            //       child: IconButton(
            //           onPressed: () async {
            //             print('go to settings page');
            //             await nfcController.closeNfcRead();

            //             Navigator.pushReplacement(
            //               context,
            //               MaterialPageRoute(builder: (context) => SettingsPage()),
            //             );
            //           },
            //           icon: Icon(
            //             Icons.settings,
            //             size: 50,
            //           )),
            //     )
            //   ],
            // ),
            GestureDetector(
              onTap: () {
                handleTap();
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => SettingsPage()),
                // );
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(200),
                    border: Border.all(color: Colors.blueAccent, width: 10)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    'assets/card-payment.png',
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Tap your Filipay Card',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ));
  }
}
