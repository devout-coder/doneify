import 'package:flutter/material.dart';

class WeeklyPage extends StatelessWidget {
  const WeeklyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Container(),
      onWillPop: () async {
        debugPrint('back is pressed in weekly');
        Navigator.pop(context, true);
        return false;
      },
    );
  }
}
