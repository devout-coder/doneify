import 'package:conquer_flutter_app/globalClasses.dart';
import 'package:flutter/material.dart';

class InputModal extends StatelessWidget {
  final action;
  const InputModal({Key? key, this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Todo newTodo = Todo("", "");
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: const Color(0xffBA99FF),
      padding: const EdgeInsets.fromLTRB(20, 40, 5, 20),
      child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          TextFormField(
            style: const TextStyle(
              color: Colors.black,
              fontSize: 35,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              hintText: "Task Name",
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).viewInsets.bottom != 0
                    ? screenHeight * 0.7 - 200
                    : screenHeight * 0.7),
            child: SingleChildScrollView(
              child: TextFormField(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: null,
                // minLines: 15,
                decoration: const InputDecoration(
                  hintText: "Task Description",
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      action.call();
                    },
                    icon: const Icon(
                      Icons.save,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
