import 'package:flutter/material.dart';

class DialogServices {
  confirmationDialog(BuildContext context, String title, String label,
      VoidCallback onConfirm) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
            // style: TextStyle(fontSize: 40),
          ),
          content: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  label,
                  // style: TextStyle(fontSize: 25),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                      height: 50,
                      // width: 200,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.redAccent)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const FittedBox(
                            child: Text(
                              'NO',
                              // style: TextStyle(fontSize: 50),
                            ),
                          ))),
                  SizedBox(
                      height: 50,
                      // width: 200,
                      child: ElevatedButton(
                          onPressed: onConfirm,
                          child: const FittedBox(
                            child: Text(
                              'YES',
                              // style: TextStyle(fontSize: 50),
                            ),
                          )))
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void showErrorDialog(BuildContext context, String title, String label) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
            // style: TextStyle(fontSize: 40),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  // style: TextStyle(fontSize: 25),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text(
            'Loading',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 40),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Please wait...',
                style: TextStyle(fontSize: 25),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> showTapin(BuildContext context, double fare) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 5), () {
          if (context.mounted) {
            if (Navigator.of(context).mounted && Navigator.canPop(context)) {
              print('navigator pop?');
              Navigator.pop(context);
            }
          }
        });
        return AlertDialog(
          title: Image.asset(
            'assets/filipaylogobanner.png',
            width: 50,
            height: 50,
          ),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Your Traveled Fare is ${fare.toStringAsFixed(2)}',
                    // style: TextStyle(fontSize: 30),
                  ),
                  Text(
                    'WELCOME!\nHAVE A SAFE RIDE',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showTapout(
    BuildContext context,
    Map<String, dynamic> item,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 5), () {
          if (context.mounted) {
            if (Navigator.of(context).mounted && Navigator.canPop(context)) {
              print('navigator pop?');
              Navigator.pop(context);
            }
          }
        });
        return AlertDialog(
          title: Image.asset(
            'assets/filipaylogobanner.png',
            width: 50,
            height: 50,
          ),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Your Traveled Fare is ${double.parse(item['maxFare'].toString()).toStringAsFixed(2)}',
                    // style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'We had refund -${double.parse(item['refund'].toString()).toStringAsFixed(2)}',
                    // style: TextStyle(fontSize: 20),
                  ),
                  Divider(),
                  Text(
                    'Remaining Balance: ${double.parse('${item['remainingBalance']}').toStringAsFixed(2)}',
                    // style: TextStyle(fontSize: 20),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xffd9d9d9),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Traveled Distance',
                                // style: TextStyle(fontSize: 30),
                              ),
                              Text(
                                '${item['kmRun']}',
                                // style: TextStyle(fontSize: 30),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Traveled Fare',
                                // style: TextStyle(fontSize: 30),
                              ),
                              Text(
                                '${double.parse(item['fare'].toString()).toStringAsFixed(2)}',
                                // style: TextStyle(fontSize: 30),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Discount',
                                // style: TextStyle(fontSize: 30),
                              ),
                              Text(
                                '${double.parse(item['discount'].toString()).toStringAsFixed(2)}',
                                // style: TextStyle(fontSize: 30),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
