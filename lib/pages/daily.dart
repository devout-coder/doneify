import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    Key? key,
    required this.index,
    required this.onPress,
  }) : super(key: key);

  final index;
  final void Function() onPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Text('Card $index'),
          TextButton(
            child: const Text('Press'),
            onPressed: onPress,
          ),
        ],
      )
    );
  }
}