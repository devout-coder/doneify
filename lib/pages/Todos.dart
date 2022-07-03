import 'package:flutter/material.dart';

class Todos extends StatefulWidget {
  const Todos({Key? key}) : super(key: key);

  @override
  State<Todos> createState() => _TodosState();
}

class _TodosState extends State<Todos> {
  bool mySwitch = false;
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text("all the created todos"),
      backgroundColor: Color(0xff262647),
    );
  }
}
