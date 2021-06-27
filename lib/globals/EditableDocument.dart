import 'package:xml/xml.dart';

class EditableDocument extends XmlTransformer {
  String nodeName = "component";
  late XmlElement parent;
  Map<String, String> attributeBindings = {};
  Map<String, Map<String, String>> childrenBindings = {};
  late String childKey;
  T addElement<T>(XmlHasVisitor visitable,
      {required XmlElement parent,
      required String name,
      required Map<String, String> bindings,
      String? lastKey,
      Map<String, Map<String, String>> childrenBindings = const {}}) {
    this.childKey = lastKey ?? bindings["id"]!;
    this.attributeBindings = bindings;
    this.childrenBindings = childrenBindings;
    this.nodeName = name;
    this.parent = parent;
    return visit(visitable);
  }

  @override
  XmlElement visitElement(XmlElement node) {
    if (node.name.qualified == parent.name.qualified) {
      bool attributesEqual = true;
      int size = node.attributes.length;
      if (size != 0) {
        if (parent.attributes
                .any((element) => element.name.qualified == "id") &&
            node.attributes.any((element) => element.name.qualified == "id")) {
          String parentKey = parent.attributes
              .firstWhere((element) => element.name.qualified == "id")
              .value;
          String foundParentKey = node.attributes
              .firstWhere((element) => element.name.qualified == "id")
              .value;
          if (parentKey != foundParentKey) {
            attributesEqual = false;
          }
        }
      } else if (node.attributes.length != parent.attributes.length) {
        attributesEqual = false;
      } else {
        for (int i = 0; i < size; i++) {
          if (node.attributes[i] != parent.attributes[i]) {
            attributesEqual = false;
            break;
          }
        }
      }
      if (attributesEqual) {
        List<XmlAttribute> attributes = [];
        List<XmlElement> children = [];
        XmlElement newChild;
        attributeBindings.forEach((key, value) {
          attributes.add(XmlAttribute(XmlName(key), value));
        });
        if (childrenBindings.isNotEmpty) {
          childrenBindings.forEach((child, binding) {
            List<XmlAttribute> childAttributes = [];
            binding.forEach((key, value) {
              childAttributes.add(XmlAttribute(XmlName(key), value));
            });
            children.add(XmlElement(XmlName(child), childAttributes));
          });
        }
        newChild = XmlElement(
          XmlName(nodeName), //visit(node.name)
          // set attributes
          attributes,
          children,
        );
        int childIndex = -1;
        bool isChildPresent = node.children.any((element) {
          String? elementKey = element.getAttribute("id");
          if (elementKey != null) {
            if (elementKey == childKey) {
              childIndex = node.children.indexOf(element);
              return true;
            }
          }
          return false;
        });
        if (isChildPresent) {
          node.children.removeAt(childIndex);
          node.children.insert(childIndex, newChild);
        } else {
          node.children.add(newChild);
        }
      }
    }
    return super.visitElement(node);
  }
}
