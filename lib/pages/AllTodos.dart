import 'package:flutter/material.dart';

class AllTodos extends StatefulWidget {
  const AllTodos({Key? key}) : super(key: key);

  @override
  State<AllTodos> createState() => _AllTodosState();
}

class _AllTodosState extends State<AllTodos> {
  bool mySwitch = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Todos"),
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: Column(
        children: [
          Image.asset("images/conquer_logo.png"),
          Container(
            height: 30,
            // color: Colors.deepPurple,
          ),
          const Divider(
            color: Colors.black,
            height: 1,
          ),
          Container(
            color: mySwitch ? Colors.red : Colors.green,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(5),
            width: double.infinity,
            child: const Center(
              child: Text(
                "some random todo",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
                primary: mySwitch ? Colors.red : Colors.green),
            onPressed: () {
              debugPrint("todo expanded");
            },
            child: const Text("Expand todo"),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Icon(Icons.fire_truck),
                Icon(Icons.perm_device_information_sharp)
              ],
            ),
          ),
          Switch(
            value: mySwitch,
            onChanged: (bool value) {
              setState(() {
                mySwitch = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
