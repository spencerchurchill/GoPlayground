import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:http/http.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  Playground createState() => new Playground();
}

class Playground extends State<MyApp> {
  // Text in code input TextFormField
  String codeText =
      'package main\n\nimport (\n\t"fmt"\n)\n\nfunc main() {\n\tfmt.Println("Hello, playground")\n}\n';
  // Text returned from Go program
  String returnText = '';
  // Additional text returned from server
  String sysText = '';
  // POST response text
  String rsp = '';
  // Disable button function while POST request awaits
  bool buttonUse = true;
  // Controller to validate and edit text in code input TextFormField
  final TextEditingController codeInput = new TextEditingController();
  // About the Go Playground text
  final String aboutText =
      'The Go Playground is a web service that runs on golang.org\'s servers.' +
          'The service receives a Go program, vets, compiles, links, and runs the program inside a sandbox, then returns the output.' +
          '\n\nIf the program contains tests or examples and no main function, the service runs the tests.' +
          'Benchmarks will likely not be supported since the program runs in a sandboxed environment with limited resources.';

  @override
  Widget build(BuildContext context) {
    codeInput.text = codeText;
    return new MaterialApp(
      title: 'Go Playground',
      home: new Scaffold(
          // SliverAppBar
          body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 150.0,
          flexibleSpace: FlexibleSpaceBar(
              background: FittedBox(
            child: Image.asset('assets/images/gophers.png'),
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
    ]);
  }

  TextField codeTextBox() {
    return new TextField(
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
              returnText,
              style: codeStyle(),
            ),
            SelectableText(
              // Go output
              sysText,
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

  // TOUCHABLE ICONS //
  GestureDetector aboutIcon() {
    return GestureDetector(
        onTap: () {
          makeRequest('about', aboutText);
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

  void makeRequest(String sender, String value) {
    // Hide keyboard on button press
    FocusScope.of(context).unfocus();

    if (value != '') {
      buttonUse = false;
      // Display loading text
      updateText(null, null, 'load');

      // Button invoked
      switch (sender) {
        case 'run':
          runPostRequest(value);
          break;
        case 'format':
          formatPostRequest(value);
          break;
        case 'about':
          updateText(aboutText, '', 'output');
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
      String url = 'https://play.golang.org/compile';
      Response response = await post(url, body: {
        'version': '2',
        'body': code,
        'withVet': 'true',
      });

      // check the status code for the result
      int statusCode = response.statusCode;

      // this API passes back the id of the new item added to the body
      if (statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);

        if (map['Errors'] == '') {
          rsp = map['Events'][0]['Message'];
          sysText = '\nProgram exited.';
        } else {
          rsp = map['Errors'];
          sysText = '\nGo build failed.';
        }
      }
    } on Exception catch (e) {
      rsp = 'Network error occurred.\n';
      sysText = '\n' + e.toString();
    }
    // Update output textfield
    updateText(rsp, sysText, 'output');
  }

  Future formatPostRequest(String code) async {
    String placement;
    try {
      String url = 'https://play.golang.org/fmt';
      Response response = await post(url, body: {
        'body': code,
        'imports': 'true',
      });

      int statusCode = response.statusCode;
      if (statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        if (map['Error'] == '') {
          rsp = map['Body'];
        } else {
          rsp = map['Errors'];
        }
        placement = 'input';
      }
    } on Exception catch (e) {
      rsp = 'Network error occurred.\n';
      sysText = '\n' + e.toString();
      placement = 'output';
    }
    // Update code textfield
    updateText(rsp, sysText, placement);
  }

  Future sharePostRequest(String code) async {
    try {
      String url = 'https://play.golang.org/share';
      Response response = await post(url, body: code);

      int statusCode = response.statusCode;
      if (statusCode == 200) {
        sysText = 'https://play.golang.org/p/' + response.body;
      }
      rsp = 'Play.Golang.Org Link\n';
      // Share link options
      Share.share('Go check out my Go code at ' + sysText, subject: 'Go code share link!');
    } on Exception catch (e) {
      rsp = 'Network error occurred.\n';
      sysText = '\n' + e.toString();
    }
    updateText(rsp, sysText, 'output');
  }

  void updateText(String rsp, String fT, String loc) {
    setState(() {
      switch (loc) {
        case 'input':
          if (rsp != null) {
            codeText = rsp;
          }
          sysText = fT;
          returnText = '';
          break;
        case 'output':
          if (rsp != null) {
            returnText = rsp;
          }
          sysText = fT;
          break;
        case 'load':
          returnText = 'Waiting for remote server...';
          sysText = '';
          break;
        default:
          break;
      }
      buttonUse = true;
    });
  }
}
