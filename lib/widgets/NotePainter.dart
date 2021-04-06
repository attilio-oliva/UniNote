import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class NotePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final text =
        'Hello, world.\nAnother line of text.\nA line of text that wraps around.';

    // draw the text
    final textStyle = ui.TextStyle(
      color: Colors.white,
      fontSize: 30,
    );
    final paragraphStyle = ui.ParagraphStyle(
      textDirection: TextDirection.ltr,
    );
    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(text);

    final constraints = ui.ParagraphConstraints(width: 300);
    final paragraph = paragraphBuilder.build();
    paragraph.layout(constraints);
    final offset = Offset(0, 0);
    canvas.drawParagraph(paragraph, offset);
  }

  @override
  bool shouldRepaint(NotePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(NotePainter oldDelegate) => false;
}
