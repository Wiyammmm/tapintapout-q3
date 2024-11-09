import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tps530/core/utls.dart';
import 'package:tps530/pages/homePage.dart';
import 'package:tps530/pages/widgets/appbar.dart';
import 'package:tps530/pages/widgets/basePage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!udpController.isConnected.value) {
      udpController.connectUDP();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(child: Obx(() {
      return Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppBarWidget(),
          Text(
            'UDP Settings',
            style: TextStyle(fontSize: 30, color: Colors.blueGrey),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'UDP Status: ',
                style: TextStyle(
                    // fontSize: 30,
                    ),
              ),
              Text(
                '${udpController.isConnected.value ? 'Connected' : 'Disconnected'}',
                style: TextStyle(
                    // fontSize: 30,
                    color: udpController.isConnected.value
                        ? Colors.green
                        : Colors.red),
              )
            ],
          ),
          SizedBox(
            width: 250,
            height: 60,
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: udpController.isConnected.value
                        ? MaterialStateProperty.all<Color>(Colors.redAccent)
                        : MaterialStateProperty.all<Color>(Colors.blueAccent)),
                onPressed: () async {
                  if (udpController.isConnected.value) {
                    await udpController.closeUDP();
                  } else {
                    await udpController.connectUDP();
                  }
                },
                child: FittedBox(
                  child: Text(
                    '${udpController.isConnected.value ? 'Disconnect' : 'Connect'} UDP',
                    // style: TextStyle(fontSize: 50),
                  ),
                )),
          ),
          const SizedBox(height: 10),
          if (udpController.isConnected.value)
            SizedBox(
              width: 250,
              height: 60,
              child: ElevatedButton(
                  onPressed: () {
                    udpController.sendMessage("hello from tps530");
                  },
                  child: const FittedBox(
                      child: Text(
                    'Send UDP Message',
                    // style: TextStyle(fontSize: 50),
                  ))),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: udpController.messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(udpController.messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    if (udpController.isConnected.value &&
                        dataController.coopData['cooperativeCodeName'] !=
                            'Unknown') {
                      dialogServices.showLoadingDialog(context);

                      Future.delayed(Duration(seconds: 2), () {
                        // After the delay (or your async task is complete), close the dialog
                        Navigator.of(context).pop(); // Close the loading dialog

                        // Then navigate to the next page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      });
                    } else {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return const AlertDialog(
                            title: Text(
                              'Not Connected',
                              textAlign: TextAlign.center,
                              // style: TextStyle(fontSize: 40),
                            ),
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Please Connect to UDP or receive data first',
                                    textAlign: TextAlign.center,
                                    // style: TextStyle(fontSize: 25),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                  child: const FittedBox(
                      child: Text(
                    'Proceed',
                    // style: TextStyle(fontSize: 50),
                  ))),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      );
    }));

    // Scaffold(
    //     appBar: AppBar(title: Text('NFC Reader')),
    //     body: Center(
    //       child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    //         Text(
    //           _nfcData,
    //           style: TextStyle(fontSize: 24),
    //         ),
    //         SizedBox(height: 20),
    //         ElevatedButton(
    //           onPressed: _startNfc,
    //           child: Text('Start NFC Read'),
    //         ),
    //         ElevatedButton(
    //           onPressed: _closeNfcRead,
    //           child: Text('Close NFC'),
    //         ),
    //         if (!isConnected) ...[
    //           ElevatedButton(
    //               onPressed: () {
    //                 connectUDP();
    //               },
    //               child: Text('Connect UDP')),
    //         ],
    //         if (isConnected) ...[
    //           ElevatedButton(
    //               onPressed: () {
    //                 sendMessage("hello from tps530");
    //               },
    //               child: Text('Send UDP Message')),
    //           ElevatedButton(
    //               onPressed: () {
    //                 closeUDP();
    //               },
    //               child: Text('Close UDP')),
    //           Expanded(
    //             child: ListView.builder(
    //               itemCount: _messages.length,
    //               itemBuilder: (context, index) {
    //                 return ListTile(
    //                   title: Text(_messages[index]),
    //                 );
    //               },
    //             ),
    //           )
    //         ]
    //       ]),
    //     ));
  }
}
