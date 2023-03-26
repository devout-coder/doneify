import 'package:doneify/pages/todos.dart';
import 'package:flutter/material.dart';

class LongTermPage extends StatelessWidget {
  const LongTermPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Todos(time: "longTerm", timeType: "longTerm");
  }
}
