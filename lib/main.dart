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
            IconButton(icon: Icon(Icons.info_outline), onPressed: null),
          ],
        ),
        bottomNavigationBar: new BottomAppBar(
          child: new ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(child: Text("Run"), onPressed: null),
              RaisedButton(child: Text("Format"), onPressed: null),
              RaisedButton(child: Text("Imports"), onPressed: null),
              RaisedButton(child: Text("Share"), onPressed: null),
            ],
          ),
        ),
        body: goBody(),
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

TextStyle code() {
  return TextStyle(
    fontSize: 18,
  );
}
