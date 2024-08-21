import 'package:flutter/widgets.dart';

class WNRichText extends StatelessWidget {
  /// Creates a widget that displays a paragraph of rich text using flutter RichText.
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
    return Text.rich(text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        textDirection: textDirection);
  }
}
