import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Auth extends StatefulWidget {
  String type;
  Auth({super.key, required this.type});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.type),
      ],
    );
  }
}
