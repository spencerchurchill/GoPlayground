import 'package:flutter/material.dart';
import 'aGP.dart';

const iconSize = 28.0;
final code = GlobalKey<FormFieldState>();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Go Playground',
      home: new Scaffold(
          // SliverAppBar
          body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 150,
          flexibleSpace: FlexibleSpaceBar(
              background: FittedBox(
            child: Image.asset('assets/images/gophers.jpg'),
            fit: BoxFit.fill,
          )),
          actions: <Widget>[
            Tooltip(message: 'About', child: aboutIcon()),
          ],
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(iconSize + 16.0), child: goBar()),
          pinned: true,
          floating: true,
          snap: true,
        ),
        SliverList(delegate: goBody()),
      ])),
      theme: new ThemeData.dark(),
    );
  }
}

// Navigation bar
BottomAppBar goBar() {
  return new BottomAppBar(
    child: new ButtonBar(
      alignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Tooltip(message: 'Run', child: runIcon()), // Button to run code
        Tooltip(message: 'Format', child: formatIcon()),
        Tooltip(message: 'Imports', child: importsIcon()),
        Tooltip(message: 'Share', child: shareIcon()),
      ],
    ),
  );
}

SliverChildListDelegate goBody() {
  return new SliverChildListDelegate([
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        key: code,
        toolbarOptions: ToolbarOptions(
          copy: true,
          cut: false,
          paste: true,
          selectAll: false,
        ),
        keyboardType: TextInputType.multiline,
        autocorrect: false,
        minLines: 9,
        maxLines: null,
        initialValue:
            // Code input field
            'package main\n\nimport (\n\t"fmt"\n)\n\nfunc main() {\n\tfmt.Println("Hello, playground")\n}',
        validator: (value) {
          if (value.isEmpty) {
            return 'Go code!';
          }
          return null;
        },
      ),
    ),
    Divider(color: Colors.white, height: 20.0),
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
          alignment: Alignment.topLeft,
          child: new SelectableText(
            // Go output
            'Hello, playground\n\nProgram exited.',
          )),
    ),
    Visibility(
      child: AGP.aboutPlayground(),
      visible: false,
    ),
  ]);
}

Widget aboutIcon() {
  return GestureDetector(
      onTap: () {
        about();
      },
      child: Icon(Icons.info_outline, size: iconSize));
}

Widget runIcon() {
  return GestureDetector(
      onTap: () {
        run();
      },
      child:
          Icon(Icons.play_circle_outline, color: Colors.green, size: iconSize));
}

Widget formatIcon() {
  return GestureDetector(
      onTap: () {
        format();
      },
      child: Icon(
        Icons.text_format,
        size: iconSize,
      ));
}

Widget importsIcon() {
  return GestureDetector(
      onTap: () {
        imports();
      },
      child: Icon(
        Icons.import_export,
        size: iconSize,
      ));
}

Widget shareIcon() {
  return GestureDetector(
      onTap: () {
        share();
      },
      child: Icon(
        Icons.share,
        size: iconSize,
      ));
}

Function about() {
  print('about');
  return null;
}

Function run() {
  print('run');
  code.currentState.validate();
  return null;
}

Function format() {
  print('format');
  return null;
}

Function imports() {
  print('imports');
  return null;
}

Function share() {
  print('share');
  return null;
}
