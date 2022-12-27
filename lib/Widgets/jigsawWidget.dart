import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as ui;
import 'dart:math' as math;

class JigsawWidget extends StatefulWidget {
  Widget child;
  JigsawWidget({super.key, required this.child});

  @override
  State<JigsawWidget> createState() => _JigsawWidgetState();
}

class _JigsawWidgetState extends State<JigsawWidget> {
  GlobalKey _globalKey = GlobalKey();
  late ui.Image fullImage;
  late Size size;

  List<List<BlockClass>> images = <List<BlockClass>>[];

  _getImageFromWidget() async {
    RenderRepaintBoundary? boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    size = boundary.size;
    var img = await boundary.toImage();
    var byteData = await img.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData!.buffer.asUint8List();

    return ui.decodeImage(pngBytes);
  }

  generalJigsawCropImage() async {
    // class for block image
    images = <List<BlockClass>>[];

    // image from out boundary
    if (fullImage == null) fullImage = await _getImageFromWidget();

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

        // make random jigsaw pointer in or out
        JigsawPos jigsawPos = JigsawPos();
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      // set height for jigsaw base
      height: size.width,
      child: Container(
        child: Stack(
          children: [
            RepaintBoundary(
              key: _globalKey,
              child: Container(
                height: size.width,
                width: size.width,
                child: widget.child,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BlockClass {}

class JigsawPos {}
