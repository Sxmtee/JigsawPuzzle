import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as ui;
import 'package:jigsawpuzzle/Models/blockClass.dart';
import 'package:jigsawpuzzle/Models/imageBox.dart';
import 'package:jigsawpuzzle/Models/jigsawPos.dart';
import 'dart:math' as math;
import 'package:jigsawpuzzle/Utils/appColors.dart';
import 'package:jigsawpuzzle/Widgets/jigsawBlockWidget.dart';

class JigsawPuzzle extends StatefulWidget {
  const JigsawPuzzle({super.key});

  @override
  State<JigsawPuzzle> createState() => _JigsawPuzzleState();
}

class _JigsawPuzzleState extends State<JigsawPuzzle> {
  //testbutton to check crop work
  GlobalKey<_JigsawWidgetState> jigkey = GlobalKey<_JigsawWidgetState>();
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
                  key: jigkey,
                  // Container for jigsaw image
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image(
                      fit: BoxFit.contain,
                      image: AssetImage("images/duck.png"),
                    ),
                  ),
                ),
              ),
              Container(
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: (() async {
                          await jigkey.currentState!.generalJigsawCropImage();
                        }),
                        child: const Text("Generate")),
                    ElevatedButton(
                        onPressed: (() {
                          jigkey.currentState!.resetJigsaw();
                        }),
                        child: const Text("Reset")),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class JigsawWidget extends StatefulWidget {
  Widget child;
  JigsawWidget({super.key, required this.child});

  @override
  State<JigsawWidget> createState() => _JigsawWidgetState();
}

class _JigsawWidgetState extends State<JigsawWidget> {
  final GlobalKey _globalKey = GlobalKey();
  late ui.Image fullImage;
  late Size size;

  List<List<BlockClass>> images = <List<BlockClass>>[];
  ValueNotifier<List<BlockClass>> blocksNotifier =
      ValueNotifier<List<BlockClass>>(<BlockClass>[]);

  //to save current touchdown offset & current index puzzle
  final Offset _pos = Offset.zero;
  final int _index = 0;

  _getImageFromWidget() async {
    RenderRepaintBoundary? boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    size = boundary.size;
    var img = await boundary.toImage();
    var byteData = await img.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData!.buffer.asUint8List();

    return ui.decodeImage(pngBytes);
  }

  Future<void> generalJigsawCropImage() async {
    // class for block image
    images = <List<BlockClass>>[];

    // image from out boundary

    fullImage = await _getImageFromWidget();

    // split image using crop
    int xSplitCount = 2;
    int ySplitCount = 2;

    double widthPerBlock = fullImage.width / xSplitCount;
    double heightPerBlock = fullImage.height / ySplitCount;

    for (var y = 0; y < ySplitCount; y++) {
      //temporary images
      List<BlockClass> tempImages = <BlockClass>[];
      images.add(tempImages);
      for (var x = 0; x < xSplitCount; x++) {
        int randomPosRow = math.Random().nextInt(2) % 2 == 0 ? 1 : -1;
        int randomPosCol = math.Random().nextInt(2) % 2 == 0 ? 1 : -1;

        Offset offsetCenter = Offset(widthPerBlock / 2, heightPerBlock / 2);

        //make random jigsaw pointer in or out
        JigsawPos jigsawPosSide = JigsawPos(
          bottom: y == ySplitCount - 1 ? 0 : randomPosCol,
          left: x == 0
              ? 0
              : -images[y][x - 1].jigsawBlockWidget.imageBox.posSide.right,
          right: x == xSplitCount - 1 ? 0 : randomPosRow,
          top: y == 0
              ? 0
              : -images[y - 1][x].jigsawBlockWidget.imageBox.posSide.bottom,
        );

        double xAxis = widthPerBlock * x;
        double yAxis = widthPerBlock * y;

        //pointing size
        double minSize = math.min(widthPerBlock, heightPerBlock) / 15 * 4;

        offsetCenter = Offset(
          (widthPerBlock / 2) + (jigsawPosSide.left == 1 ? minSize : 0),
          (heightPerBlock / 2) + (jigsawPosSide.top == 1 ? minSize : 0),
        );

        //change axis for posSideEffect
        xAxis -= jigsawPosSide.left == 1 ? minSize : 0;
        yAxis -= jigsawPosSide.top == 1 ? minSize : 0;

        //get width and height after change Axis Side Effect
        double widthPerBlockTemp = widthPerBlock +
            (jigsawPosSide.left == 1 ? minSize : 0) +
            (jigsawPosSide.right == 1 ? minSize : 0);
        double heightPerBlockTemp = heightPerBlock +
            (jigsawPosSide.top == 1 ? minSize : 0) +
            (jigsawPosSide.bottom == 1 ? minSize : 0);

        //crop image for each block
        ui.Image temp = ui.copyCrop(fullImage, xAxis.round(), yAxis.round(),
            widthPerBlockTemp.round(), heightPerBlockTemp.round());

        // offset for each block show on center stage later
        Offset offset = Offset(size.width / 2 - widthPerBlockTemp / 2,
            size.height / 2 - heightPerBlockTemp / 2);

        ImageBox imageBox = ImageBox(
            image: Image.memory(
              ui.encodePng(temp) as Uint8List,
              fit: BoxFit.contain,
            ),
            posSide: jigsawPosSide,
            offsetCenter: offsetCenter,
            size: Size(widthPerBlockTemp, heightPerBlockTemp),
            radiusPoint: minSize,
            isDone: false);

        images[y].add(BlockClass(
            offset: offset,
            offsetDefault: Offset(xAxis, yAxis),
            jigsawBlockWidget: JigsawBlockWidget(imageBox: imageBox)));
      }
    }
    blocksNotifier.value = images.expand((image) => image).toList();
    blocksNotifier.notifyListeners();
    setState(() {});
  }

  resetJigsaw() {
    images.clear();
    blocksNotifier = ValueNotifier<List<BlockClass>>(<BlockClass>[]);
    blocksNotifier.notifyListeners();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size sizeBox = MediaQuery.of(context).size; //change??
    return ValueListenableBuilder(
        valueListenable: blocksNotifier,
        builder: (context, List<BlockClass> blocks, child) {
          // List<BlockClass> b

          return Container(
            // set height for jigsaw base
            height: sizeBox.width,
            child: Container(
              child: Stack(
                children: [
                  if (blocks.isEmpty) ...[
                    RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                        color: Colors.red,
                        height: double.maxFinite,
                        width: double.maxFinite,
                        child: widget.child,
                      ),
                    )
                  ],
                  Offstage(
                    offstage: !(blocks.isNotEmpty),
                    child: Container(
                      color: Colors.blue,
                      height: sizeBox.height,
                      width: sizeBox.width,
                      child: Stack(
                        children: [
                          if (blocks.isNotEmpty)
                            ...blocks.asMap().entries.map(((map) {
                              return Positioned(
                                left: map.value.offset.dx,
                                top: map.value.offset.dy,
                                child: Container(
                                  child: map.value.jigsawBlockWidget,
                                ),
                              );
                            }))
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
