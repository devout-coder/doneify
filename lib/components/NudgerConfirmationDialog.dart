import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';

class NudgerConfirmationModal extends StatefulWidget {
  final double curve;
  const NudgerConfirmationModal({
    super.key,
    required this.curve,
  });

  @override
  State<NudgerConfirmationModal> createState() =>
      _NudgerConfirmationModalState();
}

class _NudgerConfirmationModalState extends State<NudgerConfirmationModal> {
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
                      onPressed: () {},
                      child: Text(
                        "I can trust big tech but not you",
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
                        final bool status = await FlutterAccessibilityService
                            .isAccessibilityPermissionEnabled();

                        debugPrint("status fo accessibility enablity: $status");

                        if (!status) {
                          bool didEnable = await FlutterAccessibilityService
                              .requestAccessibilityPermission();
                          debugPrint(
                              "after returning from settings: $didEnable");
                        }

                        FlutterAccessibilityService.accessStream
                            .listen((event) {
                          debugPrint("inside listen");
                          //use only isActive and isFocussed event
                        });

                        /// request accessibility permission
                        /// it will open the accessibility settings page and return `true` once the permission granted.

                        /// stream the incoming Accessibility events
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
