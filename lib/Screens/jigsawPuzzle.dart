import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jigsawpuzzle/Widgets/jigsawWidget.dart';

class JigsawPuzzle extends StatefulWidget {
  const JigsawPuzzle({super.key});

  @override
  State<JigsawPuzzle> createState() => _JigsawPuzzleState();
}

class _JigsawPuzzleState extends State<JigsawPuzzle> {
  //testbutton to check crop work
  GlobalKey<JigsawWidgetState> jigkey = GlobalKey<JigsawWidgetState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color(0xFF701ebd),
          Color(0xFF873bcc),
          Color(0xFFfe4a97),
          Color(0xFFe17763),
          Color(0xFF68998c)
        ], stops: [
          0.1,
          0.4,
          0.6,
          0.8,
          1
        ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
        child: SafeArea(
          child: Column(
            children: [
              // base for the puzzle widget
              Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  // border: Border.all(width: 2)
                ),
                child: JigsawWidget(
                  callbackFinish: () {
                    print("CallBackFinish");
                  },
                  callbackSuccess: () {
                    print("CallBackSuccess");
                  },
                  key: jigkey,
                  // Container for jigsaw image
                  child: const Padding(
                    padding: EdgeInsets.all(22.0),
                    child: Image(
                      fit: BoxFit.fill,
                      image: AssetImage("assets/images/nature.png"),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await jigkey.currentState!.generalJigsawCropImage();
                  },
                  icon: const Icon(
                    CupertinoIcons.arrow_right,
                    color: Color(0xFFFE0037),
                  ),
                  label: const Text("Start"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    jigkey.currentState!.resetJigsaw();
                  },
                  icon: const Icon(
                    CupertinoIcons.repeat,
                    color: Color(0xFFFE0037),
                  ),
                  label: const Text("Reset"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
