import 'package:conquer_flutter_app/pages/Daily.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Todos extends StatefulWidget {
  final DateTime day;
  const Todos({Key? key, required this.day}) : super(key: key);

  @override
  State<Todos> createState() => _TodosState();
}

class _TodosState extends State<Todos> {
  String formattedDate() {
    final DateFormat formatter = DateFormat('d MMM');
    final String formatted = formatter.format(widget.day);
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(5, 25, 5, 5),
          width: screenWidth * 0.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xff9A9A9A),
                  size: 30,
                ),
              ),
              Text(
                formattedDate(),
                style: const TextStyle(
                    fontFamily: "EuclidCircular",
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Color(0xffffffff)),
              ),
              IconButton(
                onPressed: () {},
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
              margin: const EdgeInsets.only(bottom: 10),
              child: MaterialButton(
                shape: const CircleBorder(),
                color: const Color(0xffBA99FF),
                padding: const EdgeInsets.all(8),
                onPressed: () {},
                child: const Icon(
                  Icons.add,
                  size: 28,
                  color: Color.fromARGB(255, 47, 15, 83),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
