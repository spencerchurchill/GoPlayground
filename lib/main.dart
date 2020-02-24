import 'dart:io';

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
  // Text in code input TextFormField
  String codeText =
      'package main\n\nimport (\n\t"fmt"\n)\n\nfunc main() {\n\tfmt.Println("Hello, playground")\n}\n';
  // Text returned from Go program
  String returnText = '';
  // Additional text returned from server
  String sysText = '';
  // POST response text
  String rsp = '';
  // About RichText display
  bool vis = false;
  // Disable button function while POST request awaits
  bool buttonUse = true;
  // Controller to validate and edit text in code input TextFormField
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
              preferredSize: Size.fromHeight(40.0), child: goBar()),
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
        child: codeTextBox(),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: returnCard(),
      ),
      Visibility(
        child: aboutPlayground(),
        visible: vis,
      ),
    ]);
  }

  TextFormField codeTextBox() {
    return new TextFormField(
      controller: codeInput,
      toolbarOptions: ToolbarOptions(
        copy: true,
        cut: false,
        paste: true,
        selectAll: false,
      ),
      keyboardType: TextInputType.multiline,
      autocorrect: false,
      minLines: 10,
      maxLines: null,
      style: codeStyle(),
      onChanged: (text) {
        codeText = codeInput.text;
      },
    );
  }

  Card returnCard() {
    return new Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SelectableText(
              // Go output
              '$returnText',
              style: codeStyle(),
            ),
            SelectableText(
              // Go output
              '$sysText',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle codeStyle() {
    return TextStyle(fontSize: 18.0);
  }

  GestureDetector aboutIcon() {
    return GestureDetector(
        onTap: () {
          setVisibility(vis);
        },
        child: Icon(Icons.info_outline));
  }

  GestureDetector runIcon() {
    return GestureDetector(
        onTap: () {
          if (buttonUse) {
            makeRequest('run', codeInput.text);
          }
          return null;
        },
        child: Icon(Icons.play_circle_outline, color: Colors.green));
  }

  GestureDetector formatIcon() {
    return GestureDetector(
        onTap: () {
          if (buttonUse) {
            makeRequest('format', codeInput.text);
          }
          return null;
        },
        child: Icon(
          Icons.text_format,
        ));
  }

  GestureDetector shareIcon() {
    return GestureDetector(
        onTap: () {
          if (buttonUse) {
            makeRequest('share', codeInput.text);
          }
          return null;
        },
        child: Icon(
          Icons.share,
        ));
  }

  RichText aboutPlayground() {
    return new RichText(
      text: TextSpan(
        text: 'About the Playground',
        style: TextStyle(fontWeight: FontWeight.bold),
        children: <TextSpan>[
          TextSpan(
              text:
                  '\n\nThe Go Playground is a web service that runs on golang.org\'s servers. The service receives a Go program, vets, compiles, links, and runs the program inside a sandbox, then returns the output.\n\nIf the program contains tests or examples and no main function, the service runs the tests. Benchmarks will likely not be supported since the program runs in a sandboxed environment with limited resources.\n\nGopher image by Renee French, licensed under (Creative Commons 3.0 Attributions license)[https://creativecommons.org/licenses/by/3.0/].',
              style: TextStyle(fontWeight: FontWeight.normal))
        ],
      ),
    );
  }

  void setVisibility(bool visLoc) {
    setState(() {
      vis = !visLoc;
    });
  }

  void makeRequest(String sender, String value) {
    if (value != '') {
      buttonUse = false;
      rsp = null;
      // Button invoked
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
    } else {
      updateText('Go code!', '', 'output');
    }
  }

// POST REQUESTS //
  Future runPostRequest(String code) async {
    // make POST request
    try {
      Response response = await post(
          'https://play.golang.org/compile?version=2&body=' +
              Uri.encodeFull(code) +
              '&withVet=true');

      // check the status code for the result
      int statusCode = response.statusCode;

      // this API passes back the id of the new item added to the body
      if (statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);

        if (map['Errors'] == '') {
          rsp = map['Events'][0]['Message'];
          sysText = '\Program exited.';
        } else {
          rsp = map['Errors'];
          sysText = '\nGo build failed.';
        }
      }
    } on SocketException catch (_) {
      sysText = 'Network error occurred.';
    }
    // Update output textfield
    updateText(rsp, sysText, 'output');
  }

  Future formatPostRequest(String code) async {
    try {
      Response response = await post('https://play.golang.org/fmt?body=' +
          Uri.encodeFull(code) +
          '&imports=true');
      int statusCode = response.statusCode;
      if (statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        if (map['Error'] == '') {
          rsp = map['Body'];
        } else {
          rsp = map['Errors'];
        }
      }
    } on SocketException catch (_) {
      sysText = '\nNetwork error occurred.';
    }
    // Update code textfield
    updateText(rsp, sysText, 'input');
  }

  Future sharePostRequest(String code) async {
    try {
      Response response =
          await post('https://play.golang.org/share?' + Uri.encodeFull(code));
      int statusCode = response.statusCode;
      if (statusCode == 200) {
        sysText = 'https://play.golang.org/p/' + response.body;
      }
      // Copy rsp to keyboard
      rsp = 'Copied to clipboard\n';
      Clipboard.setData(new ClipboardData(text: sysText));
    } on SocketException catch (_) {
      rsp = '';
      sysText = '\nNetwork error occurred.';
    }

    updateText(rsp, sysText, 'output');
  }

  void updateText(String rsp, String fT, String loc) {
    setState(() {
      if (loc == 'input') {
        if (rsp != null) {
          codeText = rsp;
        } else {
          sysText = fT;
        }
      } else if (loc == 'output') {
        if (rsp != null) {
          returnText = rsp;
        }
        sysText = fT;
      }
      buttonUse = true;
    });
  }
}
