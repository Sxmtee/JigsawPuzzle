import 'package:flutter/material.dart';
import 'package:jigsawpuzzle/Utils/appColors.dart';
import 'package:jigsawpuzzle/Widgets/jigsawWidget.dart';

class JigsawPuzzle extends StatefulWidget {
  const JigsawPuzzle({super.key});

  @override
  State<JigsawPuzzle> createState() => _JigsawPuzzleState();
}

class _JigsawPuzzleState extends State<JigsawPuzzle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.primaryColor,
        child: SafeArea(
          child: Column(
            children: [
              // base for the puzzle widget
              Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(border: Border.all(width: 2)),
                child: JigsawWidget(
                  // Container for jigsaw image
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image(
                      fit: BoxFit.contain,
                      image: AssetImage("images/livi.jpg"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
