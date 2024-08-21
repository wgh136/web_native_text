# Web Native Text

A flutter package that renders text using html.

## Getting Started

### Text

Using `WNText` widget to render text, `WNText.rich` to render rich text.

```dart
WNText(
  'Hello World',
  style: TextStyle(fontSize: 20),
),
WNText.rich(
  TextSpan(
    text: 'Hello',
    style: TextStyle(fontSize: 20),
    children: [
      TextSpan(
        text: ' World',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ],
  ),
),
```

### Editable Text

Using `WNEditableText` widget to render editable text.

```dart
// single line
WNEditableText(
  style: TextStyle(fontSize: 20),
  onChanged: (text) {
    print(text);
  },
),
// multi line
WNEditableText(
  style: TextStyle(fontSize: 20),
  singleLine: false,
  onChanged: (text) {
    print(text);
  },
),
```