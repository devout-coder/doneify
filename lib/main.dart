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
  static const MaterialColor purple = MaterialColor(
    0xffe55f48, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: const Color(0xffba99ff), //10%
      100: const Color(0xffa78ae6), //20%
      200: const Color(0xff957acc), //30%
      300: const Color(0xff826bb3), //40%
      400: const Color(0xff705c99), //50%
      500: const Color(0xff5d4d80), //60%
      600: const Color(0xff4a3d66), //70%kj
      700: const Color(0xff382e4c), //80%
      800: const Color(0xff382e4c), //90%
      900: const Color(0xff382e4c), //100%
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: "EuclidCircular",
      ),
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
