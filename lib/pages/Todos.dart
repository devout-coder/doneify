import 'package:conquer_flutter_app/pages/Daily.dart';
import 'package:flutter/material.dart';

class Todos extends StatefulWidget {
  final DateTime day;
  const Todos({Key? key, required this.day}) : super(key: key);

  @override
  State<Todos> createState() => _TodosState();
}

class _TodosState extends State<Todos> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(widget.day.toString())),
      // backgroundColor: Color(0xff262647),
    );
  }
}
