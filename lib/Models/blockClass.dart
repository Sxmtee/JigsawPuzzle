import 'dart:ui';

import 'package:jigsawpuzzle/Widgets/jigsawBlockWidget.dart';

class BlockClass {
  Offset offset;
  Offset offsetDefault;
  JigsawBlockWidget jigsawBlockWidget;

  BlockClass(
      {required this.offset,
      required this.offsetDefault,
      required this.jigsawBlockWidget});
}
