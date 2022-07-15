import 'package:flutter/material.dart';

class InputModal extends StatelessWidget {
  final action;
  const InputModal({Key? key, this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // return WillPopScope(
    return Container(
      // height: screenHeight * 0.5,
      // width: screenWidth,
      color: const Color(0xffBA99FF),
      height: screenHeight * 0.5,
      child: TextButton(
        onPressed: () {
          action.call();
          // setState(() {
          //   widget_shown = "button";
          // });
        },
        child: Text("Shit"),
      ),
    );
  }
}
