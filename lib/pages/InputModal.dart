import 'package:conquer_flutter_app/components/SelectLabelDialog.dart';
import 'package:conquer_flutter_app/impClasses.dart';

import 'package:flutter/material.dart';

class InputModal extends StatefulWidget {
  final action;
  const InputModal({Key? key, this.action}) : super(key: key);

  @override
  State<InputModal> createState() => _InputModalState();
}

class _InputModalState extends State<InputModal> {
  @override
  Widget build(BuildContext context) {
    // Todo newTodo = Todo("", "");
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: const Color(0xffBA99FF),
      padding: const EdgeInsets.fromLTRB(20, 40, 5, 20),
      child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          TextFormField(
            //! taskName text field
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
          LayoutBuilder(
            //! task description text field
            builder: (context, constraints) => Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).viewInsets.bottom != 0
                      ? screenHeight * 0.7 - 250
                      : screenHeight * 0.65),
              child: Scrollbar(
                thumbVisibility: true,
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
            ),
          ),
          Expanded(
            //! bottom icon row
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.add_comment,
                      size: 30,
                    ),
                    tooltip: "Add label",
                    onPressed: () => {
                      showGeneralDialog(
                        //! add label dialog box
                        context: context,
                        pageBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation) {
                          return Container();
                        },
                        transitionBuilder: (ctx, a1, a2, child) {
                          var curve = Curves.easeInOut.transform(a1.value);
                          return SelectLabelDialog(curve: curve);
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      )
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      // action.call();
                    },
                    tooltip: "Add reminder",
                    icon: const Icon(
                      Icons.access_alarm,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // action.call();
                    },
                    tooltip: "Share task with friends",
                    icon: const Icon(
                      Icons.people,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    tooltip: "Postpone this task",
                    icon: const Icon(
                      Icons.subdirectory_arrow_right,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      widget.action.call();
                    },
                    tooltip: "Delete this task",
                    icon: const Icon(
                      Icons.delete,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      widget.action.call();
                    },
                    tooltip: "Save this task",
                    icon: const Icon(
                      Icons.save,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
