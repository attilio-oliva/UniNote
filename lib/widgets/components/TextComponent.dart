import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:katex_flutter/katex_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const double defaultMaxWidth = 300;
const Offset defaultPosition = Offset(0, 0);

class TextComponent extends StatefulWidget {
  //Initial value parameters
  final Offset position;
  final double maxWidth;
  final String text;
  final bool autofocus;
  TextComponent(
      {this.position = defaultPosition,
      this.maxWidth = defaultMaxWidth,
      this.text = "",
      this.autofocus = true});
  @override
  State<TextComponent> createState() => _TextState(
      position: position, maxWidth: maxWidth, text: text, autofocus: autofocus);
}

class _TextState extends State<TextComponent> {
  Offset position;
  double maxWidth;
  List<String> textModeList = ["md", "latex", "rich"];
  int textMode = 0;
  TextEditingController _controller;
  FocusNode _focusNode;
  bool isEditorVisible = true;
  bool autofocus;

  _TextState({this.position, this.maxWidth, text, this.autofocus}) {
    isEditorVisible = autofocus;
    _controller = TextEditingController(text: text);
    _focusNode = FocusNode(
      onKey: (node, key) => _onKey(key),
    );
    _focusNode.addListener(_handleFocus);
  }

  void onDragUpdate(DragUpdateDetails details) {
    setState(() {
      position += details.delta;
    });
  }

  bool _onKey(RawKeyEvent key) {
    if (key.character == "PageUp") {
      textMode = (textMode + 1) % textModeList.length;
    } else if (key.character == "PageDown") {
      textMode = (textMode - 1) % textModeList.length;
    } else if (key.character == "Escape") {
      switchToParsed();
    }
    return false;
  }

  void _handleFocus() {
    if ((_focusNode.hasFocus) && (isEditorVisible = false)) {
      switchToEditor();
    } else if ((!_focusNode.hasFocus) && (isEditorVisible = true)) {
      switchToParsed();
    }
  }

  void switchToParsed() {
    setState(() {
      isEditorVisible = false;
      _focusNode.unfocus();
    });
  }

  void switchToEditor() {
    setState(() {
      isEditorVisible = true;
      _focusNode.requestFocus();
    });
  }

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  Widget textWidget() {
    Widget textWidget;
    if (textModeList[textMode] == "md") {
      textWidget = Markdown(
        shrinkWrap: true,
        //selectable: true,
        onTapLink: (text, href, title) => _launchURL(href),
        styleSheet: MarkdownStyleSheet(
          codeblockDecoration: BoxDecoration(
            color: Colors.deepPurple,
            //border: Border.all(width: 4, color: Colors.white),
            borderRadius: BorderRadius.circular(4),
          ),
          code: TextStyle(
              color: Colors.white, backgroundColor: Colors.transparent),
        ),
        data: _controller.text,
        extensionSet: md.ExtensionSet(
          md.ExtensionSet.gitHubFlavored.blockSyntaxes,
          [md.EmojiSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
        ),
      );
    } else if (textModeList[textMode] == "latex") {
      textWidget = Builder(
        builder: (context) => KaTeX(
          laTeXCode: Text(_controller.text,
              style: Theme.of(context).textTheme.bodyText1),
          //delimiter: r'$',
          //displayDelimiter: r'$$',
        ),
      );
    } else {
      textWidget = Text(_controller.text);
    }
    return textWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      width: maxWidth,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) => onDragUpdate(details),
        child: Visibility(
            visible: isEditorVisible,
            child: SizedBox(
              width: maxWidth,
              height: maxWidth,
              child: Column(
                children: [
                  SizedBox(
                    width: maxWidth,
                    height: 5,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(color: Colors.white),
                    ),
                  ),
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: autofocus,
                    maxLines: null,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            replacement: GestureDetector(
              onTapUp: (details) => switchToEditor(),
              child: textWidget(),
            )),
      ),
    );
  }
}
