import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jigsawpuzzle/Screens/jigsawPuzzle.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(const Duration(seconds: 6), (() {
      var route = MaterialPageRoute(builder: (context) => const JigsawPuzzle());
      Navigator.push(context, route);
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/splash.png"),
                fit: BoxFit.cover)),
      ),
    );
  }
}
