import 'package:conquer_flutter_app/components/AddOrEditLabelDialog.dart';
import 'package:conquer_flutter_app/components/SelectLabelDialog.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/states/labelsDB.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputModal extends StatefulWidget {
  final action;
  Todo? todo;
  final addTodo;
  final editTodo;
  final onDelete;
  String time;
  String timeType;
  int? index;

  InputModal({
    Key? key,
    this.action,
    this.todo,
    this.addTodo,
    this.editTodo,
    this.onDelete,
    required this.time,
    required this.timeType,
    this.index,
  }) : super(key: key);

  @override
  State<InputModal> createState() => _InputModalState();
}

class _InputModalState extends State<InputModal> {
  int selectedLabel = 0;

  LabelDB labelsDB = GetIt.I.get();

  final taskName = TextEditingController();
  final taskDesc = TextEditingController();

  int getRandInt() {
    var random = Random.secure();
    var values = List<String>.generate(18, (i) => random.nextInt(9).toString());
    var stringList = values.join("");
    return int.parse(stringList);
  }

  int findLabelIndex(String labelName) {
    int index = 0;
    // debugPrint("now index ${index.toString()} ");
    // debugPrint
    for (int i = 0; i < labelsDB.labels.length; i++) {
      if (labelsDB.labels[i].name == labelName) {
        index = i;
      }
    }
    return index;
  }

  void _saveTodo() {
    int id;
    Todo newTodo;
    if (widget.todo != null) {
      id = widget.todo!.id;
      newTodo = Todo(
        taskName.text,
        taskDesc.text,
        false,
        labelsDB.labels[selectedLabel].name,
        DateTime.now().millisecondsSinceEpoch,
        widget.time,
        widget.timeType,
        widget.todo!.index,
        id,
      );
      widget.editTodo(newTodo);
    } else {
      newTodo = Todo(
          taskName.text,
          taskDesc.text,
          false,
          labelsDB.labels[selectedLabel].name,
          DateTime.now().millisecondsSinceEpoch,
          widget.time,
          widget.timeType,
          widget.index!,
          getRandInt());

      widget.addTodo(newTodo);
    }
    widget.action.call();
  }

  void setValues() async {
    taskName.text = widget.todo != null ? widget.todo!.taskName : '';
    taskDesc.text = widget.todo != null ? widget.todo!.taskDesc : '';
    selectedLabel =
        widget.todo != null ? findLabelIndex(widget.todo!.labelName) : 0;
    // debugPrint(widget.todo!.index.toString());
  }

  @override
  void initState() {
    setValues();
    super.initState();
  }

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
            controller: taskName,
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
                    controller: taskDesc,
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
                      Icons.label,
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
                          return SelectLabelDialog(
                            curve: curve,
                            selectedLabel: selectedLabel,
                            updateSelectedLabel: (newLabel) {
                              setState(() {
                                selectedLabel = newLabel;
                              });
                            },
                          );
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
                  Container(
                      child: widget.todo != null
                          ? Row(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  tooltip: "Postpone this task",
                                  icon: const Icon(
                                    Icons.subdirectory_arrow_right,
                                    size: 30,
                                  ),
                                ),
                                IconButton(
                                  onPressed: widget.onDelete,
                                  tooltip: "Delete this task",
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 30,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox()),
                  IconButton(
                    onPressed: () {
                      _saveTodo();
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
