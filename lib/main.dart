import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => new _MyApp();
}

class _MyApp extends State<MyApp> {
  String codeText =
      'package main\n\nimport (\n\t"fmt"\n)\n\nfunc main() {\n\tfmt.Println("Hello, playground")\n}';
  String returnText = '';
  String sender = '';
  String rsp = '';
  bool vis = false;
  final iconSize = 28.0;
  final codeKey = GlobalKey<FormFieldState>();
  final TextEditingController codeInput = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    codeInput.text = '$codeText';
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

// Navigation bar
  BottomAppBar goBar() {
    return new BottomAppBar(
      child: new ButtonBar(
        alignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Tooltip(message: 'Run', child: runIcon()), // Button to run code
          Tooltip(message: 'Format', child: formatIcon()),
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
          key: codeKey,
          controller: codeInput,
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
          validator: (value) {
            if (value.isEmpty) {
              return 'Go code!';
            }
            makeRequest(value);
            return null;
          },
          onChanged: (text) {
            codeText = codeInput.text;
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
            alignment: Alignment.topLeft,
            child: SelectableText(
              // Go output
              '$returnText',
            )),
      ),
      Visibility(
        child: aboutPlayground(),
        visible: vis,
      ),
    ]);
  }

  Widget aboutIcon() {
    return GestureDetector(
        onTap: () {
          setVisibility(vis);
        },
        child: Icon(Icons.info_outline, size: iconSize));
  }

  Widget runIcon() {
    return GestureDetector(
        onTap: () {
          sender = 'run';
          codeKey.currentState.validate();
        },
        child: Icon(Icons.play_circle_outline,
            color: Colors.green, size: iconSize));
  }

  Widget formatIcon() {
    return GestureDetector(
        onTap: () {
          sender = 'format';
          codeKey.currentState.validate();
        },
        child: Icon(
          Icons.text_format,
          size: iconSize,
        ));
  }

  Widget shareIcon() {
    return GestureDetector(
        onTap: () {
          sender = 'share';
          codeKey.currentState.validate();
        },
        child: Icon(
          Icons.share,
          size: iconSize,
        ));
  }

  void makeRequest(String value) {
    switch (sender) {
      case 'run':
        runPostRequest(value);
        break;
      case 'format':
        formatPostRequest(value);
        break;
      case 'share':
        sharePostRequest(value);
        break;
      default:
        break;
    }
  }

// POST REQUEST //
  changeText(String rsp) {}
  Future runPostRequest(String code) async {
    // make POST request
    Response response = await post(
        'https://play.golang.org/compile?version=2&body=' +
            Uri.encodeFull(code) +
            '&withVet=true');

    String rsp;

    // check the status code for the result
    int statusCode = response.statusCode;

    // this API passes back the id of the new item added to the body
    if (statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);

      if (map['Errors'] == '') {
        rsp = map['Events'][0]['Message'];
      } else {
        rsp = map['Errors'];
      }
    } else {
      rsp = null;
    }
    // Update output textfield
    updateText(rsp, 'output');
  }

  Future formatPostRequest(String code) async {
    Response response = await post('https://play.golang.org/fmt?body=' +
        Uri.encodeFull(code) +
        '&imports=true');
    String rsp;
    int statusCode = response.statusCode;
    if (statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['Error'] == '') {
        rsp = map['Body'];
      } else {
        rsp = map['Errors'];
      }
    } else {
      rsp = null;
    }
    // Update code textfield
    updateText(rsp, 'input');
  }

  Future sharePostRequest(String code) async {
    Response response =
        await post('https://play.golang.org/share?' + Uri.encodeFull(code));
    String rsp;
    int statusCode = response.statusCode;
    if (statusCode == 200) {
      rsp = 'https://play.golang.org/p/' + response.body;
    } else {
      rsp = null;
    }
    // Copy rsp to keyboard
    Clipboard.setData(new ClipboardData(text: rsp));
  }

  updateText(String rsp, String loc) {
    setState(() {
      if (loc == 'input') {
        if (rsp != null) {
          codeText = rsp;
        }
      } else if (loc == 'output') {
        returnText = rsp;
      }
    });
  }

  setVisibility(bool visLoc) {
    setState(() {
      vis = !visLoc;
    });
  }

  Widget aboutPlayground() {
    return new Center(
      child: new Card(
        margin: EdgeInsets.all(16.0),
        elevation: 8.0,
        child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new RichText(
            text: TextSpan(
              text: 'About the Playground',
              style: TextStyle(fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '\n\nThe Go Playground is a web service that runs on golang.org\'s servers. The service receives a Go program, vets, compiles, links, and runs the program inside a sandbox, then returns the output.\n\nIf the program contains tests or examples and no main function, the service runs the tests. Benchmarks will likely not be supported since the program runs in a sandboxed environment with limited resources.',
                    style: TextStyle(fontWeight: FontWeight.normal))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
