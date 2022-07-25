import 'package:conquer_flutter_app/components/NewColorDialog.dart';
import 'package:flutter/material.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EditLabelDialog extends StatefulWidget {
  final double curve;
  EditLabelDialog({Key? key, required this.curve}) : super(key: key);

  @override
  State<EditLabelDialog> createState() => _EditLabelDialogState();
}

class _EditLabelDialogState extends State<EditLabelDialog> {
  Color currentColor = Colors.amber;
  List<Color> currentColors = [
    Colors.yellow,
    Colors.green,
    Colors.red,
    Colors.blue,
    Colors.purple,
  ];

  void changeColor(Color color) => setState(() => currentColor = color);

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
                    titlePadding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                    title: TextFormField(
                      //! taskName text field
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
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
                    children: <Widget>[
                      Container(
                        width: screenWidth * 0.8,
                        height: screenHeight * 0.3,
                        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                        child: GridView.builder(
                          itemCount: currentColors.length + 1,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                changeColor(currentColors[index]);
                              },
                              child: index != currentColors.length
                                  ? CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.black54,
                                      child: CircleAvatar(
                                        backgroundColor: currentColors[index],
                                        radius: 21,
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.black54,
                                      child: IconButton(
                                        onPressed: () {
                                          showGeneralDialog(
                                            //! add label dialog box
                                            context: context,
                                            pageBuilder: (BuildContext context,
                                                Animation<double> animation,
                                                Animation<double>
                                                    secondaryAnimation) {
                                              return Container();
                                            },
                                            transitionBuilder:
                                                (ctx, a1, a2, child) {
                                              var curve = Curves.easeInOut
                                                  .transform(a1.value);
                                              return NewColorDialog(
                                                  curve: curve);
                                            },
                                            transitionDuration: const Duration(
                                                milliseconds: 300),
                                          );
                                        },
                                        tooltip: "Add new color",
                                        icon: const Icon(
                                          Icons.add,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          debugPrint("back pressed now in edit label dialog");
          return true;
        });
  }
}
