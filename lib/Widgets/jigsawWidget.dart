// import 'dart:typed_data';
// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:image/image.dart' as ui;
// import 'package:jigsawpuzzle/Models/blockClass.dart';
// import 'package:jigsawpuzzle/Models/imageBox.dart';
// import 'dart:math' as math;
// import 'package:jigsawpuzzle/Models/jigsawPos.dart';
// import 'package:jigsawpuzzle/Widgets/jigsawBlockWidget.dart';

// class JigsawWidget extends StatefulWidget {
//   Widget child;
//   JigsawWidget({super.key, required this.child});

//   @override
//   State<JigsawWidget> createState() => _JigsawWidgetState();
// }

// class _JigsawWidgetState extends State<JigsawWidget> {
//   final GlobalKey _globalKey = GlobalKey();
//   late ui.Image fullImage;
//   late Size size;

//   List<List<BlockClass>> images = <List<BlockClass>>[];

//   _getImageFromWidget() async {
//     RenderRepaintBoundary? boundary =
//         _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

//     size = boundary.size;
//     var img = await boundary.toImage();
//     var byteData = await img.toByteData(format: ImageByteFormat.png);
//     var pngBytes = byteData!.buffer.asUint8List();

//     return ui.decodeImage(pngBytes);
//   }

//   Future<void> generalJigsawCropImage() async {
//     // class for block image
//     images = <List<BlockClass>>[];

//     // image from out boundary
//     if (fullImage == null) fullImage = await _getImageFromWidget();

//     // split image using crop
//     int xSplitCount = 2;
//     int ySplitCount = 2;

//     double widthPerBlock = fullImage.width / xSplitCount;
//     double heightPerBlock = fullImage.height / ySplitCount;

//     for (var y = 0; y < ySplitCount; y++) {
//       //temporary images
//       List<BlockClass> tempImages = <BlockClass>[];
//       images.add(tempImages);
//       for (var x = 0; x < xSplitCount; x++) {
//         int randomPosRow = math.Random().nextInt(2) % 2 == 0 ? 1 : -1;
//         int randomPosCol = math.Random().nextInt(2) % 2 == 0 ? 1 : -1;

//         Offset offsetCenter = Offset(widthPerBlock / 2, heightPerBlock / 2);

//         //make random jigsaw pointer in or out
//         JigsawPos jigsawPosSide = JigsawPos(
//           bottom: y == ySplitCount - 1 ? 0 : randomPosCol,
//           left: x == 0
//               ? 0
//               : -images[y][x - 1].jigsawBlockWidget.imageBox.posSide.right,
//           right: x == xSplitCount - 1 ? 0 : randomPosRow,
//           top: y == 0
//               ? 0
//               : -images[y][x - 1].jigsawBlockWidget.imageBox.posSide.bottom,
//         );

//         double xAxis = widthPerBlock * x;
//         double yAxis = widthPerBlock * y;

//         //pointing size
//         double minSize = math.min(widthPerBlock, heightPerBlock) / 15 * 4;

//         offsetCenter = Offset(
//           (widthPerBlock / 2) + (jigsawPosSide.left == 1 ? minSize : 0),
//           (heightPerBlock / 2) + (jigsawPosSide.top == 1 ? minSize : 0),
//         );

//         //change axis for posSideEffect
//         xAxis -= jigsawPosSide.left == 1 ? minSize : 0;
//         yAxis -= jigsawPosSide.top == 1 ? minSize : 0;

//         //get width and height after change Axis Side Effect
//         double widthPerBlockTemp = widthPerBlock +
//             (jigsawPosSide.left == 1 ? minSize : 0) +
//             (jigsawPosSide.right == 1 ? minSize : 0);
//         double heightPerBlockTemp = heightPerBlock +
//             (jigsawPosSide.top == 1 ? minSize : 0) +
//             (jigsawPosSide.bottom == 1 ? minSize : 0);

//         //crop image for each block
//         ui.Image temp = ui.copyCrop(fullImage, xAxis.round(), yAxis.round(),
//             widthPerBlockTemp.round(), heightPerBlockTemp.round());

//         // offset for each block show on center stage later
//         Offset offset = Offset(size.width / 2 - widthPerBlockTemp / 2,
//             size.height / 2 - heightPerBlockTemp / 2);

//         ImageBox imageBox = ImageBox(
//             image: Image.memory(
//               ui.encodePng(temp) as Uint8List,
//               fit: BoxFit.contain,
//             ),
//             posSide: jigsawPosSide,
//             offsetCenter: offsetCenter,
//             size: Size(widthPerBlockTemp, heightPerBlockTemp),
//             radiusPoint: minSize,
//             isDone: false);

//         images[y].add(BlockClass(
//             offset: offset,
//             offsetDefault: Offset(xAxis, yAxis),
//             jigsawBlockWidget: JigsawBlockWidget(imageBox: imageBox)));
//       }
//     }
//     setState(() {});
//   }

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Container(
//       // set height for jigsaw base
//       height: size.width,
//       child: Container(
//         child: Stack(
//           children: [
//             RepaintBoundary(
//               key: _globalKey,
//               child: Container(
//                 color: Colors.red,
//                 height: size.width,
//                 width: size.width,
//                 child: widget.child,
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
