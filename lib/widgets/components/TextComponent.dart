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

const Offset defaultPosition = Offset(0, 0);

class TextComponent extends StatefulWidget with Component {
  static double maxWidthTitle = 500;
  static const double defaultMaxWidth = 300;
  static const double defaultHeight = 45;
  static const double topFieldBarHeight = 5;
  final TextComponentBloc bloc;
  final EditorBloc editorBloc;
  TextComponent({
    position = defaultPosition,
    required this.bloc,
    required this.editorBloc,
  });
  @override
  State<TextComponent> createState() => _TextState();

  @override
  bool hitTest(Offset point) {
    return bloc.hitTest(point);
  }

  @override
  String parse() {
    // TODO: implement parse
    throw UnimplementedError();
  }

  void onChildSize(Size size) {
    print("${size.width}, ${size.height}");
    bloc.add({
      "key": ComponentEvent.resized,
      "width": size.width,
      "height": size.height
    });
  }
}

class _TextState extends State<TextComponent> {
  late double maxWidth;
  List<String> textModeList = ["md", "latex", "rich"];
  int textMode = 0;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    maxWidth = widget.bloc.state.maxWidth;
    _controller = TextEditingController(text: widget.bloc.state.content);
    _controller.addListener(() {
      widget.bloc.add(
          {"key": ComponentEvent.contentChanged, "data": _controller.text});
    });
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
    if (_focusNode.hasFocus && !widget.bloc.state.isSelected) {
      switchToEditor();
      widget.editorBloc.add({
        "key": EditorEvent.canvasPressed,
        "position": widget.bloc.state.position,
        "inputType": InputType.tap,
        "inputState": InputState.end,
      });
    } else if (!_focusNode.hasFocus && widget.bloc.state.isSelected) {
      switchToParsed();
    }
  }

  void switchToParsed() {
    setState(() {
      _focusNode.unfocus();
    });
  }

  void switchToEditor() {
    setState(() {
      _focusNode.requestFocus();
    });
  }

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  Widget textWidget(ComponentState state) {
    Widget textWidget;
    if (textModeList[textMode] == "md") {
      textWidget = Markdown(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 13),
        //selectable: true,
        onTapLink: (text, href, title) => _launchURL(href!),
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(fontSize: 16),
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
        maxLength: 35,
        cursorColor: Colors.white,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
          ),
          hintStyle: TextStyle(color: Colors.grey.shade400),
          hintText: "Insert title",
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 17),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: const BorderSide(color: Colors.transparent),
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
    return BlocConsumer<TextComponentBloc, ComponentState>(
      bloc: widget.bloc,
      listener: (context, state) {
        if (!state.isSelected && _focusNode.hasFocus) {
          /*
          final Size size = (TextPainter(
                  text: TextSpan(
                      text: _controller.text,
                      style: Theme.of(context).textTheme.bodyText1),
                  maxLines: null,
                  //textScaleFactor: MediaQuery.of(context).textScaleFactor,
                  textDirection: TextDirection.ltr)
                ..layout())
              .size;
          widget.onChildSize(size);
          */
          _focusNode.unfocus();
        }
        if (state.isSelected && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      },
      builder: (context, state) => Positioned(
        left: state.position.dx,
        top: state.position.dy,
        width: state.width,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          //onTap: () => print("comp"),
          onPanUpdate: (details) => widget.bloc.add({
            "key": ComponentEvent.moved,
            "data": details.delta,
          }),
          child: Container(
            padding: EdgeInsets.zero,
            decoration: (state.data["isTitle"] ?? false)
                ? BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 4,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
            child: Visibility(
              visible: state.isSelected || (state.data["isTitle"] ?? false),
              child: SizedBox(
                width: state.width,
                child: Column(
                  children: [
                    Visibility(
                      visible: state.canMove && state.isSelected,
                      child: SizedBox(
                        width: state.width,
                        height: TextComponent.topFieldBarHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.white),
                        ),
                      ),
                    ),
                    textFieldWidget(state),
                  ],
                ),
              ),
              replacement: textWidget(state),
            ),
          ),
        ),
      ),
    );
  }
}
