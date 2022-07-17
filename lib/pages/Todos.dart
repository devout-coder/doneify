import 'package:animations/animations.dart';
import 'package:conquer_flutter_app/pages/InputModal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:animations/animations.dart';

import 'package:conquer_flutter_app/pages/Daily.dart';

class Todos extends StatefulWidget {
  static const routeName = '/todos';
  final DateTime day;
  const Todos({Key? key, required this.day}) : super(key: key);

  @override
  State<Todos> createState() => _TodosState();
}

class _TodosState extends State<Todos> {
  String widget_shown = "button";

  String formattedDate() {
    final DateFormat formatter = DateFormat('d MMM');
    final String formatted = formatter.format(widget.day);
    return formatted;
  }

  Widget addButton() {
    return MaterialButton(
      shape: const CircleBorder(),
      color: const Color(0xffBA99FF),
      padding: const EdgeInsets.all(8),
      onPressed: () {
        setState(() {
          widget_shown = "modal";
        });
      },
      child: const Icon(
        Icons.add,
        size: 30,
        color: Color.fromARGB(255, 47, 15, 83),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          // width: screenWidth * 0.3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 60,
              ),
              Text(
                formattedDate(),
                style: const TextStyle(
                    fontFamily: "EuclidCircular",
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Color(0xffffffff)),
              ),
              const SizedBox(
                width: 20,
              ),
              IconButton(
                onPressed: () {},
                tooltip: "Sort by category",
                icon: const Icon(
                  Icons.filter_list,
                  color: Color(0xffE2DDFF),
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Align(
            alignment: FractionalOffset.bottomRight,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 15, 15),
              child: OpenContainer(
                useRootNavigator: true,
                closedShape: const CircleBorder(),
                closedColor: const Color(0xffBA99FF).withOpacity(0.9),
                transitionDuration: const Duration(milliseconds: 500),
                closedBuilder: (context, action) {
                  return FloatingActionButton(
                    tooltip: "Add New Task",
                    onPressed: () {
                      action.call();
                    },
                    backgroundColor: const Color(0xffBA99FF).withOpacity(0.9),
                    child: const Icon(
                      Icons.add,
                      size: 30,
                      color: Color.fromARGB(255, 47, 15, 83),
                    ),
                  );
                },
                openBuilder: (context, action) {
                  return InputModal(action: action);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
