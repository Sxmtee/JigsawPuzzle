import 'package:flutter/material.dart';
import 'package:jigsawpuzzle/Models/blockClass.dart';
import 'package:jigsawpuzzle/Widgets/jigsawBlockWidget.dart';

class JigsawPainterBackground extends CustomPainter {
  List<BlockClass> blocks;
  JigsawPainterBackground(this.blocks);
  @override
  void paint(Canvas canvas, Size size) {
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
