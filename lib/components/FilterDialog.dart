import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final double curve;
  FilterDialog({Key? key, required this.curve}) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Transform.scale(
          scale: widget.curve,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SimpleDialog(
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 0, 5),
                    titlePadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    title: const Text('Choose Labels'),
                    children: <Widget>[Text("choose filter")],
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
