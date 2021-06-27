import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xml/xml.dart';
import 'package:uninote/states/ComponentState.dart';
import 'package:uninote/states/EditorState.dart';
import 'package:uninote/widgets/components/Component.dart';
import 'package:uninote/widgets/components/ImageComponent.dart';
import 'package:uninote/widgets/components/StrokeComponent.dart';
import 'package:uninote/widgets/components/TextComponent.dart';
import 'package:uninote/globals/EditorTool.dart';
import 'package:uninote/iomanager.dart';

import 'ComponentBloc.dart';

enum EditorEvent {
  appBarButtonPressed,
  toolButtonPressed,
  canvasPressed,
}

enum InputType {
  tap,
  drag,
}
enum InputState {
  start, //equivalent to down for taps
  update,
  end //equivalent to up for taps
}

class EditorBloc extends Bloc<Map<String, dynamic>, EditorState> {
  EditorBloc(EditorState initialState) : super(initialState) {
    //We'll all assume this is a magic trick
    RegExp titleFinder = RegExp(r"[^\\\/]+(?=\.[\w]+$)|[^\\\/]+$");
    String foundTitle =
        titleFinder.firstMatch(initialState.noteLocation)?.group(0) ?? "";
    getLocalFile(initialState.noteLocation, DocType.document, title: foundTitle)
        .then((file) {
      openedFileDocument = file;
      openedFileDocument!.readAsString().then((value) {
        openedDocument = XmlDocument.parse(value);
        String title =
            openedDocument.firstElementChild?.getAttribute("title") ?? "";
        String appVersion = openedDocument.firstChild
                ?.getElement("meta")
                ?.getElement("version")
                ?.getAttribute("app") ??
            "";
        String noteVersion = openedDocument.firstChild
                ?.getElement("meta")
                ?.getElement("version")
                ?.getAttribute("note") ??
            "";
        print("$appVersion, last edit: $noteVersion");
        addComponent(
            EditorSubject.text, Offset(0, 0), {"isTitle": true}, title);
        getComponentsFromFile(openedDocument);
        this.emit(state);
      });
    });
  }

  void getComponentsFromFile(XmlDocument xmlDoc) {
    XmlElement? xmlList = xmlDoc.firstChild?.getElement("content");
    if (xmlList!.children.whereType<XmlElement>().isNotEmpty) {
      xmlList.findAllElements("text").toList().forEach((element) {
        loadComponent(EditorSubject.text, element);
      });
      xmlList.findAllElements("image").toList().forEach((element) {
        loadComponent(EditorSubject.image, element);
      });
      xmlList.findAllElements("stroke").toList().forEach((element) {
        loadComponent(EditorSubject.stroke, element);
      });
    }
  }

  Widget? getClickedComponent(Offset position) {
    for (Widget item in state.componentList) {
      if (item is Component) {
        Component component = item as Component;
        if (component.hitTest(position)) {
          return item;
        }
      }
    }
  }

  void loadComponent(EditorSubject subject, XmlElement data) {
    late Widget widgetComponent;
    switch (subject) {
      case EditorSubject.text:
        TextComponentBloc bloc = TextComponentBloc.load(data);
        widgetComponent = TextComponent(
          bloc: bloc,
          editorBloc: this,
        );
        break;
      case EditorSubject.image:
        ImageComponentBloc bloc = ImageComponentBloc.load(data);
        widgetComponent = ImageComponent(
          bloc: bloc,
        );
        break;
      case EditorSubject.stroke:
        StrokeComponentBloc bloc = StrokeComponentBloc.load(data);
        widgetComponent = StrokeComponent(
          bloc: bloc,
        );
        break;
      case EditorSubject.attachment:
        // TODO: Handle this case.
        break;
    }
    state.componentList.add(widgetComponent);
  }

  Widget? addComponent(EditorSubject subject, Offset pos,
      [Map<String, dynamic> data = const {},
      String content = "",
      bool isSelected = true]) {
    bool canMove = true;
    if (data.containsKey("isTitle")) {
      canMove = !data["isTitle"]!;
    }
    deselectAllComponents();
    switch (subject) {
      case EditorSubject.text:
        TextComponentBloc bloc = TextComponentBloc(ComponentState(
          position: pos,
          width: TextComponent.defaultMaxWidth,
          height: TextComponent.defaultHeight + TextComponent.topFieldBarHeight,
          maxHeight: 1000,
          content: content,
          canMove: canMove,
          isSelected: isSelected,
          data: data,
        ));
        TextComponent textComponent = TextComponent(
          bloc: bloc,
          editorBloc: this,
        );
        state.componentList.add(textComponent);
        return textComponent;
      case EditorSubject.image:
        ComponentBloc bloc = ImageComponentBloc(
          ComponentState(
            position: pos,
            width: imageDefaultMaxWidth,
            height: imageDefaultMaxHeight,
            minWidth: 200,
            minHeight: 200,
            content:
                (state.imageUrl == "") ? imageDefaultLocation : state.imageUrl,
            canMove: canMove,
            isSelected: isSelected,
            data: data,
          ),
        );
        ImageComponent imageComponent = ImageComponent(
          position: pos,
          location: content,
          bloc: bloc,
        );
        state.componentList.add(imageComponent);
        return imageComponent;
      case EditorSubject.stroke:
        StrokeComponentBloc bloc = StrokeComponentBloc(
          ComponentState(
            position: pos,
            width: double.infinity,
            height: double.infinity,
            content: content,
            canMove: canMove,
            isSelected: isSelected,
            data: data,
          ),
        );
        StrokeComponent strokeComponent = StrokeComponent(
          bloc: bloc,
        );
        state.componentList.add(strokeComponent);
        return strokeComponent;
      case EditorSubject.attachment:
        // TODO: Handle this case.
        break;
    }
    return null;
  }

  deleteEmptyComponents(List<Widget> list) {
    list = List<Widget>.from(list);
    for (Widget selected in list) {
      Component component = selected as Component;
      if (component.bloc.state.content == "" &&
          !(component.bloc.state.data["isTitle"] ?? false)) {
        state.componentList.remove(selected);
        //"Delete" component
        selected = Container();
      }
    }
  }

  void deselectAllComponents([List<Widget> excludedList = const []]) {
    List<Widget> list = state.componentList;
    list = list.toSet().difference(excludedList.toSet()).toList();

    for (Widget selected in list) {
      Component component = selected as Component;
      component.bloc.add({
        "key": ComponentEvent.deselected,
      });
    }
  }

  void selectComponents(List<Widget> list) {
    for (Widget selected in list) {
      Component component = selected as Component;
      component.bloc.add({
        "key": ComponentEvent.selected,
      });
    }
  }

/*
  @override
  void onChange(Change<EditorState> change) {
    print(change);
    super.onChange(change);
  }
*/
  @override
  Stream<EditorState> mapEventToState(Map<String, dynamic> event) async* {
    switch (event['key']) {
      case EditorEvent.appBarButtonPressed:
        if (event['data'] is EditorToolBar) {
          if (state.toolBarVisibility == true &&
              event['data'] == state.selectedToolbar) {
            state.toolBarVisibility = false;
            state.subToolBarVisibility = false;
          } else {
            state.selectedToolbar = event['data'];
            state.toolBarVisibility = true;
            state.subToolBarVisibility = false;
          }
        }
        state.lastPressedTool = EditorTool.closing;
        yield EditorState.from(state);
        break;
      case EditorEvent.toolButtonPressed:
        if (event['type'] is EditorTool) {
          EditorTool pressedTool = event['type'];
          bool prevSubToolBarVisible = state.subToolBarVisibility;
          state.subToolBarVisibility = false;
          state.paletteVisibility = false;
          state.gridModifierVisibility = false;
          switch (event['type']) {
            case EditorTool.selectionMode:
              state.mode = EditorMode.selection;
              break;
            case EditorTool.textInsert:
              state.mode = EditorMode.insertion;
              state.subject = EditorSubject.text;
              break;
            case EditorTool.imageInsert:
              state.mode = EditorMode.insertion;
              state.subject = EditorSubject.image;
              break;
            case EditorTool.strokeInsert:
              state.mode = EditorMode.insertion;
              state.subject = EditorSubject.stroke;
              break;
            case EditorTool.backgroundPalette:
              if (state.lastPressedTool == EditorTool.backgroundPalette) {
                state.subToolBarVisibility = !prevSubToolBarVisible;
              } else {
                state.subToolBarVisibility = true;
              }
              state.paletteVisibility = true;
              break;
            case EditorTool.grid:
              if (state.lastPressedTool == EditorTool.grid ||
                  state.lastPressedTool == EditorTool.changedGridSize) {
                state.subToolBarVisibility = !prevSubToolBarVisible;
              } else {
                state.subToolBarVisibility = true;
              }
              state.paletteVisibility = true;
              state.gridModifierVisibility = true;
              break;
            case EditorTool.changedGridSize:
              state.theme["gridSize"] = event["data"];
              state.subToolBarVisibility = true;
              state.paletteVisibility = true;
              state.gridModifierVisibility = true;
              break;
            case EditorTool.changedColor:
              if (state.lastPressedTool == EditorTool.backgroundPalette) {
                state.theme["backgroundColor"] = event["data"];
              } else if (state.lastPressedTool == EditorTool.grid ||
                  pressedTool == EditorTool.changedGridSize) {
                state.theme["gridColor"] = event["data"];
                state.gridModifierVisibility = true;
              }
              state.subToolBarVisibility = true;
              state.paletteVisibility = true;
              break;
            case EditorTool.lockInsertion:
              if (state.mode == EditorMode.readOnly) {
                state.mode = EditorMode.selection;
              } else {
                state.mode = EditorMode.readOnly;
              }
              break;
            case EditorTool.markdown:
              state.selectedComponents.forEach((element) {
                Component text = element as Component;
                if (text.bloc is TextComponentBloc) {
                  text.bloc.add({
                    "key": ComponentEvent.contentChanged,
                    "mode": "markdown",
                  });
                }
              });
              break;
            case EditorTool.latex:
              state.selectedComponents.forEach((element) {
                Component text = element as Component;
                if (text.bloc is TextComponentBloc) {
                  text.bloc.add({
                    "key": ComponentEvent.contentChanged,
                    "mode": "latex",
                  });
                }
              });
              break;
            case EditorTool.plainText:
              state.selectedComponents.forEach((element) {
                Component text = element as Component;
                if (text.bloc is TextComponentBloc) {
                  text.bloc.add({
                    "key": ComponentEvent.contentChanged,
                    "mode": "plain",
                  });
                }
              });
              break;
          }
          if (!pressedTool.isSubTool) {
            if (state.lastPressedTool == event["type"]) {
              state.lastPressedTool = EditorTool.closing;
            } else {
              state.lastPressedTool = event["type"];
            }
          } else {}
        }
        yield EditorState.from(state);
        break;
      case EditorEvent.canvasPressed:
        InputType inputType = event["inputType"];
        InputState inputState = event["inputState"];
        Offset position = event["position"];
        switch (inputType) {
          case InputType.tap:
            switch (inputState) {
              case InputState.end:
                Widget? clickedComponent = getClickedComponent(position);
                bool isBackgroundClick = (clickedComponent == null);
                if (isBackgroundClick) {
                  switch (state.mode) {
                    case EditorMode.selection:
                    case EditorMode.insertion:
                      deleteEmptyComponents(state.componentList);
                      deselectAllComponents();
                      state.selectedComponents = [];
                      if (state.mode == EditorMode.insertion) {
                        if (state.subject == EditorSubject.image) {
                          state.imageUrl = event["url"];
                          Widget newComponent = addComponent(
                            state.subject,
                            position,
                          )!;
                          state.selectedComponents = [newComponent];
                        } else {
                          Widget newComponent =
                              addComponent(state.subject, position)!;
                          state.selectedComponents = [newComponent];
                        }
                      }
                      break;
                    case EditorMode.readOnly:
                      break;
                  }
                } else {
                  switch (state.mode) {
                    case EditorMode.selection:
                    case EditorMode.insertion:
                      //deselect all components
                      deselectAllComponents([clickedComponent]);

                      state.selectedComponents = [clickedComponent];

                      //select all components
                      selectComponents(state.selectedComponents);
                      break;
                    case EditorMode.readOnly:
                      break;
                  }
                }
                break;
              case InputState.start:
                // TODO: Handle this case.
                break;
              case InputState.update:
                // TODO: Handle this case.
                break;
            }
            break;
          case InputType.drag:
            switch (state.mode) {
              case EditorMode.selection:
                // TODO: Handle this case.
                break;
              case EditorMode.insertion:
                if (state.subject == EditorSubject.stroke) {
                  if (inputState == InputState.start) {
                    addComponent(EditorSubject.stroke, position, {
                      "isEditing": true,
                      "points": [position]
                    });
                  } else if (inputState == InputState.update) {
                    if (state.subject == EditorSubject.stroke) {
                      StrokeComponentBloc.editingBloc?.add({
                        "key": ComponentEvent.contentChanged,
                        "isEditing": true,
                        "newPoint": position,
                      });
                    }
                  } else if (inputState == InputState.end) {
                    if (state.subject == EditorSubject.stroke) {
                      StrokeComponentBloc.editingBloc?.add({
                        "key": ComponentEvent.contentChanged,
                        "isEditing": false,
                      });
                    }
                  }
                }
                break;
              case EditorMode.readOnly:
                // TODO: Handle this case.
                break;
            }
            break;
        }
        yield EditorState.from(state);
        break;
    }
  }
}
