import 'package:conquer_flutter_app/pages/InputModal.dart';
import 'package:conquer_flutter_app/states/nudgerState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

class NudgerConfirmationModal extends StatefulWidget {
  final double curve;
  Function turnOn;
  NudgerConfirmationModal({
    super.key,
    required this.curve,
    required this.turnOn,
  });

  @override
  State<NudgerConfirmationModal> createState() =>
      _NudgerConfirmationModalState();
}

class _NudgerConfirmationModalState extends State<NudgerConfirmationModal> {
  NudgerStates nudgerStates = GetIt.I.get();

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: widget.curve,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SimpleDialog(
                  contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  children: [
                    Text(
                      "You need to provide accessibility permission. We need it to check if you are using a blacklisted app.",
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "No, I can trust big tech but not you",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color(0xfff50057),
                        ),
                      ),
                      style: ButtonStyle(),
                    ),
                    TextButton(
                      onPressed: () async {
                        bool didEnable =
                            await nudgerStates.requestAccessibilityPermission();
                        debugPrint("after returning from settings: $didEnable");
                        if (didEnable) {
                          Navigator.pop(context);
                          await widget.turnOn();
                        } else {
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                            msg:
                                "Nudger couldn't be turned on cause you didn't provide Doneify accessibility permission",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                          );
                        }
                      },
                      child: Text(
                        "Fine, take me to settings",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ]),
            )
          ],
        ),
      ),
    );
  }
}
