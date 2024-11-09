import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tps530/core/utls.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(color: Colors.blueAccent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            child: Text(
              '${dataController.coopData['cooperativeName']}',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
