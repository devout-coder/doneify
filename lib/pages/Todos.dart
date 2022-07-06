import 'package:conquer_flutter_app/pages/Daily.dart';
import 'package:flutter/material.dart';

class Todos extends StatefulWidget {
  const Todos({Key? key}) : super(key: key);

  @override
  State<Todos> createState() => _TodosState();
}

class _TodosState extends State<Todos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Daily")),
      backgroundColor: Color(0xff262647),
    );
  }
}
