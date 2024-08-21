import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:web_native_text/web_native_text.dart';
import 'package:web_native_text/web_native_editable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web Native Text Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const WNText('Web Native Text Example'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 400,
                child: Center(
                  child: buildTitle(),
                ),
              ),
              const SizedBox(height: 16),
              const WNText(
                "TextField",
                style: TextStyle(fontSize: 16),
              ),
              buildTextField(context),
              const SizedBox(height: 16),
              const WNText(
                "Form",
                style: TextStyle(fontSize: 16),
              ),
              const MyForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTitle() {
    return WNText.rich(
      TextSpan(
        text: 'Web Native ',
        style: const TextStyle(
          fontSize: 24,
          color: Colors.red,
        ),
        children: <InlineSpan>[
          if (kIsWeb)
            HtmlSpan(
                text: 'Text',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.green,
                ),
                onTap: () {
                  print('Hello, World');
                },
                css: const {
                  'border': '1px solid red',
                })
          else
            TextSpan(
              text: 'Text',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.green,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  print('Hello, World');
                },
            ),
        ],
      ),
      selectable: true,
    );
  }

  Widget buildTextField(BuildContext context) {
    var theme = Theme.of(context);
    return WNTextField(
      singleLine: true,
      selectionColor: theme.colorScheme.primary,
      decoration: WNFieldDecoration(
        hintText: 'Enter your name',
        border: RoundedRectangleBorder(
          side: BorderSide(
            color: theme.colorScheme.outline,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: RoundedRectangleBorder(
          side: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class MyForm extends StatefulWidget {
  const MyForm({super.key});

  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  var usernameController = WNEditingController();
  var passwordController = WNEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return SizedBox(
      width: 400,
      height: 150,
      child: Column(
        children: [
          Expanded(
            child: WNForm(
                child: Column(
              children: [
                WNFormTextField(
                  controller: usernameController,
                  inputType: 'text',
                  decoration: WNFieldDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: 'Enter your name',
                    border: RoundedRectangleBorder(
                      side: BorderSide(
                        color: theme.colorScheme.outline,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: RoundedRectangleBorder(
                      side: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                WNFormTextField(
                  controller: passwordController,
                  inputType: 'password',
                  onSubmitted: (s) => onSubmitted(),
                  decoration: WNFieldDecoration(
                    prefixIcon: const Icon(Icons.password),
                    hintText: 'Enter your password',
                    border: RoundedRectangleBorder(
                      side: BorderSide(
                        color: theme.colorScheme.outline,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: RoundedRectangleBorder(
                      side: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            )),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onSubmitted, child: const WNText('Submit')),
        ],
      ),
    );
  }

  void onSubmitted() {
    var username = usernameController.text;
    var password = passwordController.text;
    // Do something with username and password
    print(username);
    print(password);
  }
}
