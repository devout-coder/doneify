import 'package:conquer_flutter_app/components/NudgerConfirmationDialog.dart';
import 'package:conquer_flutter_app/globalColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NudgerSettings extends StatefulWidget {
  const NudgerSettings({super.key});

  @override
  State<NudgerSettings> createState() => _NudgerSettingsState();
}

class _NudgerSettingsState extends State<NudgerSettings> {
  bool nudgerOn = false;
  void handleSwitch() {
    //   setState(() {
    //     nudgerOn = !nudgerOn;
    //   });
    showGeneralDialog(
      //! select filter dialog box
      context: context,
      barrierDismissible: true,
      barrierLabel: "Choose filters",
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (ctx, a1, a2, child) {
        var curve = Curves.easeInOut.transform(a1.value);
        return NudgerConfirmationModal(
          curve: curve,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              handleSwitch();
            },
            child: AppBar(
              title: Text(
                "Nudger",
                // style: TextStyle(color: Colors.black),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                Switch(
                  activeTrackColor: themePurple,
                  activeColor: themeMediumPurple,
                  value: nudgerOn,
                  onChanged: (bool value) {
                    handleSwitch();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
