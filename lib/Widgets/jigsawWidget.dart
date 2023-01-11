import 'dart:typed_data';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as ui;
import 'package:jigsawpuzzle/Models/blockClass.dart';
import 'package:jigsawpuzzle/Models/imageBox.dart';
import 'dart:math' as math;
import 'package:jigsawpuzzle/Models/jigsawPos.dart';
import 'package:jigsawpuzzle/Utils/jigsaw_painter.dart';
import 'package:jigsawpuzzle/Widgets/jigsawBlockWidget.dart';

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
  State<JigsawWidget> createState() => JigsawWidgetState();
}

class JigsawWidgetState extends State<JigsawWidget> {
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
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF701ebd),
                                      Color(0xFF873bcc),
                                      Color(0xFFfe4a97),
                                      Color(0xFFe17763),
                                      Color(0xFF68998c)
                                    ],
                                    stops: [
                                      0.1,
                                      0.4,
                                      0.6,
                                      0.8,
                                      1
                                    ],
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft)),
                            child: widget.child,
                          ),
                        )
                      ],
                      Offstage(
                        offstage: !(blocks.isNotEmpty),
                        child: Container(
                          color: Colors.transparent,
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
              SizedBox(
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
