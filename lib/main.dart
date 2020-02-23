import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'goplayground',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('The Go Playground'),
          actions: <Widget>[
            Tooltip(
                message: 'About',
                child: IconButton(
                    icon: Icon(Icons.info_outline), onPressed: about())),
          ],
        ),
        body: goBody(),
        bottomNavigationBar: goBar(),
      ),
      theme: new ThemeData.dark(),
    );
  }
}

Widget goBody() {
  return new Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: new ListView(
      children: <Widget>[
        // WebView(
        //   initialUrl: 'https://play.golang.org/',
        //   javascriptMode: JavascriptMode.unrestricted,
        // ),
        TextFormField(
          keyboardType: TextInputType.multiline,
          autocorrect: false,
          maxLines: null,
          style: code(),
          initialValue:
              "package main\n\nimport (\n\t\"fmt\"\n)\n\nfunc main() {\n\tfmt.Println(\"Hello, playground\")\n}",
        ),
        Align(
            alignment: Alignment.topLeft,
            child: new Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: new SelectableText(
                  "",
                  style: code(),
                ))),
      ],
    ),
  );
}

Widget goBar() {
  return new BottomAppBar(
    child: new ButtonBar(
      alignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Tooltip(
            message: 'Run',
            child: IconButton(
                icon: Icon(Icons.play_circle_outline), onPressed: run())),
        Tooltip(
            message: 'Format',
            child:
                IconButton(icon: Icon(Icons.text_format), onPressed: format())),
        Tooltip(
            message: 'Imports',
            child: IconButton(
                icon: Icon(Icons.import_export), onPressed: imports())),
        Tooltip(
            message: 'Share',
            child: IconButton(icon: Icon(Icons.share), onPressed: share())),
      ],
    ),
  );
}

TextStyle code() {
  return TextStyle(
    fontSize: 18,
  );
}

Function about() {
  return null;
}

Function run() {
  return null;
}

Function format() {
  return null;
}

Function imports() {
  return null;
}

Function share() {
  return null;
}
