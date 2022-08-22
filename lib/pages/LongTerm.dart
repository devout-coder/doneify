import 'package:conquer_flutter_app/pages/Todos.dart';
import 'package:flutter/material.dart';

class LongTermPage extends StatelessWidget {
  const LongTermPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Todos(time: "longTerm", timeType: "longTerm");
  }
}
