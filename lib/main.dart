import 'dart:ffi';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:conquer_flutter_app/pages/Landing.dart';
import 'package:conquer_flutter_app/pages/Home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.deepPurple, fontFamily: "EuclidCircular"),
      home: HomePage(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      var isShowed = prefs.getBool("landingShown");
      // debugPrint("at splash screen landingShown is " + isShowed.toString());
      if (isShowed != null && isShowed) {
        //navigate to main page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(),
          ),
        );
      } else {
        //navigate to intro page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LandingPage(),
          ),
        );
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: CircularProgressIndicator(),
          ),
          backgroundColor: Colors.transparent,
        ));
  }
}
