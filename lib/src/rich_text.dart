import 'dart:js_interop';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart';
import 'package:web_native_text/src/html_span.dart';
import 'package:web_native_text/src/utils.dart';

class WNRichText extends StatelessWidget {
  /// Creates a widget that displays a paragraph of rich text using web platform view.
  const WNRichText(this.text,
      {super.key,
      this.style,
      this.textAlign,
      this.maxLines,
      this.overflow = TextOverflow.clip,
      this.selectable = false,
      this.textDirection});

  final InlineSpan text;

  final TextStyle? style;

  final TextAlign? textAlign;

  final int? maxLines;

  final TextOverflow overflow;

  final TextDirection? textDirection;

  final bool selectable;

  @override
  Widget build(BuildContext context) {
    var style = this.style ?? const TextStyle();
    style = DefaultTextStyle.of(context).style.merge(style);
    return LayoutBuilder(builder: (context, constrains) {
      return SizedBox.fromSize(
        size: calcSize(constrains, style),
        child: IgnorePointer(
          child: HtmlElementView.fromTagName(
            tagName: 'div',
            onElementCreated: (e) {
              onElementCreated(e, style);
            },
          ),
        ),
      );
    });
  }

  void onElementCreated(Object e, TextStyle style) {
    var element = e as HTMLElement;
    element.style.display = 'inline-block';
    if (selectable) {
      element.style.userSelect = 'text';
    }
    void walk(InlineSpan inlineSpan, TextStyle style, HTMLElement parentNode) {
      var e = HTMLSpanElement();
      if (inlineSpan.style != null) {
        style = style.merge(inlineSpan.style!);
      }
      if (inlineSpan is TextSpan && inlineSpan.text != null) {
        writeTextToElement(e, style, inlineSpan.text!, textAlign,
            maxLines?.toString(), textDirection, overflow);
        if (inlineSpan.recognizer is TapGestureRecognizer) {
          e.onClick.listen((event) {
            (inlineSpan.recognizer as TapGestureRecognizer).onTap!();
          });
        }
        if (inlineSpan.mouseCursor == SystemMouseCursors.click) {
          e.style.cursor = 'pointer';
        }
      } else if (inlineSpan is WidgetSpan) {
        throw "WidgetSpan is not supported";
      } else if (inlineSpan is HtmlSpan) {
        if (inlineSpan.css != null) {
          inlineSpan.css!.forEach((key, value) {
            e.style.setProperty(key, value);
          });
        }
        if (inlineSpan.text != null) {
          writeTextToElement(e, style, inlineSpan.text!, textAlign,
              maxLines?.toString(), textDirection, overflow);
        }
        if (inlineSpan.innerHtml != null) {
          e.setHTMLUnsafe(inlineSpan.innerHtml!.toJS);
        }
        if (inlineSpan.onTap != null) {
          e.onClick.listen((event) {
            inlineSpan.onTap!();
          });
          e.style.cursor = 'pointer';
        }
      }
      parentNode.append(e);

      bool walkChildren(InlineSpan span) {
        walk(span, style, e);
        return true;
      }

      inlineSpan.visitDirectChildren(walkChildren);
    }

    walk(text, style, e);
  }

  Size calcSize(BoxConstraints constrains, TextStyle style) {
    if (constrains.maxHeight == double.infinity) {
      constrains = constrains.copyWith(maxHeight: 10000);
    }
    if (constrains.maxWidth == double.infinity) {
      constrains = constrains.copyWith(maxWidth: 10000);
    }
    var element = HTMLDivElement();
    element.style
      ..position = 'absolute'
      ..top = '0'
      ..left = '0'
      ..width = '${constrains.maxWidth}px'
      ..height = '${constrains.maxHeight}px'
      ..visibility = 'hidden';
    var textDiv = HTMLDivElement();
    onElementCreated(textDiv, style);
    textDiv.style.position = 'absolute';
    element.append(textDiv);
    document.body!.appendChild(element);
    var rect = textDiv.getBoundingClientRect();
    var size = Size(rect.width, rect.height);
    element.remove();
    return size;
  }
}
