import 'dart:convert';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'dart:math' as math;

class ComponentState {
  static const double minPosX = 10;
  static const double minPosY = 10;
  static double defaultWidth = 200;
  static double defaultHeight = 200;
  late final Offset position;
  late final double width;
  late final double height;
  late final double minWidth;
  late final double minHeight;
  late final double maxWidth;
  late final double maxHeight;
  late final String content;
  late final bool canMove;
  late final bool isSelected;
  late final String key;
  late final Map<String, dynamic> data;

  String generateKey() {
    String salt = math.Random().nextInt(0xFFFF).toString();
    List<int> plainText = utf8.encode(this.hashCode.toString() + salt);
    return sha1.convert(plainText).toString();
  }

  setPosition(Offset newPos) {
    //if (!canMove) return;
    double newX = newPos.dx;
    double newY = newPos.dy;
    if (minPosX > newPos.dx) {
      newX = minPosX;
    }
    if (minPosY > newPos.dy) {
      newY = minPosY;
    }
    position = Offset(newX.clamp(minPosX, double.infinity),
        newY.clamp(minPosY, double.infinity));
  }

  setWidth(double newWidth) {
    width = newWidth.clamp(minWidth, maxWidth);
  }

  setHeight(double newHeight) {
    height = newHeight.clamp(minHeight, maxHeight);
  }

  void setBoundary(
      double minWidth, double minHeight, double maxWidth, double maxHeight) {
    this.minWidth = minWidth;
    this.minHeight = minHeight;
    this.maxWidth = maxWidth;
    this.maxHeight = maxHeight;
  }

  ComponentState(
      {required Offset position,
      required double width,
      required double height,
      this.content = "",
      this.canMove = true,
      Map<String, dynamic>? data,
      this.isSelected = true,
      this.minWidth = 20,
      this.minHeight = 20,
      this.maxWidth = 1000,
      this.maxHeight = 1000,
      String? key}) {
    setPosition(position);
    setWidth(width);
    setHeight(height);
    this.data = data ?? {};
    this.key = key ?? generateKey();
  }
  ComponentState select() {
    return copyWith(isSelected: true);
  }

  ComponentState deselect() {
    return copyWith(isSelected: false);
  }

  ComponentState move(Offset position) {
    return copyWith(position: position);
  }

  ComponentState resize(double width, double height) {
    return copyWith(width: width, height: height);
  }

  ComponentState copyWith({
    String? key,
    Offset? position,
    double? width,
    double? height,
    double? minWidth,
    double? minHeight,
    double? maxWidth,
    double? maxHeight,
    String? content,
    bool? canMove,
    bool? isSelected,
    Map<String, dynamic>? data,
  }) {
    return ComponentState(
      key: key ?? this.key,
      position: position ?? this.position,
      width: width ?? this.width,
      height: height ?? this.height,
      minWidth: minWidth ?? this.minWidth,
      minHeight: minHeight ?? this.minHeight,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      content: content ?? this.content,
      canMove: canMove ?? this.canMove,
      isSelected: isSelected ?? this.isSelected,
      data: data ?? this.data,
    );
  }

  String toString() {
    String result = "\n{\n";
    result += "\tkey: $key,\n";
    result += "\tposition: $position,\n";
    result += "\twidth: $width,\n";
    result += "\theight: $height,\n";
    result += "\tisSelected: $isSelected,\n";
    result += "\tcanMove: $canMove,\n";
    result += "}";
    return result;
  }
}
