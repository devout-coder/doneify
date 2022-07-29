import 'package:conquer_flutter_app/components/EditLabelDialog.dart';
import 'package:flutter/material.dart';

class Label {
  String name;
  Color color;

  Label(this.name, this.color);
}

class AddLabelDialog extends StatefulWidget {
  final double curve;
  AddLabelDialog({Key? key, required this.curve}) : super(key: key);

  @override
  State<AddLabelDialog> createState() => _AddLabelDialogState();
}

class _AddLabelDialogState extends State<AddLabelDialog> {
  List<Label> labels = [
    Label("General", Colors.blue),
  ];
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
        child: Transform.scale(
          scale: widget.curve,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SimpleDialog(
                    contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                    titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    title: const Text('Select Label'),
                    children: <Widget>[
                      Container(
                        height: screenHeight * 0.4,
                        width: screenWidth * 0.9,
                        child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: labels.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: labels[index].name,
                                        groupValue: labels[index].name,
                                        onChanged: (String? value) {
                                          setState(() {
                                            labels[index].name = value!;
                                          });
                                        },
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.black54,
                                        child: CircleAvatar(
                                          radius: 16,
                                          backgroundColor: labels[index].color,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        labels[index].name,
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    tooltip: "Edit label",
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.create_rounded,
                                    ),
                                  ),
                                ],
                              );
                            }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            tooltip: "Add new label",
                            onPressed: () {
                              showGeneralDialog(
                                //! edit label dialog box
                                context: context,
                                pageBuilder: (BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secondaryAnimation) {
                                  return Container();
                                },
                                transitionBuilder: (ctx, a1, a2, child) {
                                  var curve =
                                      Curves.easeInOut.transform(a1.value);
                                  return EditLabelDialog(curve: curve);
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 300),
                              );
                            },
                            icon: const Icon(
                              Icons.add_rounded,
                            ),
                          ),
                          IconButton(
                            tooltip: "Save current label",
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.check_rounded),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          debugPrint("back pressed now in add label dialog");
          return true;
        });
  }
}
