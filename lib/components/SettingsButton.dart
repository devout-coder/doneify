import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingsButton extends StatefulWidget {
  String title;
  double buttonWidth;
  Function onPressed;
  Icon icon;
  SettingsButton({
    super.key,
    required this.buttonWidth,
    required this.onPressed,
    required this.title,
    required this.icon,
  });

  @override
  State<SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => widget.onPressed(),
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Color.fromRGBO(217, 217, 217, 0.16))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              )),
          SizedBox(width: widget.buttonWidth, height: 50),
          widget.icon,
        ],
      ),
    );
  }
}
