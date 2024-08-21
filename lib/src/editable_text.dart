import 'dart:async';
import 'dart:js_interop';
import 'dart:math';

import 'package:flutter/widgets.dart' hide Text, Element;
import 'package:web/web.dart';
import 'package:web_native_text/src/utils.dart';

part 'form.dart';

class WNEditableRichText extends StatefulWidget {
  const WNEditableRichText(
      {super.key,
      this.controller,
      this.textDirection,
      this.style,
      this.singleLine = false,
      this.textSpanBuilder,
      this.onChanged});

  final WNEditingController? controller;

  final TextDirection? textDirection;

  final TextStyle? style;

  final void Function(String)? onChanged;

  final bool singleLine;

  final TextSpan Function(BuildContext context, String text)? textSpanBuilder;

  @override
  State<WNEditableRichText> createState() => _WNEditableRichTextState();
}

class _WNEditableRichTextState extends State<WNEditableRichText>
    with _WNEditableMixin {
  late WNEditingController _controller;

  @override
  HTMLElement? input;

  @override
  void initState() {
    addStyle();
    _controller = widget.controller ?? WNEditingController();
    _controller._registerState(this);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WNEditableRichText oldWidget) {
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ?? WNEditingController();
      _controller._registerState(this);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      if (constrains.maxWidth == double.infinity ||
          constrains.maxHeight == double.infinity) {
        throw FlutterError(
            'WNEditableText must be wrapped in a parent widget with finite width and height.');
      }
      return SizedBox(
        width: constrains.maxWidth,
        height: constrains.maxHeight,
        child: HtmlElementView.fromTagName(
          tagName: 'div',
          onElementCreated: onElementCreate,
        ),
      );
    });
  }

  void addStyle() {
    var css = '''
      .noScrollBar::-webkit-scrollbar {
        display: none;
      }

      .noScrollBar {
        -ms-overflow-style: none;
        scrollbar-width: none;
      }
    ''';
    var styleTags = document.head!.querySelectorAll('style');
    for (int i = 0; i < styleTags.length; i++) {
      var styleTag = styleTags.item(i) as Element;
      if (styleTag.innerHTML.toString().contains(css)) {
        return;
      }
    }
    var style = document.createElement('style');
    style.innerHTML = css.toJS;
    document.head!.append(style);
  }

  void onElementCreate(Object e) {
    input = (e as HTMLElement)
      ..contentEditable = 'true'
      ..style.userSelect = 'text'
      ..style.width = '100%'
      ..style.height = '100%'
      ..tabIndex = -1
      ..onInput.listen((event) {
        onContentChange();
      })
      ..onFocus.listen((event) {
        onFocus();
      })
      ..onBlur.listen((event) {
        onBlur();
      });
    if (widget.singleLine) {
      input!.style.whiteSpace = 'nowrap';
      input!.style.overflowX = 'auto';
      input!.className = 'noScrollBar';
    } else {
      input!.style.overflow = 'auto';
    }
  }

  @override
  void onBlur() {
    _controller.setIsFocused(false);
  }

  @override
  void onFocus() {
    input!.style.outline = 'none';
    input!.style.border = 'none';
    _controller.setIsFocused(true);
  }

  void onContentChange() {
    var content = input!.innerText;
    if (widget.onChanged != null) {
      widget.onChanged!(content);
    }
    updateContent(content);
  }

  @override
  void updateContent(String value) {
    assert(input != null);
    if (_controller.text == value) {
      return;
    }
    var cursorLocation = getCursorLocation();
    input!.innerHTML = ''.toJS;
    _controller._value = value;
    if (_controller.text.isEmpty) {
      return;
    }
    var textSpan =
        widget.textSpanBuilder?.call(context, value) ?? TextSpan(text: value);
    var style = DefaultTextStyle.of(context).style;
    if (widget.style != null) {
      style = style.merge(widget.style!);
    }

    void walk(InlineSpan inlineSpan, TextStyle style, HTMLElement parentNode) {
      var e = HTMLSpanElement();
      if (inlineSpan.style != null) {
        style = style.merge(inlineSpan.style!);
      }
      if (inlineSpan is TextSpan && inlineSpan.text != null) {
        writeTextToElement(
            e, style, inlineSpan.text!, null, null, widget.textDirection, null);
      } else {
        throw "Unsupported";
      }
      parentNode.append(e);

      bool walkChildren(InlineSpan span) {
        walk(span, style, e);
        return true;
      }

      inlineSpan.visitDirectChildren(walkChildren);
    }

    walk(textSpan, style, input!);

    setCursorLocation(cursorLocation);
  }

  @override
  void focus() {
    if (input == null) {
      Future.delayed(const Duration(milliseconds: 200), () {
        input?.focus();
      });
      return;
    }
    assert(input != null);
    input?.focus();
  }

  @override
  void removeFocus() {
    assert(input != null);
    input?.blur();
  }
}

class WNEditableText extends StatefulWidget {
  /// Create a widget using html <input>
  const WNEditableText(
      {super.key,
      this.controller,
      this.textDirection,
      this.style,
      this.onChanged,
      this.onSubmitted,
      this.selectionColor,
      this.inputType = 'text',
      this.autocomplete,
      this.hintText,
      this.singleLine = true});

  final WNEditingController? controller;

  final TextDirection? textDirection;

  final TextStyle? style;

  final void Function(String)? onChanged;

  final void Function(String)? onSubmitted;

  final bool singleLine;

  final Color? selectionColor;

  final String inputType;

  final String? autocomplete;

  final String? hintText;

  @override
  State<WNEditableText> createState() => _WNEditableTextState();
}

class _WNEditableTextState extends State<WNEditableText> with _WNEditableMixin {
  late WNEditingController _controller;

  @override
  HTMLElement? input;

  @override
  void initState() {
    addInputStyle(widget.selectionColor);
    _controller = widget.controller ?? WNEditingController();
    _controller._registerState(this);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WNEditableText oldWidget) {
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ?? WNEditingController();
      _controller._registerState(this);
    }
    super.didUpdateWidget(oldWidget);
  }

  double? heightForSingleLine;

  double calcHeight(double width) {
    if (widget.singleLine && heightForSingleLine != null) {
      return heightForSingleLine!;
    }
    HTMLElement temp = HTMLDivElement();
    var textStyle = DefaultTextStyle.of(context).style;
    if (widget.style != null) {
      textStyle = textStyle.merge(widget.style);
    }
    var text = '1';
    if (_controller.text.isNotEmpty && !widget.singleLine) {
      text = _controller.text.replaceFirst(' ', '1');
    }
    writeTextToElement(
        temp, textStyle, text, null, null, widget.textDirection, null);
    temp.style.position = 'fixed';
    temp.style
      ..position = 'absolute'
      ..top = '0'
      ..left = '0'
      ..width = '${width}px'
      ..wordBreak = 'break-word'
      ..whiteSpace = 'pre-wrap'
      ..visibility = 'hidden';
    document.body!.appendChild(temp);
    var rect = temp.getBoundingClientRect();
    var size = Size(rect.width, rect.height);
    temp.remove();
    if (widget.singleLine) {
      heightForSingleLine = size.height;
    }
    return size.height;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      if (constrains.maxWidth == double.infinity) {
        throw FlutterError(
            'WNEditableText must be wrapped in a parent widget with finite width.');
      }
      var height = constrains.maxHeight;
      if (height == double.infinity) {
        height = calcHeight(constrains.maxWidth);
      }
      return SizedBox(
        width: constrains.maxWidth,
        height: height,
        child: HtmlElementView.fromTagName(
          tagName: widget.singleLine ? 'input' : 'textarea',
          onElementCreated: onElementCreate,
        ),
      );
    });
  }

  void onElementCreate(Object e) {
    input = (e as HTMLElement)
      ..className = 'WNEditableText'
      ..onInput.listen((event) {
        onContentChange();
      })
      ..onFocus.listen((event) {
        onFocus();
      })
      ..onBlur.listen((event) {
        onBlur();
      });
    if (widget.autocomplete != null) {
      input!.setAttribute('autocomplete', widget.autocomplete!);
    }
    if (widget.singleLine) {
      input as HTMLInputElement
        ..type = widget.inputType
        ..placeholder = widget.hintText ?? '';
      input!.onKeyDown.listen((event) {
        if (event.key == 'Enter') {
          event.preventDefault();
          if (widget.onSubmitted != null) {
            widget.onSubmitted!(input!.innerText);
          }
        }
      });
    } else {
      (input as HTMLTextAreaElement).placeholder = widget.hintText ?? '';
      (input as HTMLTextAreaElement).style
        ..resize = 'none'
        ..whiteSpace = 'pre-wrap';
    }
    var textStyle = DefaultTextStyle.of(context).style;
    if (widget.style != null) {
      textStyle = textStyle.merge(widget.style);
    }
    writeTextToElement(
        e, textStyle, _controller.text, null, null, widget.textDirection, null);
  }

  String get value {
    if (widget.singleLine) {
      return (input as HTMLInputElement).value;
    } else {
      return (input as HTMLTextAreaElement).value;
    }
  }

  set value(String value) {
    if (widget.singleLine) {
      (input as HTMLInputElement).value = value;
    } else {
      (input as HTMLTextAreaElement).value = value;
    }
  }

  void onContentChange() {
    setState(() {});
    var content = value;
    if (widget.onChanged != null) {
      widget.onChanged!(content);
    }
    _controller._value = content;
  }

  @override
  void onBlur() {
    _controller.setIsFocused(false);
  }

  @override
  void onFocus() {
    input!.style.outline = 'none';
    input!.style.border = 'none';
    _controller.setIsFocused(true);
  }

  @override
  void updateContent(String value) {
    if (_controller.text == value) return;
    this.value = value;
  }

  @override
  void focus() {
    if (input == null) {
      Future.delayed(const Duration(milliseconds: 200), () {
        input?.focus();
      });
      return;
    }
    assert(input != null);
    input?.focus();
  }

  @override
  void removeFocus() {
    assert(input != null);
    input?.blur();
  }
}

abstract mixin class _WNEditableMixin {
  void onBlur();

  void onFocus();

  void updateContent(String value);

  void addInputStyle(Color? selectionColor) {
    var color = selectionColor ?? const Color(0xFF0078D4);
    var colorString =
        "rgba(${color.red}, ${color.green}, ${color.blue}, ${color.alpha / 255})";
    var css = '''
      .WNEditableText {
        width: 100%;
        height: 100%;
        line-height: 100%;
        outline: none;
        border: none;
        background-color: transparent;
        user-select: text;
      }
      .WNEditableText::selection {
        background-color: $colorString;
        color: white;
      }
    ''';
    const styleId = 'WNEditableText';
    var styleTags = document.head!.querySelectorAll('style#$styleId');
    for (int i = 0; i < styleTags.length; i++) {
      var styleTag = styleTags.item(i) as Element;
      styleTag.remove();
    }
    var style = document.createElement('style');
    style.innerHTML = css.toJS;
    style.id = styleId;
    document.head!.append(style);
  }

  BuildContext get context;

  void focus();

  void removeFocus();

  HTMLElement? get input;

  int getCursorLocation() {
    var selection = window.getSelection();
    if (selection == null || selection.rangeCount == 0) {
      return 0;
    }
    var range = selection.getRangeAt(0);
    var preRange = range.cloneRange();
    preRange.selectNodeContents(input!);
    preRange.setEnd(range.startContainer, range.startOffset);

    var node = preRange.cloneContents();
    var temp = HTMLDivElement();
    temp.append(node);
    return getElementPlainText(temp).length;
  }

  void setCursorLocation(int position) {
    final range = Range();
    final selection = window.getSelection();
    int charCount = 0;
    bool found = false;

    if (position == 0) {
      range.setStart(input!, 0);
      range.setEnd(input!, 0);
      selection?.removeAllRanges();
      selection?.addRange(range);
      return;
    }

    void traverseNodes(Node node) {
      if (found) return;

      if (node.nodeType == Node.TEXT_NODE) {
        final nextCharCount = charCount + (node as Text).wholeText.length;
        if (nextCharCount >= position) {
          range.setStart(node, position - charCount);
          range.setEnd(node, position - charCount);
          found = true;
        }
        charCount = nextCharCount;
      } else if (node.nodeType == Node.ELEMENT_NODE &&
          (node as Element).tagName == 'BR') {
        if (charCount + 1 >= position) {
          range.setStartAfter(node);
          range.setEndAfter(node);
          found = true;
        }
        charCount++;
      } else {
        for (int i = 0; i < node.childNodes.length; i++) {
          traverseNodes(node.childNodes.item(i)!);
        }
      }
    }

    traverseNodes(input!);

    selection?.removeAllRanges();
    selection?.addRange(range);
  }
}

class WNEditingController extends Listenable {
  String _value;

  _WNEditableMixin? _state;

  bool _isFocused = false;

  bool get isFocused => _isFocused;

  WNEditingController({String text = ''}) : _value = text;

  set text(String value) {
    _state!.updateContent(value);
    _value = value;
    notifyListeners();
  }

  String get text => _value;

  void _registerState(_WNEditableMixin state) {
    _state = state;
  }

  void setIsFocused(bool value) {
    _isFocused = value;
    notifyListeners();
  }

  final _listeners = <VoidCallback>[];

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  void finishAutocomplete() {
    var form = WNForm.of(_state!.context);
    if (form == null) {
      throw "No parent form found. AutoComplete must have a parent WNForm.";
    }
    form.finishAutocomplete();
  }

  void focus() {
    _state!.focus();
  }

  void removeFocus() {
    _state!.removeFocus();
  }

  void clear() {
    text = '';
  }

  int get cursorLocation => _state!.getCursorLocation();

  set cursorLocation(int value) {
    _state!.setCursorLocation(value);
  }
}

class WNTextField extends StatefulWidget {
  const WNTextField(
      {super.key,
      this.controller,
      this.textDirection,
      this.style,
      this.width,
      this.height,
      this.decoration,
      this.selectionColor,
      this.singleLine = true,
      this.onSubmitted,
      this.inputType = 'text',
      this.autocomplete,
      this.onChanged});

  final WNEditingController? controller;

  final TextDirection? textDirection;

  final TextStyle? style;

  final void Function(String)? onChanged;

  final void Function(String)? onSubmitted;

  final double? width;

  final double? height;

  final WNFieldDecoration? decoration;

  final bool singleLine;

  final Color? selectionColor;

  final String inputType;

  final String? autocomplete;

  @override
  State<WNTextField> createState() => _WNTextFieldState();
}

class _WNTextFieldState extends State<WNTextField> {
  late WNEditingController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? WNEditingController();
    _controller.addListener(onChanged);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WNTextField oldWidget) {
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ?? WNEditingController();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.removeListener(onChanged);
    super.dispose();
  }

  void onChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      var width = widget.width;
      var height = widget.height;
      width ??= min(400, constrains.maxWidth);
      height ??= min(42, constrains.maxHeight);
      return Container(
        width: width,
        height: height,
        decoration: buildDecoration(),
        padding: widget.decoration?.contentPadding ?? const EdgeInsets.all(8),
        child: Row(
          children: [
            if (widget.decoration?.prefixIcon != null)
              widget.decoration!.prefixIcon!,
            if (widget.decoration?.prefixIcon != null)
              const SizedBox(
                width: 8,
              ),
            Expanded(
              child: buildField(),
            ),
            if (widget.decoration?.suffixIcon != null)
              const SizedBox(
                width: 8,
              ),
            if (widget.decoration?.suffixIcon != null)
              widget.decoration!.suffixIcon!,
          ],
        ),
      );
    });
  }

  Widget buildField() {
    var editable = WNEditableText(
      controller: _controller,
      textDirection: widget.textDirection,
      style: widget.style,
      onChanged: widget.onChanged,
      singleLine: widget.singleLine,
      onSubmitted: widget.onSubmitted,
      selectionColor: widget.selectionColor,
      inputType: widget.inputType,
      autocomplete: widget.autocomplete,
      hintText: widget.decoration?.hintText,
    );
    return editable;
  }

  Decoration? buildDecoration() {
    if (widget.decoration == null) {
      return null;
    }
    if (widget.decoration!.border != null && !_controller.isFocused) {
      return ShapeDecoration(
        shape: widget.decoration!.border!,
        color: widget.decoration!.fillColor,
      );
    } else if (widget.decoration!.focusedBorder != null &&
        _controller.isFocused) {
      return ShapeDecoration(
        shape: widget.decoration!.focusedBorder!,
        color: widget.decoration!.fillColor,
      );
    } else {
      return BoxDecoration(
        color: widget.decoration!.fillColor,
      );
    }
  }
}

class WNFieldDecoration {
  const WNFieldDecoration({
    this.fillColor,
    this.border,
    this.focusedBorder,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.hintStyle,
    this.contentPadding,
  });

  final Color? fillColor;

  final ShapeBorder? border;

  final ShapeBorder? focusedBorder;

  final Widget? prefixIcon;

  final Widget? suffixIcon;

  final String? hintText;

  final TextStyle? hintStyle;

  final EdgeInsetsGeometry? contentPadding;
}
