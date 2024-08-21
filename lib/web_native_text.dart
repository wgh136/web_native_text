import 'package:flutter/widgets.dart';
import 'src/rich_text_flutter.dart'
    if (dart.library.html) 'src/rich_text.dart';

export 'src/html_span.dart';

class WNText extends StatelessWidget {
  /// Creates a widget that displays a paragraph of text.
  /// On web platform, it uses platform view to render text.
  /// On other platforms, it uses flutter RichText to render text.
  const WNText(this.data,
      {super.key,
      this.style,
      this.textAlign,
      this.maxLines,
      this.overflow = TextOverflow.clip,
      this.selectable = false,
      this.textDirection})
      : text = null;

  /// Creates a widget that displays a paragraph of rich text.
  /// On web platform, it uses platform view to render text.
  /// On other platforms, it uses flutter RichText to render text.
  /// 
  /// On web platform, [WidgetSpan] is not supported, use [HtmlSpan] instead.
  const WNText.rich(this.text,
      {super.key,
      this.style,
      this.textAlign,
      this.maxLines,
      this.overflow = TextOverflow.clip,
      this.selectable = false,
      this.textDirection})
      : data = '';

  /// The text to display in this widget.
  final String data;

  /// The text style to apply to the text.
  final TextStyle? style;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  final int? maxLines;

  /// How visual overflow should be handled.
  final TextOverflow overflow;

  /// The directionality of the text.
  final TextDirection? textDirection;

  /// Whether the text should be selectable.
  final bool selectable;

  /// The text to display in this widget.
  final InlineSpan? text;

  @override
  Widget build(BuildContext context) {
    if (text != null) {
      return WNRichText(text!,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          selectable: selectable,
          textDirection: textDirection);
    } else {
      return WNRichText(TextSpan(text: data),
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          selectable: selectable,
          textDirection: textDirection);
    }
  }
}
