import 'package:flutter/material.dart';
import 'package:jigsawpuzzle/Models/imageBox.dart';
import 'package:jigsawpuzzle/Models/jigsawPos.dart';

class JigsawBlockWidget extends StatefulWidget {
  ImageBox imageBox;
  JigsawBlockWidget({super.key, required this.imageBox});

  @override
  State<JigsawBlockWidget> createState() => _JigsawBlockWidgetState();
}

class _JigsawBlockWidgetState extends State<JigsawBlockWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: PuzzlePieceClipper(imageBox: widget.imageBox),
      child: CustomPaint(
          foregroundPainter: JigsawBlokPainter(imageBox: widget.imageBox),
          child: widget.imageBox.image),
    );
  }
}

class JigsawBlokPainter extends CustomPainter {
  ImageBox imageBox;
  JigsawBlokPainter({required this.imageBox});
  @override
  void paint(Canvas canvas, Size size) {
    //function for custom painter to use same path later
    Paint paint = Paint()
      ..color = imageBox.isDone ? Colors.white.withOpacity(0.2) : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(
        getPiecePath(size, imageBox.radiusPoint, imageBox.offsetCenter,
            imageBox.posSide),
        paint);

    if (imageBox.isDone) {
      Paint paintDone = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill
        ..strokeWidth = 2;
      canvas.drawPath(
          getPiecePath(size, imageBox.radiusPoint, imageBox.offsetCenter,
              imageBox.posSide),
          paintDone);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class PuzzlePieceClipper extends CustomClipper<Path> {
  ImageBox imageBox;
  PuzzlePieceClipper({required this.imageBox});
  @override
  Path getClip(Size size) {
    //function for custom painter to use same path later
    return getPiecePath(
      size,
      imageBox.radiusPoint,
      imageBox.offsetCenter,
      imageBox.posSide,
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

getPiecePath(
    Size size, double radiusPoint, Offset offsetCenter, JigsawPos posSide) {
  Path path = Path();

  Offset topLeft = const Offset(0, 0);
  Offset topRight = Offset(size.width, 0);
  Offset bottomLeft = Offset(0, size.height);
  Offset bottomRight = Offset(size.width, size.height);

  //calculate top point on 4 point
  topLeft = Offset(posSide.left > 0 ? radiusPoint : 0,
          (posSide.top > 0) ? radiusPoint : 0) +
      topLeft;
  topRight = Offset(posSide.right > 0 ? -radiusPoint : 0,
          (posSide.top > 0) ? radiusPoint : 0) +
      topRight;
  bottomLeft = Offset(posSide.left > 0 ? radiusPoint : 0,
          (posSide.bottom > 0) ? -radiusPoint : 0) +
      bottomLeft;
  bottomRight = Offset(posSide.right > 0 ? -radiusPoint : 0,
          (posSide.bottom > 0) ? -radiusPoint : 0) +
      bottomRight;

  //calculate midpoint for min and max
  double topMiddle = posSide.top == 0
      ? topRight.dy
      : (posSide.top > 0
          ? topRight.dy - radiusPoint
          : topRight.dy + radiusPoint);
  double bottomMiddle = posSide.bottom == 0
      ? bottomRight.dy
      : (posSide.bottom > 0
          ? bottomRight.dy + radiusPoint
          : bottomRight.dy - radiusPoint);
  double leftMiddle = posSide.left == 0
      ? topLeft.dx
      : (posSide.left > 0
          ? topLeft.dx - radiusPoint
          : topLeft.dx + radiusPoint);
  double rightMiddle = posSide.right == 0
      ? topRight.dx
      : (posSide.right > 0
          ? topRight.dx + radiusPoint
          : topRight.dx - radiusPoint);

  path.moveTo(topLeft.dx, topLeft.dy);
  // top draw
  if (posSide.top != 0) {
    path.extendWithPath(
        calculatePoint(Axis.horizontal, topLeft.dy,
            Offset(offsetCenter.dx, topMiddle), radiusPoint),
        Offset.zero);
  }
  path.lineTo(topRight.dx, topRight.dy);
  //right draw
  if (posSide.right != 0) {
    path.extendWithPath(
        calculatePoint(Axis.vertical, topRight.dx,
            Offset(rightMiddle, offsetCenter.dy), radiusPoint),
        Offset.zero);
  }
  path.lineTo(bottomRight.dx, bottomRight.dy);
  //bottom draw
  if (posSide.bottom != 0) {
    path.extendWithPath(
        calculatePoint(Axis.horizontal, bottomRight.dy,
            Offset(offsetCenter.dx, bottomMiddle), -radiusPoint),
        Offset.zero);
  }
  path.lineTo(bottomLeft.dx, bottomLeft.dy);
  //left draw
  if (posSide.left != 0) {
    path.extendWithPath(
        calculatePoint(Axis.vertical, bottomLeft.dx,
            Offset(leftMiddle, offsetCenter.dy), -radiusPoint),
        Offset.zero);
  }
  path.lineTo(topLeft.dx, topLeft.dy);

  path.close();

  return path;
}

//design each point shape
calculatePoint(Axis axis, double fromPoint, Offset point, double radiusPoint) {
  Path path = Path();

  if (axis == Axis.horizontal) {
    path.moveTo(point.dx - radiusPoint / 2, fromPoint);
    path.lineTo(point.dx - radiusPoint / 2, point.dy);
    path.lineTo(point.dx + radiusPoint / 2, point.dy);
    path.lineTo(point.dx + radiusPoint / 2, fromPoint);
  } else if (axis == Axis.vertical) {
    path.moveTo(fromPoint, point.dy - radiusPoint / 2);
    path.lineTo(point.dx, point.dy - radiusPoint / 2);
    path.lineTo(point.dx, point.dy + radiusPoint / 2);
    path.lineTo(fromPoint, point.dy + radiusPoint / 2);
  }

  return path;
}
