import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingsButton extends StatefulWidget {
  String pageName;
  String page;
  double buttonWidth;
  SettingsButton({
    super.key,
    required this.buttonWidth,
    required this.page,
    required this.pageName,
  });

  @override
  State<SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          "/${widget.page}",
        );
      },
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Color.fromRGBO(217, 217, 217, 0.16))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.pageName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              )),
          SizedBox(width: widget.buttonWidth, height: 50),
          Icon(
            Icons.keyboard_arrow_right,
            size: 24.0,
          ),
        ],
      ),
    );
  }
}
