import 'dart:ffi';
import 'package:conquer_flutter_app/states/initStates.dart';
import 'package:flutter/material.dart';
import 'package:conquer_flutter_app/pages/Home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final Future _init = GetItRegister().initializeGlobalStates();
  final Future _init = GetItRegister().initializeGlobalStates();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.deepPurple, fontFamily: "EuclidCircular"),
      home: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff404049),
              Color(0xff09090E),
            ],
          ),
        ),
        child: Scaffold(
          body: Center(
              child: FutureBuilder(
                  future: _init,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return const HomePage();
                    } else {
                      return const Material(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                  })),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
