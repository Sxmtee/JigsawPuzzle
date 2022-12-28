import 'package:flutter/material.dart';
import 'package:jigsawpuzzle/Models/jigsawPos.dart';

class ImageBox {
  Widget image;
  JigsawPos posSide;
  Offset offsetCenter;
  Size size;
  double radiusPoint;
  bool isDone;

  ImageBox(
      {required this.image,
      required this.posSide,
      required this.offsetCenter,
      required this.size,
      required this.radiusPoint,
      required this.isDone});
}
