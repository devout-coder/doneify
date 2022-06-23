import 'package:conquer_flutter_app/pages/AllTodos.dart';
import 'package:flutter/material.dart';

class DailyPage extends StatelessWidget {
  const DailyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const AllTodos();
                },
              ),
            );
          },
          child: const Text("Open a todo")),
    );
  }
}
