import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Auth extends StatefulWidget {
  String type;
  Auth({super.key, required this.type});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: OutlinedButton(
              onPressed: () {},
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                side: MaterialStateProperty.all(BorderSide(
                    width: 1, color: Color.fromARGB(85, 255, 255, 255))),
                overlayColor: MaterialStateProperty.all(
                    Color.fromARGB(71, 217, 217, 217)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
              ),
              child: Ink(
                width: 320,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(15, 217, 217, 217),
                      Color.fromARGB(71, 217, 217, 217),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 25),
                      Image.asset("assets/images/Google.png"),
                      SizedBox(width: 15),
                      Text("Continue with Google",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          )),
                      SizedBox(width: 200, height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          SizedBox(
            width: 300,
            child: ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                // foregroundColor: MaterialStateProperty.all(Colors.white),
                // overlayColor: MaterialStateProperty.all(
                //     Color.fromARGB(71, 217, 217, 217)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
              ),
              child: Ink(
                width: 320,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xffF476FF),
                      Color(0xffBA99FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 120),
                      Text("Log In",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          )),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
