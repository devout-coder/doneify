import 'package:conquer_flutter_app/components/AddOrEditLabelDialog.dart';
import 'package:conquer_flutter_app/components/SelectLabelDialog.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
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
  final Function() notifyParent;

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
    required this.notifyParent,
  }) : super(key: key);

  @override
  State<InputModal> createState() => _InputModalState();
}

class _InputModalState extends State<InputModal> {
  int selectedLabel = 0;

  List<Label> labels = [];

  final taskName = TextEditingController();
  final taskDesc = TextEditingController();

  List<Label> extractLabels(String labelsString) {
    List<dynamic> decodedMap = jsonDecode(labelsString);
    List<Label> storedLabels = [];
    decodedMap.forEach((element) {
      String name = element["name"];
      String color = element["color"];
      Label thisLabel = Label(name, color);
      storedLabels.add(thisLabel);
    });
    return storedLabels;
  }

  Future<void> readLabels() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    String stringStoredLabels = prefs.getString('labels') ?? "";
    if (stringStoredLabels == "") {
      Label newLabel = Label("General", Colors.white.toString());
      List<Map<String, dynamic>> mapList = [
        {'name': newLabel.name, 'color': newLabel.color.toString()}
      ];

      String labelsJSON = jsonEncode(mapList);
      prefs.setString('labels', labelsJSON);
      stringStoredLabels = labelsJSON;
    }
    // debugPrint(stringStoredLabels);
    setState(() {
      labels = extractLabels(stringStoredLabels);
    });
  }

  int getRandInt() {
    var random = Random.secure();
    var values = List<String>.generate(18, (i) => random.nextInt(9).toString());
    var stringList = values.join("");
    return int.parse(stringList);
  }

  int findLabelIndex(String labelName) {
    int index = 0;
    debugPrint("now index " + index.toString());
    // debugPrint
    for (int i = 0; i < labels.length; i++) {
      debugPrint(labels[i].name);
      debugPrint(labelName);
      if (labels[i].name == labelName) {
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
        labels[selectedLabel],
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
          labels[selectedLabel],
          DateTime.now().millisecondsSinceEpoch,
          widget.time,
          widget.timeType,
          widget.index!,
          getRandInt());

      widget.addTodo(newTodo);
    }
    widget.action.call();
  }

  void startFunc() async {
    taskName.text = widget.todo != null ? widget.todo!.taskName : '';
    taskDesc.text = widget.todo != null ? widget.todo!.taskDesc : '';
    await readLabels();
    selectedLabel =
        widget.todo != null ? findLabelIndex(widget.todo!.label.name) : 0;
  }

  @override
  void initState() {
    startFunc();
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
                            labels: labels,
                            readLabels: readLabels,
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
