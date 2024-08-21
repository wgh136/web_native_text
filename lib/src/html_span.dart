import 'dart:ui';

import 'package:flutter/widgets.dart';

class HtmlSpan extends InlineSpan {
  /// Create a [HtmlSpan] with the given values.
  ///
  /// Node: Only support web platform.
  ///
  /// Do not use [HtmlSpan] in [Text.rich]
  const HtmlSpan({super.style, this.css, this.text, this.innerHtml, this.onTap});

  /// The style to apply to the text.
  final Map<String, String>? css;

  /// inner text
  final String? text;

  /// inner html
  final String? innerHtml;

  /// The callback that is triggered when the span is tapped.
  final void Function()? onTap;

  @override
  void build(ParagraphBuilder builder,
      {TextScaler textScaler = TextScaler.noScaling,
      List<PlaceholderDimensions>? dimensions}) {
    throw "Unsupported method";
  }

  @override
  int? codeUnitAtVisitor(int index, Accumulator offset) {
    throw "Unsupported method";
  }

  @override
  RenderComparison compareTo(InlineSpan other) {
    throw "Unsupported method";
  }

  @override
  void computeSemanticsInformation(
      List<InlineSpanSemanticsInformation> collector) {
    throw "Unsupported method";
  }

  @override
  void computeToPlainText(StringBuffer buffer,
      {bool includeSemanticsLabels = true, bool includePlaceholders = true}) {
    throw "Unsupported method";
  }

  @override
  InlineSpan? getSpanForPositionVisitor(
      TextPosition position, Accumulator offset) {
    throw "Unsupported method";
  }

  @override
  bool visitChildren(InlineSpanVisitor visitor) {
    return true;
  }

  @override
  bool visitDirectChildren(InlineSpanVisitor visitor) {
    return true;
  }
}
