part of "editable_text.dart";

class WNForm extends StatefulWidget {
  const WNForm({super.key, this.width, this.height, required this.child});

  final double? width;

  final double? height;

  final Widget child;

  static WNFormState? of(BuildContext context) {
    return context.findAncestorStateOfType<WNFormState>();
  }

  @override
  State<WNForm> createState() => WNFormState();
}

class WNFormState extends State<WNForm> {
  HTMLFormElement? _form;
  HTMLInputElement? _submit;

  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      var width = widget.width;
      var height = widget.height;
      width ??= min(400, constrains.maxWidth);
      height ??= min(400, constrains.maxHeight);
      return SizedBox(
        width: width,
        height: height,
        child: Stack(
          key: _key,
          children: [
            Positioned.fill(
                child: HtmlElementView.fromTagName(
              tagName: 'form',
              onElementCreated: _onElementCreate,
            )),
            Positioned.fill(child: widget.child),
          ],
        ),
      );
    });
  }

  void _onElementCreate(Object e) {
    _form = e as HTMLFormElement
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.position = 'relative'
      ..autocomplete = 'on'
      ..onSubmit.listen((event) {
        event.preventDefault();
      });
    _submit = HTMLInputElement()
      ..style.display = "none"
      ..tabIndex = -1;
    _form!.appendChild(_submit!);
  }

  RenderObject get _renderBox {
    return _key.currentContext!.findRenderObject()!;
  }

  void finishAutocomplete() {
    _submit!.click();
  }
}

class WNFormEditableText extends StatefulWidget {
  const WNFormEditableText(
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
  State<WNFormEditableText> createState() => _WNFormEditableTextState();
}

class _WNFormEditableTextState extends State<WNFormEditableText>
    with _WNEditableMixin {
  late WNEditingController _controller;

  @override
  HTMLElement? input;

  @override
  void initState() {
    Future.microtask(() => layout());
    addInputStyle(widget.selectionColor);
    _controller = widget.controller ?? WNEditingController();
    _controller._registerState(this);
    super.initState();
    window.onblur = () {
      FocusManager.instance.primaryFocus!.unfocus();
    }.toJS;
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }

  void layout() {
    var renderBox = context.findRenderObject() as RenderBox;
    var formState = context.findAncestorStateOfType<WNFormState>();
    if (formState == null) {
      throw "No parent form found. WNFormEditableText must have a parent WNForm.";
    }
    var offset =
        renderBox.localToGlobal(Offset.zero, ancestor: formState._renderBox);
    var size = renderBox.size;
    if (widget.singleLine) {
      input = HTMLInputElement()
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
      input = HTMLTextAreaElement()..placeholder = widget.hintText ?? '';
      if (widget.inputType != 'text') {
        throw "inputType must be text for multi-line input";
      }
    }
    input!
      ..style.width = '${size.width}px'
      ..style.height = '${size.height}px'
      ..style.position = 'absolute'
      ..style.left = '${offset.dx}px'
      ..style.top = '${offset.dy}px'
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
    formState._form!.append(input!);
    if (widget.autocomplete != null) {
      input!.setAttribute('autocomplete', widget.autocomplete!);
    }
    var textStyle = DefaultTextStyle.of(context).style;
    if (widget.style != null) {
      textStyle = textStyle.merge(widget.style);
    }
    writeTextToElement(input!, textStyle, _controller.text, null, null,
        widget.textDirection, null);
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

class WNFormTextField extends StatefulWidget {
  const WNFormTextField(
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
  State<WNFormTextField> createState() => _WNFormTextFieldState();
}

class _WNFormTextFieldState extends State<WNFormTextField> {
  late WNEditingController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? WNEditingController();
    _controller.addListener(onChanged);
    //node = widget.focusNode ?? FocusNode();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WNFormTextField oldWidget) {
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ?? WNEditingController();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.removeListener(onChanged);
    //node.dispose();
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
    var editable = WNFormEditableText(
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
