import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:katex_flutter/katex_flutter.dart';
import 'package:uninote/bloc/ComponentBloc.dart';
import 'package:uninote/bloc/EditorBloc.dart';
import 'package:uninote/states/ComponentState.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Component.dart';

const double defaultMaxWidth = 300;
const Offset defaultPosition = Offset(0, 0);
const double topFieldBarHeight = 5;

class TextComponent extends StatefulWidget with Component {
  //Initial value parameters
  final double maxWidth;
  final String text;
  final EditorBloc editorBloc;
  TextComponent(
      {position = defaultPosition,
      this.maxWidth = defaultMaxWidth,
      this.text = "",
      this.editorBloc});
  @override
  State<TextComponent> createState() =>
      _TextState(maxWidth: maxWidth, text: text);
}

class _TextState extends State<TextComponent> {
  double maxWidth;
  List<String> textModeList = ["md", "latex", "rich"];
  int textMode = 0;
  TextEditingController _controller;
  FocusNode _focusNode;
  bool isEditorVisible = true;

  _TextState({this.maxWidth, text}) {
    isEditorVisible = true;
    _controller = TextEditingController(text: text);
    _focusNode = FocusNode(
      onKey: (node, key) => _onKey(key),
    );
    _focusNode.addListener(_handleFocus);
  }
/*
  void onDragUpdate(DragUpdateDetails details) {
    setState(() {
      position += details.delta;
    });
  }
*/
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
    if (_focusNode.hasFocus && isEditorVisible == false) {
      switchToEditor();
    } else if (!_focusNode.hasFocus && isEditorVisible == true) {
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

  Widget textFieldWidget(ComponentState state) {
    if (state.data["isTitle"] ?? false) {
      return TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: true,
        maxLines: 1,
        maxLength: 35,
        cursorColor: Colors.white,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
          ),
          hintStyle: TextStyle(color: Colors.grey.shade400),
          hintText: "Insert title",
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              width: 4,
              color: Colors.white,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: const BorderSide(color: Colors.transparent),
          ),
        ),
      );
    } else {
      return TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: true,
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
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextComponentBloc componentBloc =
        BlocProvider.of<TextComponentBloc>(context);
    widget.bloc = componentBloc;
    return BlocConsumer<TextComponentBloc, ComponentState>(
      listener: (context, state) {},
      builder: (context, state) => Positioned(
        left: state.position.dx,
        top: state.position.dy - topFieldBarHeight,
        width: state.width,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: (details) => componentBloc.add({
            "key": ComponentEvent.moved,
            "data": details.delta,
          }),
          child: Visibility(
              visible: isEditorVisible,
              child: SizedBox(
                width: state.width,
                child: Column(
                  children: [
                    Visibility(
                      visible: state.canMove,
                      child: SizedBox(
                        width: state.width,
                        height: topFieldBarHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.white),
                        ),
                      ),
                    ),
                    textFieldWidget(state),
                  ],
                ),
              ),
              replacement: GestureDetector(
                onTapUp: (details) => switchToEditor(),
                child: textWidget(),
              )),
        ),
      ),
    );
  }
}
