import 'dart:ui';

import 'package:uninote/bloc/ComponentBloc.dart';

abstract class Component {
  bool hitTest(Offset point);
  String parse();
}
