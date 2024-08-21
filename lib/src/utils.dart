import 'package:flutter/widgets.dart' hide Element, Text;
import 'package:web/web.dart';

void writeTextToElement(
    HTMLElement e,
    TextStyle style,
    String text,
    TextAlign? textAlign,
    String? maxLines,
    TextDirection? textDirection,
    TextOverflow? overflow) {
  e.innerText = text;
  var color = style.color ?? const Color(0xFF000000);
  e.style
    ..fontWeight = style.fontWeight?.value.toString() ?? '400'
    ..fontSize = '${style.fontSize}px'
    ..color =
        "rgba(${color.red}, ${color.green}, ${color.blue}, ${color.alpha / 255})";
  if (overflow != null) {
    e.style.overflow = overflow.name;
  }
  if (style.fontFamily != null) {
    var fontFamily = style.fontFamily!;
    for (var font in style.fontFamilyFallback ?? const []) {
      fontFamily += ', $font';
    }
    e.style.fontFamily = fontFamily;
  }
  if (style.backgroundColor != null) {
    var backgroundColor = style.backgroundColor!;
    e.style.backgroundColor = "#${backgroundColor.value.toRadixString(16)}";
  }
  if (style.fontStyle != null) {
    e.style.fontStyle = style.fontStyle!.name;
  }
  if (style.letterSpacing != null) {
    e.style.letterSpacing = '${style.letterSpacing}px';
  }
  if (style.wordSpacing != null) {
    e.style.wordSpacing = '${style.wordSpacing}px';
  }
  if (style.height != null) {
    e.style.lineHeight = '${style.height}';
  }
  if (style.textBaseline != null) {
    e.style.verticalAlign = style.textBaseline!.name;
  }
  if (style.decoration != null) {
    var decoration = '';
    if (style.decoration!.contains(TextDecoration.underline)) {
      decoration += 'underline ';
    }
    if (style.decoration!.contains(TextDecoration.overline)) {
      decoration += 'overline ';
    }
    if (style.decoration!.contains(TextDecoration.lineThrough)) {
      decoration += 'line-through ';
    }
    e.style.textDecoration = decoration.trim();
  }
  if (style.decorationColor != null && style.decoration != null) {
    var decorationColor = style.decorationColor!;
    e.style.textDecorationColor = "#${decorationColor.value.toRadixString(16)}";
  }
  if (style.decorationStyle != null && style.decoration != null) {
    e.style.textDecorationStyle = style.decorationStyle!.name;
  }
  if (style.shadows != null) {
    var shadows = '';
    for (var shadow in style.shadows!) {
      shadows +=
          '${shadow.offset.dx}px ${shadow.offset.dy}px ${shadow.blurRadius}px #${shadow.color.value.toRadixString(16)},';
    }
    e.style.boxShadow = shadows;
  }
  if (textAlign != null) {
    e.style.textAlign = textAlign.name;
  }
  if (maxLines != null) {
    e.style.maxLines = maxLines.toString();
  }
  if (textDirection != null) {
    e.style.direction = textDirection.name;
  }
}

String getElementPlainText(Element element) {
  StringBuffer text = StringBuffer();
  String lastTagName = 'BR';

  void traverse(Node node) {
    if (node.nodeType == Node.TEXT_NODE) {
      text.write((node as Text).data);
    } else if (node.nodeType == Node.ELEMENT_NODE) {
      node as Element;
      if (node.tagName == 'BR') {
        text.write('\n');
      } else if (node.tagName == 'P' || node.tagName == 'DIV') {
        if (lastTagName != 'BR') {
          text.write('\n');
        }
      }
      lastTagName = node.tagName;
      for (int i = 0; i < node.childNodes.length; i++) {
        traverse(node.childNodes.item(i)!);
      }
    }
  }

  traverse(element);
  return text.toString();
}
