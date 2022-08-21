import 'dart:ffi';
import 'package:conquer_flutter_app/globalColors.dart';
import 'package:conquer_flutter_app/states/initStates.dart';
import 'package:conquer_flutter_app/states/labelsDB.dart';
import 'package:conquer_flutter_app/states/selectedFilters.dart';
import 'package:flutter/material.dart';
import 'package:conquer_flutter_app/pages/Home.dart';
import 'package:get_it/get_it.dart';

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

  MaterialColor purple = const MaterialColor(
    0xffe55f48, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: themePurple, //10%
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

  Future registerDB() async {
    await GetItRegister().initializeGlobalStates();
    LabelDB labelsDB = GetIt.I.get();
    SelectedFilters selectedFilters = GetIt.I.get();

    await selectedFilters.fetchFiltersFromStorage();
    await labelsDB.readLabelsFromStorage();
  }

  @override
  void initState() {
    // loadLabels();
    // debugPrint("Home widget is rendered");
    super.initState();
  }

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
                  future: registerDB(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // loadLabels();
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
