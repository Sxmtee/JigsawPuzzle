import 'dart:typed_data';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
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
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                // base for the puzzle widget
                Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border.all(width: 2)),
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
                        image: AssetImage("images/nature.png"),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: (() async {
                          await jigkey.currentState!.generalJigsawCropImage();
                        }),
                        child: const Text("Generate")),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: (() {
                          jigkey.currentState!.resetJigsaw();
                        }),
                        child: const Text("Clear")),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class JigsawWidget extends StatefulWidget {
  Widget child;
  Function() callbackFinish;
  Function() callbackSuccess;
  JigsawWidget(
      {super.key,
      required this.child,
      required this.callbackFinish,
      required this.callbackSuccess});

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
  late CarouselController _carouselController;

  //to save current touchdown offset & current index puzzle
  Offset _pos = Offset.zero;
  late int _index;

  // Future<Uint8List> _getImageFromWidget() async {
  //   final RenderRepaintBoundary boundary =
  //       _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  //   final image = await boundary.toImage(pixelRatio: 1);
  //   final byteData = await image.toByteData(format: ImageByteFormat.png);
  //   final pngBytes = byteData!.buffer.asUint8List();
  //   return pngBytes;
  // }

  _getImageFromWidget() async {
    try {
      RenderRepaintBoundary? boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      size = boundary.size;
      var img = await boundary.toImage();
      var byteData = await img.toByteData(format: ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();

      return ui.decodeImage(pngBytes);
    } catch (e) {
      print(Text("Error: ${e.toString()}"));
    }
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
        double yAxis = heightPerBlock * y;

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
              fit: BoxFit.fill,
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
    blocksNotifier.value.shuffle();
    blocksNotifier.notifyListeners();
    _index = 0;
    setState(() {});
  }

  resetJigsaw() {
    images.clear();
    blocksNotifier = ValueNotifier<List<BlockClass>>(<BlockClass>[]);
    // _carouselController = CarouselController();
    blocksNotifier.notifyListeners();
    setState(() {});
  }

  @override
  void initState() {
    _index = 0;
    _carouselController = CarouselController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size sizeBox = MediaQuery.of(context).size;
    return ValueListenableBuilder(
        valueListenable: blocksNotifier,
        builder: (context, List<BlockClass> blocks, child) {
          List<BlockClass> blockNotDone = blocks
              .where((block) => !block.jigsawBlockWidget.imageBox.isDone)
              .toList();
          List<BlockClass> blockDone = blocks
              .where((block) => block.jigsawBlockWidget.imageBox.isDone)
              .toList();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: sizeBox.width,
                child: Listener(
                  onPointerUp: (event) {
                    if (blockNotDone.isEmpty) {
                      resetJigsaw();
                      //set callback for completing all piece
                      widget.callbackFinish.call();
                    }
                    if (_index == null) {
                      //carousel for change index
                      _carouselController.nextPage(
                          duration: const Duration(microseconds: 600));
                      setState(() {
                        // _index = 0;
                      });
                    }
                  },
                  onPointerMove: (event) {
                    if (_index == null) return;

                    Offset offset = event.localPosition - _pos;

                    blockNotDone[_index].offset = offset;

                    if ((blockNotDone[_index].offset -
                                blockNotDone[_index].offsetDefault)
                            .distance <
                        5) {
                      //drag box close to default position will trigger condition
                      blockNotDone[_index].jigsawBlockWidget.imageBox.isDone =
                          true;
                      blockNotDone[_index].offset =
                          blockNotDone[_index].offsetDefault;

                      _index = 0;

                      blocksNotifier.notifyListeners();

                      //set callback success
                      widget.callbackSuccess.call();
                    }

                    setState(() {});
                  },
                  child: Stack(
                    children: [
                      if (blocks.isEmpty) ...[
                        RepaintBoundary(
                          key: _globalKey,
                          child: Container(
                            height: double.maxFinite,
                            width: double.maxFinite,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                            ),
                            child: widget.child,
                          ),
                        )
                      ],
                      Offstage(
                        offstage: !(blocks.isNotEmpty),
                        child: Container(
                          color: Colors.grey[800],
                          height: sizeBox.height,
                          width: sizeBox.width,
                          child: CustomPaint(
                            //drawing linebase for jigsaw
                            painter: JigsawPainterBackground(blocks),
                            child: Stack(
                              children: [
                                if (blockDone.isNotEmpty)
                                  ...blockDone.map(((map) {
                                    return Positioned(
                                      left: map.offset.dx,
                                      top: map.offset.dy,
                                      child: Container(
                                        child: map.jigsawBlockWidget,
                                      ),
                                    );
                                  })),
                                if (blockNotDone.isNotEmpty)
                                  ...blockNotDone.asMap().entries.map(((map) {
                                    return Positioned(
                                      left: map.value.offset.dx,
                                      top: map.value.offset.dy,
                                      child: Offstage(
                                        offstage: !(_index == map.key),
                                        child: GestureDetector(
                                          // for event touchdown
                                          onTapDown: (details) {
                                            if (map.value.jigsawBlockWidget
                                                .imageBox.isDone) return;

                                            setState(() {
                                              _pos = details.localPosition;
                                              _index = map.key;
                                            });
                                          },
                                          child: Container(
                                            child: map.value.jigsawBlockWidget,
                                          ),
                                        ),
                                      ),
                                    );
                                  }))
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.black,
                height: 100,
                child: CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    initialPage: _index,
                    height: 80,
                    aspectRatio: 1,
                    viewportFraction: 0.15,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    disableCenter: false,
                    onPageChanged: (index, reason) {
                      _index = index; //outside
                      setState(() {});
                    },
                  ),
                  items: blockNotDone.map((block) {
                    Size sizeBlock = block.jigsawBlockWidget.imageBox.size;
                    return FittedBox(
                      child: Container(
                        width: sizeBlock.width,
                        height: sizeBlock.height,
                        child: block.jigsawBlockWidget,
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          );
        });
  }
}

class JigsawPainterBackground extends CustomPainter {
  List<BlockClass> blocks;
  JigsawPainterBackground(this.blocks);
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black12
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    Path path = Path();

    //loop blocks so we can draw line at base
    for (var element in blocks) {
      Path pathTemp = getPiecePath(
          element.jigsawBlockWidget.imageBox.size,
          element.jigsawBlockWidget.imageBox.radiusPoint,
          element.jigsawBlockWidget.imageBox.offsetCenter,
          element.jigsawBlockWidget.imageBox.posSide);

      path.addPath(pathTemp, element.offsetDefault);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
